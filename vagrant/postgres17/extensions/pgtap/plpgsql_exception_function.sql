--  ======================================================================
--  Test PLpgSQL function with exceptions
--  ======================================================================
create or replace function test_func( num1 int, num2 int) returns int as $$
DECLARE
    result INT;
BEGIN
IF num1<0 AND num2 <0 THEN RAISE EXCEPTION 'num1<0 and num2<0' using ERRCODE='20200'; END IF;
IF num1<0 THEN RAISE EXCEPTION 'num1<0' using ERRCODE='20201'; END IF;
IF num2<0 THEN RAISE EXCEPTION 'num2<0' using ERRCODE='20202'; END IF;
result := num1 + num2;
RETURN result;

EXCEPTION
			when others then
			  case 
        when SQLSTATE = '20200' then raise exception '20200 num1 and num2 are -ve';
        when SQLSTATE = '20201' then raise exception '20201 num1 is -ve';
        when SQLSTATE = '20202' then raise exception '20202 num2 is -ve';
			  else raise exception 'unknown';
				END CASE;
END;
$$ LANGUAGE plpgsql;

--  ======================================================================
-- Test using psql

\echo test1 -5 -7
SELECT test_func(-5, -7);

\echo test2 -5 7
SELECT test_func(-5, 7);

\echo test3 5 -7
SELECT test_func(5, -7);

\echo test4 5 7
SELECT test_func(5, 7);


--  ======================================================================
-- Test using pgTAP

select plan(6);

select function_lang_is('public','test_func',ARRAY['int','int'],'plpgsql');
select function_returns('public','test_func',ARRAY['int','int'],'int');

PREPARE ex_ok AS select public.test_func(5,7);
SELECT lives_ok( 'select test_func(5,7)' );

PREPARE ex_20200 AS select public.test_func(-5,-7);
SELECT throws_matching( 'ex_20200', '20200' );

PREPARE ex_20201 AS select public.test_func(-5,7);
SELECT throws_matching( 'ex_20201', '20201' );

PREPARE ex_20202 AS select public.test_func(5,-7);
SELECT throws_matching( 'ex_20202', '20202' );

--  ======================================================================

