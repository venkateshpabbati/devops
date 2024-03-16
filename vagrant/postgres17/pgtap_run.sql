-- ######################################################################
-- pgtap_run.sql: Postgres automated unit testing 
-- ######################################################################
\pset border 0
\pset tuples_only on
\pset footer off

set search_path to "$user", public, postgres;

select concat('pg_version: ',pg_version());
select concat('os_name: ',os_name());
select concat('pgTAP version: ',pgtap_version());

select plan(38);

select has_schema ('schema1');
select has_user ('user1'::name);
select has_group ('group1'::name);
select has_role ('role1'::name);

select has_table ('public','table1'::name);
select has_pk ('table1');
select has_unique ('table1');
select has_check('table1');
--select has_fk('table1');

select has_column('table1'::name,'notes'::name);
select col_is_pk ('public'::name,'table1'::name,'id1'::name);
select col_not_null('public'::name,'table1'::name,'typ'::name);
select col_has_default('table1','amt');
select col_has_check('table1','amt');
select col_is_unique('public'::name,'table1'::name,'id2'::name);
select col_type_is('public'::name,'table1'::name,'dt'::name,'date');
select col_default_is('table1'::name,'amt'::name,'1.0');
--select col_is_fk('table1'::name,'typ'::name);

select is_indexed('public'::name,'table1'::name,'id2'::name);
select index_is_type('public'::name,'table1'::name,'index2_uk'::name,'btree');
select index_is_unique('public','table1','index2_uk');
select index_is_primary('public','table1','table1_pkey');
select has_index ('public'::name,'table1'::name,'index2_uk'::name,'id2'::name);

select has_view ('public','view1'::name);
select has_materialized_view ('mview1');
select has_sequence ('public','sequence1'::name);
select has_type ('public','type1'::name);
select has_domain ('public','domain1'::name);
select has_enum ('public','enum1'::name);

select is_ancestor_of('public'::name,'table1'::name,'public'::name,'table2'::name);
select is_descendent_of('public'::name,'table2'::name,'public'::name,'table1'::name);
select has_extension('plpgsql');

/*
is_partitioned()
isnt_partitioned()
is_partition_of()
is_clustered()
has_foreign_table()
has_trigger()
*/

select has_function('public'::name,'function1'::name);
select is_definer('public'::name,'function2'::name);
select function_lang_is('public','function1','sql'::name);
select function_lang_is('public','function2','plpgsql'::name);
select function_returns('function1','bool'::text);
select isnt_strict('public'::name,'function1'::name);
select is_normal_function('public'::name,'function1'::name);
--select is_procedure('public'::name,'function1'::name);

select is_aggregate('sum');

/*
isnt_aggregate()
is_window()
isnt_window()
*/

select finish();
--
-- EOF
--
