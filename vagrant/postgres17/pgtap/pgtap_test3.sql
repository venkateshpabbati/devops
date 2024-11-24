-- ######################################################################
-- pgtap_run.sql: Postgres automated unit testing 
-- ######################################################################
\pset border 0
\pset tuples_only on
\pset footer off

set search_path to "$user", public, postgres;

select 'TEST: Partitions validation';
select no_plan();
select '======================================================================';

SELECT is_partitioned('public'::name,'pt_range'::name);
SELECT is_partitioned('public'::name,'pt_list'::name);
SELECT is_partitioned('public'::name,'pt_hash'::name);

SELECT is_partition_of('public'::name,'pt_range_p1'::name,'public'::name,'pt_range');
SELECT is_partition_of('public'::name,'pt_range_p2'::name,'public'::name,'pt_range');
SELECT is_partition_of('public'::name,'pt_range_p3'::name,'public'::name,'pt_range');

SELECT is_partition_of('public'::name,'pt_list_p1'::name,'public'::name,'pt_list');
SELECT is_partition_of('public'::name,'pt_list_p2'::name,'public'::name,'pt_list');
SELECT is_partition_of('public'::name,'pt_list_p3'::name,'public'::name,'pt_list');
SELECT is_partition_of('public'::name,'pt_list_p4'::name,'public'::name,'pt_list');

SELECT is_partition_of('public'::name,'pt_hash_p1'::name,'public'::name,'pt_hash');
SELECT is_partition_of('public'::name,'pt_hash_p2'::name,'public'::name,'pt_hash');
SELECT is_partition_of('public'::name,'pt_hash_p3'::name,'public'::name,'pt_hash');
SELECT is_partition_of('public'::name,'pt_hash_p4'::name,'public'::name,'pt_hash');

SELECT partitions_are('public','pt_range',ARRAY['pt_range_p1','pt_range_p2','pt_range_p3']);
SELECT partitions_are('public','pt_list',ARRAY['pt_list_p1','pt_list_p2','pt_list_p3','pt_list_p4']);
SELECT partitions_are('public','pt_hash',ARRAY['pt_hash_p1','pt_hash_p2','pt_hash_p3','pt_hash_p4']);


select '======================================================================';
select finish();
--
-- EOF
--
