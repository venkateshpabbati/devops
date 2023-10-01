-- ================================================================================
-- range
drop table if exists pt_range;
create table pt_range (id int, name varchar(30)) partition by range(id);
create table pt_range_p1 partition of pt_range for values from (minvalue) to (1000);
create table pt_range_p2 partition of pt_range for values from (1000) to (2000);
create table pt_range_p3 partition of pt_range for values from (2000) to (maxvalue);
-- ================================================================================
