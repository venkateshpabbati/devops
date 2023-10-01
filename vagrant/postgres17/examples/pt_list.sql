-- ================================================================================
-- list
drop table if exists pt_list;
create table pt_list (region char(1), id int) partition by list(region);
create table pt_list_p1 partition of pt_list for values in ('E');
create table pt_list_p2 partition of pt_list for values in ('W');
create table pt_list_p3 partition of pt_list for values in ('N');
create table pt_list_p4 partition of pt_list for values in ('S');
