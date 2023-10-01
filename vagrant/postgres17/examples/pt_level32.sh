# ################################################################################
# Generate PostgreSQL script to create partitioned table with 32 levels deep
# ./pt_level32.sh > pt_level32.sql
# ################################################################################
i=0
ECHO () {
((i=i+1))
echo "--$i:\n $*"
}

echo "\set ECHO none"

v_table="pt32"

echo "drop table if exists ${v_table};"

ECHO "create table ${v_table} (
c01 numeric(1), 
c02 numeric(1), 
c03 numeric(1), 
c04 numeric(1), 
c05 numeric(1), 
c06 numeric(1), 
c07 numeric(1), 
c08 numeric(1), 
c09 numeric(1), 
c10 numeric(1), 
c11 numeric(1), 
c12 numeric(1), 
c13 numeric(1), 
c14 numeric(1), 
c15 numeric(1), 
c16 numeric(1), 
c17 numeric(1), 
c18 numeric(1), 
c19 numeric(1), 
c20 numeric(1), 
c21 numeric(1), 
c22 numeric(1), 
c23 numeric(1), 
c24 numeric(1), 
c25 numeric(1), 
c26 numeric(1), 
c27 numeric(1), 
c28 numeric(1), 
c29 numeric(1), 
c30 numeric(1), 
c31 numeric(1), 
c32 numeric(1),
amt numeric(4,2)) 
partition by list(c01);"

t01=${v_table}

for c02 in $(seq 1 1) ; do t02=${t01}${c02} ; ECHO "create table ${t02} partition of ${t01} for values in (${c02}) partition by list (c03);"
for c03 in $(seq 1 1) ; do t03=${t02}${c03} ; ECHO "create table ${t03} partition of ${t02} for values in (${c03}) partition by list (c04);"
for c04 in $(seq 1 1) ; do t04=${t03}${c04} ; ECHO "create table ${t04} partition of ${t03} for values in (${c04}) partition by list (c05);"
for c05 in $(seq 1 1) ; do t05=${t04}${c05} ; ECHO "create table ${t05} partition of ${t04} for values in (${c05}) partition by list (c06);"
for c06 in $(seq 1 1) ; do t06=${t05}${c06} ; ECHO "create table ${t06} partition of ${t05} for values in (${c06}) partition by list (c07);"
for c07 in $(seq 1 1) ; do t07=${t06}${c07} ; ECHO "create table ${t07} partition of ${t06} for values in (${c07}) partition by list (c08);"
for c08 in $(seq 1 1) ; do t08=${t07}${c08} ; ECHO "create table ${t08} partition of ${t07} for values in (${c08}) partition by list (c09);"
for c09 in $(seq 1 1) ; do t09=${t08}${c09} ; ECHO "create table ${t09} partition of ${t08} for values in (${c09}) partition by list (c10);"
for c10 in $(seq 1 1) ; do t10=${t09}${c10} ; ECHO "create table ${t10} partition of ${t09} for values in (${c10}) partition by list (c11);"
for c11 in $(seq 1 1) ; do t11=${t10}${c11} ; ECHO "create table ${t11} partition of ${t10} for values in (${c11}) partition by list (c12);"
for c12 in $(seq 1 1) ; do t12=${t11}${c12} ; ECHO "create table ${t12} partition of ${t11} for values in (${c12}) partition by list (c13);"
for c13 in $(seq 1 1) ; do t13=${t12}${c13} ; ECHO "create table ${t13} partition of ${t12} for values in (${c13}) partition by list (c14);"
for c14 in $(seq 1 1) ; do t14=${t13}${c14} ; ECHO "create table ${t14} partition of ${t13} for values in (${c14}) partition by list (c15);"
for c15 in $(seq 1 1) ; do t15=${t14}${c15} ; ECHO "create table ${t15} partition of ${t14} for values in (${c15}) partition by list (c16);"
for c16 in $(seq 1 1) ; do t16=${t15}${c16} ; ECHO "create table ${t16} partition of ${t15} for values in (${c16}) partition by list (c17);"
for c17 in $(seq 1 1) ; do t17=${t16}${c17} ; ECHO "create table ${t17} partition of ${t16} for values in (${c17}) partition by list (c18);"
for c18 in $(seq 1 1) ; do t18=${t17}${c18} ; ECHO "create table ${t18} partition of ${t17} for values in (${c18}) partition by list (c19);"
for c19 in $(seq 1 1) ; do t19=${t18}${c19} ; ECHO "create table ${t19} partition of ${t18} for values in (${c19}) partition by list (c20);"
for c20 in $(seq 1 1) ; do t20=${t19}${c20} ; ECHO "create table ${t20} partition of ${t19} for values in (${c20}) partition by list (c21);"
for c21 in $(seq 1 1) ; do t21=${t20}${c21} ; ECHO "create table ${t21} partition of ${t20} for values in (${c21}) partition by list (c22);"
for c22 in $(seq 1 1) ; do t22=${t21}${c22} ; ECHO "create table ${t22} partition of ${t21} for values in (${c22}) partition by list (c23);"
for c23 in $(seq 1 1) ; do t23=${t22}${c23} ; ECHO "create table ${t23} partition of ${t22} for values in (${c23}) partition by list (c24);"
for c24 in $(seq 1 1) ; do t24=${t23}${c24} ; ECHO "create table ${t24} partition of ${t23} for values in (${c24}) partition by list (c25);"
for c25 in $(seq 1 1) ; do t25=${t24}${c25} ; ECHO "create table ${t25} partition of ${t24} for values in (${c25}) partition by list (c26);"
for c26 in $(seq 1 1) ; do t26=${t25}${c26} ; ECHO "create table ${t26} partition of ${t25} for values in (${c26}) partition by list (c27);"
for c27 in $(seq 1 1) ; do t27=${t26}${c27} ; ECHO "create table ${t27} partition of ${t26} for values in (${c27}) partition by list (c28);"
for c28 in $(seq 1 1) ; do t28=${t27}${c28} ; ECHO "create table ${t28} partition of ${t27} for values in (${c28}) partition by list (c29);"
for c29 in $(seq 1 1) ; do t29=${t28}${c29} ; ECHO "create table ${t29} partition of ${t28} for values in (${c29}) partition by list (c30);"
for c30 in $(seq 1 1) ; do t30=${t29}${c30} ; ECHO "create table ${t30} partition of ${t29} for values in (${c30}) partition by list (c31);"
for c31 in $(seq 1 1) ; do t31=${t30}${c31} ; ECHO "create table ${t31} partition of ${t30} for values in (${c31}) partition by list (c32);"
for c32 in $(seq 1 1) ; do t32=${t31}${c32} ; ECHO "create table ${t32} partition of ${t31} for values in (${c32}) ;"
done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done
done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done ; done
