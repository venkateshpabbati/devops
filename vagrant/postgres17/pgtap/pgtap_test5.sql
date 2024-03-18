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

select 'TEST: Function unit testing with exceptions';

select plan(5);
select '======================================================================';

SELECT throws_ok('select function3(-1,10)','P0001','30001-p1<0');
SELECT throws_ok('select function3(1,-10)','P0001','30002-p2<0');
SELECT throws_ok('select function3(10,5)','P0001','30003-p1>p2');
SELECT lives_ok('select function3(5,10)','Function does not throw exception');

SELECT results_eq('SELECT function3(6,9)', ARRAY[4], 'Function returns excepected value');

select '======================================================================';
select finish();
--
-- EOF
--
