 /*
 *-------------------------------------------------------------------------
 * raohook.c
 * Copyright (c) 2008-2024, PostgreSQL Global Development Group
 * IDENTIFICATION
 *	  contrib/raohook/raohook.c
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include <math.h>
#include <sys/stat.h>
#include <unistd.h>

#include "access/parallel.h"
#include "catalog/pg_authid.h"
#include "common/hashfn.h"
#include "common/int.h"
#include "executor/instrument.h"
#include "funcapi.h"
#include "jit/jit.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "nodes/queryjumble.h"
#include "optimizer/planner.h"
#include "parser/analyze.h"
#include "parser/parsetree.h"
#include "parser/scanner.h"
#include "parser/scansup.h"
#include "pgstat.h"
#include "storage/fd.h"
#include "storage/ipc.h"
#include "storage/lwlock.h"
#include "storage/shmem.h"
#include "storage/spin.h"
#include "tcop/utility.h"
#include "utils/acl.h"
#include "utils/builtins.h"
#include "utils/memutils.h"
#include "utils/timestamp.h"

PG_MODULE_MAGIC;


/* Magic number identifying the stats file format */
//static const uint32 PGSS_FILE_HEADER = 0x20220408;

/* PostgreSQL major version number, changes in which invalidate all entries */
//static const uint32 PGSS_PG_MAJOR_VERSION = PG_VERSION_NUM / 100;

/* XXX: Should USAGE_EXEC reflect execution time and/or buffer usage? */
#define USAGE_EXEC(duration)	(1.0)
#define USAGE_INIT				(1.0)	/* including initial planning */
#define ASSUMED_MEDIAN_INIT		(10.0)	/* initial assumed median usage */
#define ASSUMED_LENGTH_INIT		1024	/* initial assumed mean query length */
#define USAGE_DECREASE_FACTOR	(0.99)	/* decreased every entry_dealloc */
#define STICKY_DECREASE_FACTOR	(0.50)	/* factor for sticky entries */
#define USAGE_DEALLOC_PERCENT	5	/* free this % of entries at once */
#define IS_STICKY(c)	((c.calls[PGSS_PLAN] + c.calls[PGSS_EXEC]) == 0)

/*
 * Extension version number, for supporting older extension versions' objects
	RAODB_V1_1,
	RAODB_V1_2,
	RAODB_V1_3,
	PGSS_V1_11,
} pgssVersion;
 */


//int IsBackgroundWorker = MyProc->isBackgroundWorker;
int IsBackgroundWorker = 0; 

/* Current nesting depth of planner/ExecutorRun/ProcessUtility calls */
//static int	nesting_level = 0;

/* Links to shared memory state */
//static HTAB *pgss_hash = NULL;

/*---- GUC variables ----*/


