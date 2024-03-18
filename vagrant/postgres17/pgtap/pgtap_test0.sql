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

select 'TEST: Header';

select no_plan();
select '======================================================================';
select ok();
select '======================================================================';
select finish();
--
-- EOF
--
