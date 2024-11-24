--  ======================================================================
--  Test PLpgSQL procedure with exceptions
--  ======================================================================
create or replace procedure test_proc( num1 int, num2 int) as $$
DECLARE
    result INT;
BEGIN
IF num1<0 AND num2 <0 THEN RAISE EXCEPTION 'num1<0 and num2<0' using ERRCODE='20200'; END IF;
IF num1<0 THEN RAISE EXCEPTION 'num1<0' using ERRCODE='20201'; END IF;
IF num2<0 THEN RAISE EXCEPTION 'num2<0' using ERRCODE='20202'; END IF;

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
call test_proc(-5, -7);

\echo test2 -5 7
perform test_proc(-5, 7);

\echo test3 5 -7
perform test_proc(5, -7);

\echo test4 5 7
perform test_proc(5, 7);

--  ======================================================================
-- Test using pgTAP

select plan(5);

select function_lang_is('public','test_proc',ARRAY['int','int'],'plpgsql');

SELECT lives_ok( 'call test_proc(5,7)' );

SELECT throws_matching( 'call public.test_proc(-5,-7)', '20200' );

SELECT throws_matching( 'call public.test_proc(-5,7)', '20201' );

SELECT throws_matching( 'call public.test_proc(5,-7)', '20202' );

--  ======================================================================