// ################################################################################
// save hook values in case of unload 
// ################################################################################
static emit_log_hook_type prev_emit_log_hook = NULL;
//static shmem_request_hook_type prev_shmem_request_hook = NULL;
//static shmem_startup_hook_type prev_shmem_startup_hook = NULL;
//static shmem_shutdown_hook_type prev_shmem_shutdown_hook = NULL;
//static check_password_hook_type prev_check_password_hook = NULL;
//static ClientAuthentication_hook_type prev_ClientAuthentication_hook = NULL;
//static ExecutorCheckPerms_hook_type prev_ExecutorCheckPerms_hook = NULL;
//static object_access_hook_type prev_object_access_hook = NULL;
//static row_security_policy_hook_permissive_type prev_row_security_policy_hook_permissive = NULL;
//static row_security_policy_hook_restrictive_type prev_row_security_policy_hook_restrictive = NULL;
//static needs_fmgr_hook_type prev_needs_fmgr_hook = NULL;
//static fmgr_hook_type prev_fmgr_hook = NULL;
//static ExplainOneQuery_hook_type prev_ExplainOneQuery_hook = NULL;
//static get_attavgwidth_hook_type prev_get_attavgwidth_hook = NULL;
//static get_index_stats_hook_type prev_get_index_stats_hook = NULL;
//static get_relation_info_hook_type prev_get_relation_info_hook = NULL;
//static get_relation_stats_hook_type prev_get_relation_stats_hook = NULL;
//static planner_hook_type prev_planner_hook = NULL;
//static join_search_hook_type prev_join_search_hook = NULL;
//static set_rel_pathlist_hook_type prev_set_rel_pathlist_hook = NULL;
//static set_join_pathlist_hook_type prev_set_join_pathlist_hook = NULL;
//static create_upper_paths_hook_type prev_create_upper_paths_hook = NULL;
//static post_parse_analyze_hook_type prev_post_parse_analyze_hook = NULL;
static ExecutorStart_hook_type prev_ExecutorStart_hook = NULL;
static ExecutorRun_hook_type prev_ExecutorRun_hook = NULL;
static ExecutorFinish_hook_type prev_ExecutorFinish_hook = NULL;
static ExecutorEnd_hook_type prev_ExecutorEnd_hook = NULL;
static ProcessUtility_hook_type prev_ProcessUtility_hook = NULL;
//static func_setup_type prev_func_setup = NULL;
//static func_beg_type prev_func_beg = NULL;
//static func_end_type prev_func_end = NULL;
//static stmt_beg_type prev_stmt_beg = NULL;
//static stmt_end_type prev_stmt_end = NULL;

// ################################################################################
// define new pg_settings default values
// ################################################################################
static bool v_raohook_trace_login = true; //boolean
static bool v_raohook_trace_parser = true; //boolean
static bool v_raohook_trace_planner = true; //boolean
static bool v_raohook_trace_explainer = true; //boolean
static bool v_raohook_trace_executor = true; //boolean
static char *v_raohook_trace_prefix = "raohook";	//string
static int  v_raohook_trace_level =5; 	//valueAddr

// ################################################################################
// hook function declarations
// ################################################################################
void _PG_init(void);
void _PG_fini(void);
static void RAODB_emit_log_hook (ErrorData *edata);
//static void RAODB_shmem_request_hook(void);
//static void RAODB_shmem_startup_hook(void);
//static void RAODB_shmem_shutdown_hook(int code, Datum arg);
//
//static void RAODB_check_password_hook
//static void RAODB_ClientAuthentication_hook(Port *, Datum arg);
//static void RAODB_ExecutorCheckPerms_hook
//static void RAODB_object_access_hook
//static void RAODB_row_security_policy_hook_permissive
//static void RAODB_row_security_policy_hook_restrictive
//static void RAODB_needs_fmgr_hook
//static void RAODB_fmgr_hook
//static void RAODB_ExplainOneQuery_hook
//static void RAODB_get_attavgwidth_hook
//static void RAODB_get_index_stats_hook
//static void RAODB_get_relation_info_hook
//static void RAODB_get_relation_stats_hook
//static PlannedStmt *RAODB_planner_hook(Query *parse, const char *query_string, int cursorOptions, ParamListInfo boundParams);
//static void RAODB_join_search_hook
//static void RAODB_set_rel_pathlist_hook
//static void RAODB_set_join_pathlist_hook
//static void RAODB_create_upper_paths_hook
//static void RAODB_post_parse_analyze_hook(ParseState *pstate, Query *query, JumbleState *jstate);
static void RAODB_ExecutorStart_hook(QueryDesc *queryDesc, int eflags);
static void RAODB_ExecutorRun_hook(QueryDesc *queryDesc, ScanDirection direction, uint64 count, bool execute_once);
static void RAODB_ExecutorFinish_hook(QueryDesc *queryDesc);
static void RAODB_ExecutorEnd_hook(QueryDesc *queryDesc);
static void RAODB_ProcessUtility_hook(PlannedStmt *pstmt, const char *queryString, bool readOnlyTree, ProcessUtilityContext context, ParamListInfo params, QueryEnvironment *queryEnv, DestReceiver *dest, QueryCompletion *qc);
//static void RAODB_func_setup
//static void RAODB_func_beg
//static void RAODB_func_end
//static void RAODB_stmt_beg
//static void RAODB_stmt_end

