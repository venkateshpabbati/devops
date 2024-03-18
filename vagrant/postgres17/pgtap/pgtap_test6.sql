-- ######################################################################
-- pgtap_run.sql: Postgres automated unit testing 
-- ######################################################################
\pset border 0
\pset tuples_only on
\pset footer off

set search_path to "$user", public, postgres;

select 'TEST: Performance testing';

select plan(5);
select '======================================================================';

PREPARE query1 AS SELECT id1 FROM public.table1 WHERE id2 = id1+10;

PREPARE query2 AS SELECT count(1) 
FROM public.table1 a,public.table1 b, public.table1 c;

PREPARE query3 AS SELECT count(1) 
FROM public.table1 a,public.table1 b, public.table1 c, public.table1 d, public.table1 e;

SELECT performs_ok('query1',10, 'Query query1 shoudl run in less than 10ms');

SELECT performs_within( 'query1', 10, 20, 100,
    'Query query1 should run within 10ms  with a variation of 20ms after running 100 times'
);

SELECT performs_ok('query2',10, 'Query query2 shoudl run in less than 10ms');

SELECT performs_ok('query3',20, 'Query query3 shoudl run in less than 10ms');

SELECT performs_within( 'query3', 10, 5, 100,
    'Query query3 should run within 10ms  with a variation of 5ms after running 100 times'
);

select '======================================================================';
select finish();
--
-- EOF
--
