-- ================================================================================
DROP VIEW if exists rao_tablespace;
CREATE OR REPLACE VIEW rao_tablespace AS
SELECT 
	spcname as tablespace_name
	,pg_catalog.pg_get_userbyid(spcowner) as owner
	,pg_catalog.pg_tablespace_location(oid) as location
FROM 
	pg_catalog.pg_tablespace
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_database;
CREATE OR REPLACE VIEW rao_database AS
SELECT 
	pg_database.datname as db_name
	,pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
FROM 
	pg_database;
-- ================================================================================
DROP VIEW if exists rao_schema;
CREATE OR REPLACE VIEW rao_schema AS
SELECT 
	nspname as schema
	,nspowner as owner
	,nspacl as acl
FROM
	pg_catalog.pg_namespace
ORDER BY nspname;
-- ================================================================================
DROP VIEW if exists rao_role;
CREATE OR REPLACE VIEW rao_role AS
SELECT 
	r.rolname as role_name
	,r.rolsuper as super_user
	,r.rolinherit as inherited
	,r.rolvaliduntil as valid_until
FROM
	pg_catalog.pg_roles r
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_extension;
CREATE OR REPLACE VIEW rao_extension AS
SELECT
	e.extname as name
	,e.extversion as version
	,n.nspname as schema
	,c.description as description
FROM 
	pg_catalog.pg_extension e
	LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace                                                              
	LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid
		AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_fdw;
CREATE OR REPLACE VIEW rao_fdw AS
SELECT 
	fdw.fdwname as name
	,pg_catalog.pg_get_userbyid(fdw.fdwowner) as owner
	,fdw.fdwhandler::pg_catalog.regproc as handler
	,fdw.fdwvalidator::pg_catalog.regproc as validator
	,(CASE WHEN fdwoptions IS NULL THEN '' 
	  ELSE '(' || pg_catalog.array_to_string(ARRAY(SELECT 
			pg_catalog.quote_ident(option_name) ||  ' ' || 
            pg_catalog.quote_literal(option_value)  
			FROM pg_catalog.pg_options_to_table(fdwoptions)),  ', ') || ')' 
      END) as fdw_options
	,d.description as description
FROM 
	pg_catalog.pg_foreign_data_wrapper fdw
	LEFT JOIN pg_catalog.pg_description d ON d.classoid = fdw.tableoid AND d.objoid = fdw.oid AND d.objsubid = 0
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_event_trigger;
CREATE OR REPLACE VIEW rao_event_trigger AS
SELECT 
	evtname as name
	,evtevent as event
	,pg_catalog.pg_get_userbyid(e.evtowner) as owner
	,(case evtenabled 
		when 'O' then 'enabled'
		when 'R' then 'replica'
	  	when 'A' then 'always'
	  	when 'D' then 'disabled' 
	  end) as status
	,e.evtfoid::pg_catalog.regproc as function
	,pg_catalog.array_to_string(array(select x from pg_catalog.unnest(evttags) as t(x)), ', ') as tags
	,pg_catalog.obj_description(e.oid, 'pg_event_trigger') as description
FROM 
	pg_catalog.pg_event_trigger e
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_language;
CREATE OR REPLACE VIEW rao_language AS
SELECT 
	l.lanname as name
	,pg_catalog.pg_get_userbyid(l.lanowner) as owner
	,l.lanpltrusted as trusted
	,NOT l.lanispl as internal
	,d.description as description
	/*
	,l.lanplcallfoid::pg_catalog.regprocedure as call_handler
	,l.lanvalidator::pg_catalog.regprocedure as validator
	,l.laninline::pg_catalog.regprocedure as inline_hanlder
	,l.lanacl as acl
	*/
FROM 
	pg_catalog.pg_language l
	LEFT JOIN pg_catalog.pg_description d ON d.classoid = l.tableoid AND d.objoid = l.oid
	AND d.objsubid = 0
WHERE l.lanplcallfoid != 0
ORDER BY 1;
-- ================================================================================
DROP VIEW if exists rao_routine;
CREATE OR REPLACE VIEW rao_routine AS
SELECT
	n.nspname as schema
	,p.proname as name
	,pg_catalog.pg_get_function_result(p.oid) as result_data_type
	--,pg_catalog.pg_get_function_arguments(p.oid) as argument_data_types
    ,(CASE p.prokind
		WHEN 'a' THEN 'agg' 
		WHEN 'w' THEN 'window'
		WHEN 'p' THEN 'proc'
		ELSE 'func'
		END
	 ) as func_type
	,(CASE
		WHEN p.provolatile = 'i' THEN 'immutable'
		WHEN p.provolatile = 's' THEN 'stable'
		WHEN p.provolatile = 'v' THEN 'volatile'
		END
	 ) as Volatility
	,(CASE
		WHEN p.proparallel = 'r' THEN 'restricted'
		WHEN p.proparallel = 's' THEN 'safe'
		WHEN p.proparallel = 'u' THEN 'unsafe'
		END
	 ) as Parallel
	,pg_catalog.pg_get_userbyid(p.proowner) as owner
	,(CASE WHEN prosecdef THEN 'definer' ELSE 'invoker' END) as Security
	,p.proacl as acl
	,l.lanname as Language
	,(CASE WHEN l.lanname IN ('internal', 'c') THEN p.prosrc END) as Internal_Name
	,pg_catalog.obj_description(p.oid, 'pg_proc') as Description
