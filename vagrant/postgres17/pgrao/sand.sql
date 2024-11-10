-- -------------------------------------------------
bash pt_multi32.sh > pt_multi32.sql
psql -f  pt_multi32.sql
-- ================================================================================
--- multiple 32 levels of partitioning
-- -------------------------------------------------
bash pt_level32.sh > pt_level32.sql
psql -f pt_level32.sql
-- -------------------------------------------------
-- =============================================================
select * from rao_part_tables where table_name like 'pt_multi%';

select * from rao_part_tables order by table_name;

select * from pg_tables where tablename like 'pt_multi%'
	
