-- ######################################################################
-- pgtap_run.sql: Postgres automated unit testing 
-- ######################################################################
\pset border 0
\pset tuples_only on
\pset footer off

set search_path to "$user", public, postgres;

select 'TEST: Database pg_settings validation';

select no_plan();
select '======================================================================';
select is(s.setting,'on','Check pg_setting: autovacuum') from pg_settings s where name='autovacuum';
select is(s.setting,'on','Check pg_setting: enable_hashjoin') from pg_settings s where name='enable_hashjoin';
select is(s.setting,'on','Check pg_setting: enable_indexscan') from pg_settings s where name='enable_indexscan';
select is(s.setting,'on','Check pg_setting: enable_mergejoin') from pg_settings s where name='enable_mergejoin';
select is(s.setting,'on','Check pg_setting: enable_nestloop') from pg_settings s where name='enable_nestloop';
select is(s.setting,'on','Check pg_setting: enable_seqscan') from pg_settings s where name='enable_seqscan';
select is(s.setting,'on','Check pg_setting: enable_sort') from pg_settings s where name='enable_sort';
select is(s.setting,'on','Check pg_setting: fsync') from pg_settings s where name='fsync';
select is(s.setting,'on','Check pg_setting: data_checksums') from pg_settings s where name='data_checksums';
--select is(s.setting,'on','Check pg_setting: xxx') from pg_settings s where name='xxx';
select '======================================================================';
select finish();
--
-- EOF
--