FROM 
	pg_catalog.pg_proc p
	LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
	LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
ORDER BY 1,2;
-- ================================================================================
DROP VIEW if exists rao_table;
CREATE OR REPLACE VIEW rao_table AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_index;
CREATE OR REPLACE VIEW rao_index AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_view;
CREATE OR REPLACE VIEW rao_view AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_mview;
CREATE OR REPLACE VIEW rao_mview AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_sequence;
CREATE OR REPLACE VIEW rao_sequence AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_type;
CREATE OR REPLACE VIEW rao_type AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_domain;
CREATE OR REPLACE VIEW rao_domain AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_xxx;
CREATE OR REPLACE VIEW rao_xxx AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_xxx;
CREATE OR REPLACE VIEW rao_xxx AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_xxx;
CREATE OR REPLACE VIEW rao_xxx AS
SELECT false;
-- ================================================================================
DROP VIEW if exists rao_xxx;
CREATE OR REPLACE VIEW rao_xxx AS
SELECT false;



-- ================================================================================
DROP VIEW if exists rao_part_tables;
CREATE OR REPLACE VIEW rao_part_tables AS
WITH part_tables as (
SELECT
  p.partrelid
  ,pg_catalog.pg_get_userbyid(c.relowner) as owner
  ,c.relnamespace::regnamespace::text as schema
  ,c.relname as table_name
  ,partnatts as num_cols 
  ,(case partstrat when 'l' then 'list' when 'r' then 'range' when 'h' then 'hash' end) as part_type
  ,pg_catalog.pg_get_partkeydef(c.oid) as part_key
FROM 
	pg_partitioned_table p
	JOIN pg_catalog.pg_class c ON c.oid = p.partrelid
)
SELECT pt.owner, pt.schema, pt.table_name, pt.num_cols, pt.part_type, COUNT(i.*) as part_count, pt.part_key
FROM part_tables as pt
	 FULL OUTER JOIN pg_inherits i ON i.inhparent = pt.partrelid
GROUP BY pt.owner, pt.schema, pt.table_name, pt.num_cols, pt.part_type, pt.part_key;
-- ================================================================================
/*
tabparts - owner, table_name, part_type,part_name, 
tabpartcols - owner, table_name, part_name, part_columns
tabpartvals - owner, table_name, part_name, part_col_values
tabpartstats - owner, table_name, part_name, num_rows, etc.


*/
-- ================================================================================
/*

-- To show max databases connection allowed
SHOW max_connections;

-- To display actives connections
SELECT 
	COUNT(client_addr) 
FROM  
	pg_stat_activity;

-- To display the activity of your database
SELECT 
	* 
FROM
	pg_stat_activity 
WHERE 
	datname = 'your_database_name' 
ORDER BY 
	backend_start;

-- To display connections by client_addr
SELECT 
	client_addr,
	COUNT(client_addr) AS connecciones 
FROM 
	pg_stat_activity 
GROUP BY 
	client_addr 
ORDER BY 
	client_addr ASC;


-- To display usaged size of a specific table
SELECT 
	pg.relname AS "Tabla", 
	pg_size_pretty((relpages*8)::bigint*1024) 
AS "Tamaño estimado"
FROM 
	pg_class pg
WHERE 
	relname='your_table_name';

-- To display usaged size of tables by schemas
SELECT
	*,
	pg_size_pretty(total_bytes) AS total,
    pg_size_pretty(index_bytes) AS INDEX,
    pg_size_pretty(toast_bytes) AS toast,
    pg_size_pretty(table_bytes) AS TABLE
  FROM (
  	SELECT 
  		*, 
  		total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes 
  	FROM (
	      SELECT 
	      	c.oid,
	      	nspname AS table_schema, 
	      	relname AS TABLE_NAME, 
	      	c.reltuples AS row_estimate, 
	      	pg_total_relation_size(c.oid) AS total_bytes, 
	      	pg_indexes_size(c.oid) AS index_bytes, 
	      	pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM 
          	pg_class c
          	LEFT JOIN 
          		pg_namespace n ON n.oid = c.relnamespace
          WHERE 
          	relkind = 'r'
          ORDER BY 
          	table_name,
          	total_bytes ASC
      	) a
) a;
*/
