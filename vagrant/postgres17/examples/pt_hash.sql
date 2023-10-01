-- ================================================================================
-- hash
drop table if exists pt_hash;
create table pt_hash (id int, name varchar(30)) partition by hash(id);
create table pt_hash_p1 partition of pt_hash for values with (modulus 4, remainder 0);
create table pt_hash_p2 partition of pt_hash for values with (modulus 4, remainder 1);
create table pt_hash_p3 partition of pt_hash for values with (modulus 4, remainder 2);
create table pt_hash_p4 partition of pt_hash for values with (modulus 4, remainder 3);
-- ================================================================================
