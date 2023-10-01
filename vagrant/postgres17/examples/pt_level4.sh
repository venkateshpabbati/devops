# ################################################################################

# Generate SQL script to create 
#
# ./pt_level4.sh > pt_level4.sql
# ################################################################################
echo "\set ECHO none"

v_table="pt_multi4"

echo "drop table if exists ${v_table};"

echo "create table ${v_table} (region char(1), yyyy char(4), mm char(2),  id int, amt numeric(10,2)) partition by list(region);"

for v_region in E W N S
do
echo "create table ${v_table}_${v_region} partition of ${v_table} for values in ('${v_region}') partition by list (yyyy);"
for v_yyyy in $(seq 2001 2025)
do
echo "create table ${v_table}_${v_region}_${v_yyyy} partition of ${v_table}_${v_region} for values in (${v_yyyy}::char(4)) partition by list (mm);"
for v_mm in 01 02 03 04 05 06 07 08 09 10 11 12
do
echo "create table ${v_table}_${v_region}_${v_yyyy}_${v_mm} partition of ${v_table}_${v_region}_${v_yyyy} for values in (${v_mm}::char(2)) partition by hash (id);"
for v_id in 0 1 2 3
do
echo "create table ${v_table}_${v_region}_${v_yyyy}_${v_mm}_${v_id} partition of ${v_table}_${v_region}_${v_yyyy}_${v_mm} for values with (modulus 4, remainder ${v_id});"
done
done
done
done



