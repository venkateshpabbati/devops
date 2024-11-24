-- ######################################################################
-- pgtap_run.sql: Postgres automated unit testing 
-- ######################################################################
\pset border 0
\pset tuples_only on
\pset footer off

set search_path to "$user", public, postgres;

select 'TEST: SQL results data set validation';

select no_plan();
select '======================================================================';

SELECT results_eq(
	'SELECT id1 FROM public.table1 where id1<4', 
	ARRAY[1,2,3],
	 'Result from table table1 compare with constants'
	
);

SELECT results_eq(
	'SELECT id1 FROM public.table1 where id1<4', 
	'SELECT id1 FROM public.table1 where id2<14',
	 'Result from table table1 table1 using 2 diferent SQLs'
	);

SELECT results_eq(
	'SELECT id1,id2 FROM public.table1 where id1 in (1,5,10)',
	$$VALUES ( 1,11), (5,15), (10,20)$$,
	'Results from table table1 SQL compared with cursor of constants'
	);

SELECT isnt_empty( 'select * from public.table1','Table table1 should not be empty');
SELECT is_empty( 'select * from public.table3','Table table3 should be empty');


SELECT row_eq(
	$$ SELECT id1, id2 from public.table1 where id1=7$$,
	ROW(7,17),
	'Row data match for SQL output with Row values'
	);

SELECT set_has(
	'SELECT id1 FROM public.table1 where id1<4', 
	'SELECT id1 FROM public.table1 where id2<14
union all
	SELECT id1 FROM public.table1 where id2<14',
	 'Result from SQL1 has result from SQL2'
	);

select '======================================================================';
select finish();
--
-- EOF
--
