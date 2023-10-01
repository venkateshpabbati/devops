-- ================================================================================
-- range with 3 columns
drop table if exists pt_3col;
create table pt_3col (yyyy char(4), mm char(2), dd char(2), region char(1), id int, amt numeric(10,2)) partition by range(yyyy,mm,dd);
-- ================================================================================
