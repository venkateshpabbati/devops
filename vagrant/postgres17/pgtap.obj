-- ######################################################################
-- Postgres Test objects created to demo pgTAP
-- ######################################################################
create database database1;

create schema schema1;

create user user1;

create group group1;

create role role1;

create table table1(id1 integer primary key, id2 integer unique, 
typ char(3) not null,
amt numeric default '1.00' check (amt>0),
dt date default current_date,
notes varchar(100));

alter table table1 add constraint table1_pk primary key (id1);

create index index1_pk on table1(id1);

create unique index index2_uk on table1(id2);

create or replace view view1 as select * from table1;

create materialized view mview1 
as select id1, typ, sum(amt) as total_amt  from table1 group by id1, typ;

create sequence sequence1 ;

create type type1 as (id1 integer, id2 integer, typ char(3), amt numeric, dt date, notes varchar(1000));

create domain domain1 as type1 [];

create table table2 (country char(3) default 'USA') inherits (table1);

insert into table2 
select g.id, g.id+10, 'ABC', 10.00, current_date, substr(md5(random()::text), 0, 25)
from generate_series(1, 10) AS g (id);

create rule rule1 as on insert to table1 do instead (insert into table2 values(new.id1, new.id2, new.typ, new.amt, new.dt, new.notes));

create table table3 (id1 integer, amt numeric, action_dt date);

create rule rule2 as on update to table1 do also (insert into table3 values(new.id1, new.amt, current_date));

create type enum1 as enum ('AAA','BBB','CCC');

create extension if not exists plpgsql;

create function function1 (int) returns bool language 'sql' as 'select $1>0';

create function function2 (text) returns char language plpgsql security definer as
$$ declare begin return left($1,1); end; $$ ;

create procedure procedure1 () language plpgsql security definer as
$$ declare begin null; end; $$ ;

--create trigger trigger1 before delete or update on table1 for each row execute function mod(id1,2);

-- extended statistics
create statistics statistics1 on (left(notes,1)) from table1;

create collation collation1 from "C";

create conversion conversion1 FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;

create publication publication1 for all tables with (publish = 'insert, update, delete');

create subscription subscription1 connection 'dbname=database1' publication publication1 with (connect = false);

create aggregate aggregate1 (
   sfunc = int4_avg_accum, basetype = int4, stype = _int8,
   finalfunc = int8_avg,
   initcond1 = '{0,0}'
);  

--large object
select lo_create(10);
comment on large object 10 is 'this is large object 10';

/*

TRANSFORM
SERVER
USER MAPPING
EVENT TRIGGER 
FOREIGN DATA WRAPPER
LANGUAGE
POLICY
OPERATOR
OPERATOR CLASS
OPERATOR FAMILY

*/