// ################################################################################
// Extension initialize
// ################################################################################
void 
_PG_init(void)
{
	// Ensure hook lib loaded
	//if (!process_shared_preload_libraries_in_progress) return;
	if (!process_shared_preload_libraries_in_progress) 
		 ereport(ERROR, (errcode(ERRCODE_OBJECT_NOT_IN_PREREQUISITE_STATE),
                errmsg("raohook must be loaded via shared_preload_libraries")));

	// define custom GUC variables
   DefineCustomBoolVariable(
		"raohook.trace_login",
		"whether login hooks are traced by raohook.",//short_desc
		"raohook.trace_login=true|false." ,				//long_desc
		&v_raohook_trace_login,	//valueAddr
		true,								//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

   DefineCustomBoolVariable(
		"raohook.trace_parser",
		"whether parser hooks are traced by raohook.",//short_desc
		"raohook.trace_parser=true|false." ,				//long_desc
		&v_raohook_trace_parser,	//valueAddr
		true,								//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

   DefineCustomBoolVariable(
		"raohook.trace_planner",
		"whether planner hooks are traced by raohook.",//short_desc
		"raohook.trace_planner=true|false." ,				//long_desc
		&v_raohook_trace_planner,	//valueAddr
		true,								//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

   DefineCustomBoolVariable(
		"raohook.trace_explainer",
		"whether explainer hooks are traced by raohook.",//short_desc
		"raohook.trace_explainer=true|false." ,				//long_desc
		&v_raohook_trace_explainer,	//valueAddr
		true,								//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

   DefineCustomBoolVariable(
		"raohook.trace_executor",
		"whether executor hooks are traced by raohook.",//short_desc
		"raohook.trace_executor=true|false." ,				//long_desc
		&v_raohook_trace_executor,	//valueAddr
		true,								//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

	DefineCustomIntVariable(
		"raohook.trace_level=1",	//name
		"trace_level 1 to 5. ", 	// short_desc
		"defaults to 1. 1=simple 5=detailed", 			//long_desc
		&v_raohook_trace_level, 	//valueAddr
		1,									//bootValue
		1,									//minValue
		5,									//maxValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

	DefineCustomStringVariable(
		"raohook.trace_prefix",		//name
		"trace prefix string",		//short_desc
		"trace prefix string",		//long_desc
		&v_raohook_trace_prefix,	//valueAddr
		"raohook", 						//bootValue
		PGC_SUSET,						//context
		0,									//flags
		NULL,								//check_hook
		NULL,								//assign_hook
		NULL								//show_hook
		);

	/*
	DefineCustomRealVariable(const char *name,
		const char *short_desc,
                   const char *long_desc,
                   double *valueAddr,
                   double bootValue,
                   double minValue,
                   double maxValue,
                   GucContext context,
                   int flags,
                   GucRealCheckHook check_hook,
                   GucRealAssignHook assign_hook,
                   GucShowHook show_hook)
	*/


	MarkGUCPrefixReserved("raohook.");

	// logging hooks
	prev_emit_log_hook=emit_log_hook;
	emit_log_hook=RAODB_emit_log_hook;

	// memory: request for extending memory
	//prev_shmem_request_hook=shmem_request_hook;
	//shmem_request_hook=RAODB_shmem_request_hook;

	// memory: hook for extensions to initialize their shared memory
	//prev_shmem_startup_hook=shmem_startup_hook;
	//shmem_startup_hook=RAODB_shmem_startup_hook;

	// memory: hook for extensions to terminate their shared memory
	//prev_shmem_shutdown_hook=shmem_shutdown_hook;
	//shmem_shutdown_hook=RAODB_shmem_shutdown_hook;

	// security: hook for enforcing password constraints and performing action on password change
	//prev_check_password_hook=check_password_hook;
	//check_password_hook=RAODB_check_password_hook;

	// security: hook for controlling the authentication process
	//prev_ClientAuthentication_hook=ClientAuthentication_hook;
	//ClientAuthentication_hook=RAODB_ClientAuthentication_hook;

	// security: hook for adding additional security checks on the per-relation level
	//prev_ExecutorCheckPerms_hook=ExecutorCheckPerms_hook;
	//ExecutorCheckPerms_hook=RAODB_ExecutorCheckPerms_hook;

	// security: hook to monitor accesses to objects
	//prev_object_access_hook=object_access_hook;
	//object_access_hook=RAODB_object_access_hook;

	// security: hook to add policies which are combined with the other permissive policies
	//prev_row_security_policy_hook_permissive=row_security_policy_hook_permissive;
	//row_security_policy_hook_permissive=RAODB_row_security_policy_hook_permissive;

	// security: hook to add policies which are enforced, regardless of other policies
	//prev_row_security_policy_hook_restrictive=row_security_policy_hook_restrictive;
	//row_security_policy_hook_restrictive=RAODB_row_security_policy_hook_restrictive;

	// function manager: auxiliary hook which decides whether fmgr_hook should be applied to a function
	//prev_needs_fmgr_hook=needs_fmgr_hook;
	//needs_fmgr_hook=RAODB_needs_fmgr_hook;

	// function manager: hook for controlling function execution process
	//prev_fmgr_hook=fmgr_hook;
	//fmgr_hook=RAODB_fmgr_hook;

	// planner: hook for altering index names in explain statements
	//prev_explain_get_index_name_hook=explain_get_index_name_hook;
	//explain_get_index_name_hook=RAODB_explain_get_index_name_hook;

	// planner: hook for overriding explain procedure for a single query
	//prev_ExplainOneQuery_hook=ExplainOneQuery_hook;
	//ExplainOneQuery_hook=RAODB_ExplainOneQuery_hook;

	// planner: hook for controlling an algorithm for predicting the average width of entries in the column
	//prev_get_attavgwidth_hook=get_attavgwidth_hook;
	//get_attavgwidth_hook=RAODB_get_attavgwidth_hook;

	// planner: hook for overriding index stats lookup
	//prev_get_index_stats_hook=get_index_stats_hook;
	//get_index_stats_hook=RAODB_get_index_stats_hook;

	// planner: hook for altering results of the relation info lookup
	//prev_get_relation_info_hook=get_relation_info_hook;
	//get_relation_info_hook=RAODB_get_relation_info_hook;

	// planner: hook for overriding relation stats lookup
	//prev_get_relation_stats_hook=get_relation_stats_hook;
	//get_relation_stats_hook=RAODB_get_relation_stats_hook;

	// planner: called in query optimizer entry point
	//prev_planner_hook=planner_hook;
	//planner_hook=RAODB_planner_hook;

	// planner: called when optimiser chooses order for join relations
	//prev_join_search_hook=join_search_hook;
	//join_search_hook=RAODB_join_search_hook;

	// planner: called at the end of building access paths for a base relation
	//prev_set_rel_pathlist_hook=set_rel_pathlist_hook;
	//set_rel_pathlist_hook=RAODB_set_rel_pathlist_hook;

	// planner: called at the end of the process of joinrel modification to contain the best paths
	//prev_set_join_pathlist_hook=set_join_pathlist_hook;
	//set_join_pathlist_hook=RAODB_set_join_pathlist_hook;

	// planner: called when postprocess of the path of set operations occurs
	//prev_create_upper_paths_hook=create_upper_paths_hook;
	//create_upper_paths_hook=RAODB_create_upper_paths_hook;

	// planner: called when parse analyze goes, right after performing transformTopLevelStmt()
	//prev_post_parse_analyze_hook=post_parse_analyze_hook;
	//post_parse_analyze_hook=RAODB_post_parse_analyze_hook;

	// executor: called at the beginning of any execution of any query plan
	prev_ExecutorStart_hook=ExecutorStart_hook;
	ExecutorStart_hook=RAODB_ExecutorStart_hook;

	// executor: called at any plan execution, after ExecutorStart
	prev_ExecutorRun_hook=ExecutorRun_hook;
	ExecutorRun_hook=RAODB_ExecutorRun_hook;

	// executor: called after the last ExecutorRun call
	prev_ExecutorFinish_hook=ExecutorFinish_hook;
	ExecutorFinish_hook=RAODB_ExecutorFinish_hook;

	// executor: called at the end of execution of any query plan
	prev_ExecutorEnd_hook=ExecutorEnd_hook;
	ExecutorEnd_hook=RAODB_ExecutorEnd_hook;

	// executor: hook for the ProcessUtility
	prev_ProcessUtility_hook=ProcessUtility_hook;
	ProcessUtility_hook=RAODB_ProcessUtility_hook;

	// plpgsql: hook for intercepting PLpgSQL function pre-init phase
	//prev_func_setup=func_setup;
	//func_setup=RAODB_func_setup;

	// plpgsql: hook for intercepting post-init phase
	//prev_func_beg=func_beg;
	//func_beg=RAODB_func_beg;

	// plpgsql: hook for intercepting end of a function
	//prev_func_end=func_end;
	//func_end=RAODB_func_end;

	// plpgsql: called before each statement of a function
	//prev_stmt_beg=stmt_beg;
	//stmt_beg=RAODB_stmt_beg;

	// plpgsql: called after each statement of a function
	//prev_stmt_end=stmt_end;
	//stmt_end=RAODB_stmt_end;
}
// ################################################################################
// Extension finish
// ################################################################################
void _PG_fini(void)
{
	if (emit_log_hook == RAODB_emit_log_hook) emit_log_hook = prev_emit_log_hook;

	//if (shmem_request_hook == RAODB_shmem_request_hook) shmem_request_hook = prev_shmem_request_hook;
	//if (shmem_startup_hook == RAODB_shmem_startup_hook) shmem_startup_hook = prev_shmem_startup_hook;
	//if (shmem_shutdown_hook == RAODB_shmem_shutdown_hook) shmem_shutdown_hook = prev_shmem_shutdown_hook;
	//if (check_password_hook == RAODB_check_password_hook) check_password_hook = prev_check_password_hook;
	//if (ClientAuthentication_hook == RAODB_ClientAuthentication_hook) ClientAuthentication_hook = prev_ClientAuthentication_hook;
	//if (ExecutorCheckPerms_hook == RAODB_ExecutorCheckPerms_hook) ExecutorCheckPerms_hook = prev_ExecutorCheckPerms_hook;
	//if (object_access_hook == RAODB_object_access_hook) object_access_hook = prev_object_access_hook;
	//if (row_security_policy_hook_permissive == RAODB_row_security_policy_hook_permissive) row_security_policy_hook_permissive = prev_row_security_policy_hook_permissive;
	//if (row_security_policy_hook_restrictive == RAODB_row_security_policy_hook_restrictive) row_security_policy_hook_restrictive = prev_row_security_policy_hook_restrictive;
	//if (needs_fmgr_hook == RAODB_needs_fmgr_hook) needs_fmgr_hook = prev_needs_fmgr_hook;
	//if (fmgr_hook == RAODB_fmgr_hook) fmgr_hook = prev_fmgr_hook;
	//if (ExplainOneQuery_hook == RAODB_ExplainOneQuery_hook) ExplainOneQuery_hook = prev_ExplainOneQuery_hook;
	//if (get_attavgwidth_hook == RAODB_get_attavgwidth_hook) get_attavgwidth_hook = prev_get_attavgwidth_hook;
	//if (get_index_stats_hook == RAODB_get_index_stats_hook) get_index_stats_hook = prev_get_index_stats_hook;
	//if (get_relation_info_hook == RAODB_get_relation_info_hook) get_relation_info_hook = prev_get_relation_info_hook;
	//if (get_relation_stats_hook == RAODB_get_relation_stats_hook) get_relation_stats_hook = prev_get_relation_stats_hook;
	//if (planner_hook == RAODB_planner_hook) planner_hook = prev_planner_hook;
	//if (join_search_hook == RAODB_join_search_hook) join_search_hook = prev_join_search_hook;
	//if (set_rel_pathlist_hook == RAODB_set_rel_pathlist_hook) set_rel_pathlist_hook = prev_set_rel_pathlist_hook;
	//if (set_join_pathlist_hook == RAODB_set_join_pathlist_hook) set_join_pathlist_hook = prev_set_join_pathlist_hook;
	//if (create_upper_paths_hook == RAODB_create_upper_paths_hook) create_upper_paths_hook = prev_create_upper_paths_hook;
	//if (post_parse_analyze_hook == RAODB_post_parse_analyze_hook) post_parse_analyze_hook = prev_post_parse_analyze_hook;
	if (ExecutorStart_hook == RAODB_ExecutorStart_hook) ExecutorStart_hook = prev_ExecutorStart_hook;
	if (ExecutorRun_hook == RAODB_ExecutorRun_hook) ExecutorRun_hook = prev_ExecutorRun_hook;
	if (ExecutorFinish_hook == RAODB_ExecutorFinish_hook) ExecutorFinish_hook = prev_ExecutorFinish_hook;
	if (ExecutorEnd_hook == RAODB_ExecutorEnd_hook) ExecutorEnd_hook = prev_ExecutorEnd_hook;
	if (ProcessUtility_hook == RAODB_ProcessUtility_hook) ProcessUtility_hook = prev_ProcessUtility_hook;
	//if (func_setup == RAODB_func_setup) func_setup = prev_func_setup;
	//if (func_beg == RAODB_func_beg) func_beg = prev_func_beg;
	//if (func_end == RAODB_func_end) func_end = prev_func_end;
	//if (stmt_beg == RAODB_stmt_beg) stmt_beg = prev_stmt_beg;
	//if (stmt_end == RAODB_stmt_end) stmt_end = prev_stmt_end;

}
// ################################################################################
static void
RAODB_emit_log_hook(ErrorData *edata)
{
	static bool in_hook = false;
	FILE           *file;
	MemoryContext  oldcontext;
	StringInfoData buf; 

	if (prev_emit_log_hook) prev_emit_log_hook(edata);
	elog(LOG, "RAODB_emit_log_hook:" );

  // Protect from recursive calls
	if (! in_hook) { 
		in_hook = true; 

	
		if (!edata->output_to_server) return;
		oldcontext = MemoryContextSwitchTo(ErrorContext);
		initStringInfo(&buf);
		appendStringInfoString(&buf, "level=");
		appendStringInfoString(&buf, error_severity(edata->elevel));
/*
		if (MyProcPort) {
			if (MyProcPort->database_name) {
				appendStringInfoString(&buf, " database=");
				appendStringInfoString(&buf, MyProcPort->database_name);
			}
		}
*/
	
		if (edata->message) {
			appendStringInfoString(&buf, " message=");
			appendStringInfoString(&buf, edata->message);
		}
		appendStringInfoString(&buf, "\n");
	
		file = AllocateFile("postgresql.logfmt", "a");
		fwrite(buf.data, 1, strlen(buf.data), file);
		FreeFile(file);
	
		MemoryContextSwitchTo(oldcontext);
		in_hook = false; 
	}
}
/*
// ================================================================================
static void
RAODB_shmem_request_hook(void)
{
	if (prev_shmem_request_hook) prev_shmem_request_hook();
	elog(LOG, "RAODB_shmem_request_hook:" );
}
// ================================================================================
static void
RAODB_shmem_startup_hook(void)
{
	if (prev_shmem_startup_hook) prev_shmem_startup_hook();
	elog(LOG, "RAODB_shmem_startup_hook:" );
}
// ================================================================================
static void
RAODB_shmem_shutdown_hook(int code, Datum arg)
{
	if (prev_shmem_shutdown_hook) prev_shmem_shutdown_hook();
	elog(LOG, "RAODB_shmem_shutdown_hook:" );
}
// ================================================================================
static void
RAODB_check_password_hook(void)
{
	if (prev_check_password_hook) prev_check_password_hook();
	elog(LOG, "RAODB_check_password_hook:" );
}
// ================================================================================
static void
RAODB_ClientAuthentication_hook(void)
{
	if (prev_ClientAuthentication_hook) prev_ClientAuthentication_hook();
	elog(LOG, "RAODB_ClientAuthentication_hook:" );
}
// ================================================================================
static void
RAODB_ExecutorCheckPerms_hook(void)
{
	if (prev_ExecutorCheckPerms_hook) prev_ExecutorCheckPerms_hook();
	elog(LOG, "RAODB_ExecutorCheckPerms_hook:" );
}
// ================================================================================
static void
RAODB_object_access_hook(void)
{
	if (prev_object_access_hook) prev_object_access_hook();
	elog(LOG, "RAODB_object_access_hook:" );
}
// ================================================================================
static void
RAODB_row_security_policy_hook_permissive(void)
{
	if (prev_row_security_policy_hook_permissive) prev_row_security_policy_hook_permissive();
	elog(LOG, "RAODB_row_security_policy_hook_permissive:" );
}
// ================================================================================
static void
RAODB_row_security_policy_hook_restrictive(void)
{
	if (prev_row_security_policy_hook_restrictive) prev_row_security_policy_hook_restrictive();
	elog(LOG, "RAODB_row_security_policy_hook_restrictive:" );
}
// ================================================================================
static void
RAODB_needs_fmgr_hook(void)
{
	if (prev_needs_fmgr_hook) prev_needs_fmgr_hook();
	elog(LOG, "RAODB_needs_fmgr_hook:" );
}
// ================================================================================
static void
RAODB_fmgr_hook(void)
{
	if (prev_fmgr_hook) prev_fmgr_hook();
	elog(LOG, "RAODB_fmgr_hook:" );
}
// ================================================================================
static void
RAODB_ExplainOneQuery_hook(void)
{
	if (prev_ExplainOneQuery_hook) prev_ExplainOneQuery_hook();
	elog(LOG, "RAODB_ExplainOneQuery_hook:" );
}
// ================================================================================
static void
RAODB_get_attavgwidth_hook(void)
{
	if (prev_get_attavgwidth_hook) prev_get_attavgwidth_hook();
	elog(LOG, "RAODB_get_attavgwidth_hook:" );
}
// ================================================================================
static void
RAODB_get_index_stats_hook(void)
{
	if (prev_get_index_stats_hook) prev_get_index_stats_hook();
	elog(LOG, "RAODB_get_index_stats_hook:" );
}
// ================================================================================
static void
RAODB_get_relation_info_hook(void)
{
	if (prev_get_relation_info_hook) prev_get_relation_info_hook();
	elog(LOG, "RAODB_get_relation_info_hook:" );
}
// ================================================================================
static void
RAODB_get_relation_stats_hook(void)
{
	if (prev_get_relation_stats_hook) prev_get_relation_stats_hook();
	elog(LOG, "RAODB_get_relation_stats_hook:" );
}
// ================================================================================
static PlannedStmt
*RAODB_planner_hook(Query *parse, const char *query_string, int cursorOptions, ParamListInfo boundParams)
{
	if (prev_planner_hook) prev_planner_hook();
	elog(LOG, "RAODB_planner_hook:" );
}
// ================================================================================
static void
RAODB_join_search_hook(void)
{
	if (prev_join_search_hook) prev_join_search_hook();
	elog(LOG, "RAODB_join_search_hook:" );
}
// ================================================================================
static void
RAODB_set_rel_pathlist_hook(void)
{
	if (prev_set_rel_pathlist_hook) prev_set_rel_pathlist_hook();
	elog(LOG, "RAODB_set_rel_pathlist_hook:" );
}
// ================================================================================
static void
RAODB_set_join_pathlist_hook(void)
{
	if (prev_set_join_pathlist_hook) prev_set_join_pathlist_hook();
	elog(LOG, "RAODB_set_join_pathlist_hook:" );
}
// ================================================================================
static void
RAODB_create_upper_paths_hook(void)
{
	if (prev_create_upper_paths_hook) prev_create_upper_paths_hook();
	elog(LOG, "RAODB_create_upper_paths_hook:" );
}
// ================================================================================
static void
RAODB_post_parse_analyze_hook(ParseState *pstate, Query *query, JumbleState *jstate)
{
	if (prev_post_parse_analyze_hook) prev_post_parse_analyze_hook();
	elog(LOG, "RAODB_post_parse_analyze_hook:" );
}
*/
// ================================================================================
static void
RAODB_ExecutorStart_hook(QueryDesc *queryDesc, int eflags)
{
	//if (v_raohook_trace_executor) 
	elog(LOG, "RAODB_ExecutorStart_hook: %d (%s)", 
		MyProcPid, IsBackgroundWorker ? "worker" : "leader");

	if (prev_ExecutorStart_hook) 
		prev_ExecutorStart_hook(queryDesc, eflags);
	else
		standard_ExecutorStart(queryDesc, eflags);
}
// ================================================================================

static void
RAODB_ExecutorRun_hook(QueryDesc *queryDesc, ScanDirection direction, uint64 count, bool execute_once)
{
	elog(LOG, "**hook_executor** Run %d (%s)",
		MyProcPid, IsBackgroundWorker ? "worker" : "leader");

	if (prev_ExecutorRun_hook)
		prev_ExecutorRun_hook(queryDesc, direction, count, execute_once);
	else
		standard_ExecutorRun(queryDesc, direction, count, execute_once);
}
// ================================================================================
static void
RAODB_ExecutorFinish_hook(QueryDesc *queryDesc)
{
	elog(LOG, "RAODB_ExecutorFinish_hook: %d (%s)",
		MyProcPid, IsBackgroundWorker ? "worker" : "leader");

	if (prev_ExecutorFinish_hook)
		prev_ExecutorFinish_hook(queryDesc);
	else
		standard_ExecutorFinish(queryDesc);
}
// ================================================================================
static void
RAODB_ExecutorEnd_hook(QueryDesc *queryDesc)
{
    elog(LOG, "RAODB_ExecutorEnd_hook: %d (%s)",
		MyProcPid, IsBackgroundWorker ? "worker" : "leader");

	if (prev_ExecutorEnd_hook)
		prev_ExecutorEnd_hook(queryDesc);
	else
		standard_ExecutorEnd(queryDesc);
}
// ================================================================================
static void
RAODB_ProcessUtility_hook(PlannedStmt *pstmt, const char *queryString, bool readOnlyTree, ProcessUtilityContext context, ParamListInfo params, QueryEnvironment *queryEnv, DestReceiver *dest, QueryCompletion *qc)
{
    elog(LOG, "RAODB_ProcessUtility_hook: %d (%s)",
		MyProcPid, IsBackgroundWorker ? "worker" : "leader");

	if (prev_ProcessUtility_hook)
		prev_ProcessUtility_hook(pstmt, queryString, readOnlyTree, context, params, queryEnv, dest, qc);
	else
		standard_ProcessUtility(pstmt, queryString, readOnlyTree, context, params, queryEnv, dest, qc);
}
// ================================================================================
/*
static void
RAODB_func_setup(void)
{
	if (prev_func_setup) prev_func_setup();
	elog(LOG, "RAODB_func_setup:" );
}
// ================================================================================
static void
RAODB_func_beg(void)
{
	if (prev_func_beg) prev_func_beg();
	elog(LOG, "RAODB_func_beg:" );
}
// ================================================================================
static void
RAODB_func_end(void)
{
	if (prev_func_end) prev_func_end();
	elog(LOG, "RAODB_func_end:" );
}
// ================================================================================
static void
RAODB_stmt_beg(void)
{
	if (prev_stmt_beg) prev_stmt_beg();
	elog(LOG, "RAODB_stmt_beg:" );
}
// ================================================================================
static void
RAODB_stmt_end(void)
{
	if (prev_stmt_end) prev_stmt_end();
	elog(LOG, "RAODB_stmt_end:" );
}
*/
// ################################################################################

