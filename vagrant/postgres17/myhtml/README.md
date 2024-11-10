# create table
psql -f tab.sql

# insert 2 sample report parameters
psql -f ins0.sql
psql -f ins1.sql

# create myhtml function
psql -f myhtml.sql 

vi call.sql ; rm -f /vagrant/rpt.tmp;rm -f /vagrant/rpt.html;psql -f call.sql -q -o /vagrant/rpt.tmp; psql -f /vagrant/rpt.tmp > /vagrant/rpt.html

