# ################################################################################
# Install pgTAP

cd GitHub/devops/vagrant/postgre17
vagrant up
vagrant ssh
vagrant scp pgtap.run :/tmp/pgtap.run
vagrant scp pgtap.obj :/tmp/pgtap.obj

sudo su - postgres
cd $HOME/code/contrib
git clone https://github.com/theory/pgtap.git
cd $HOME/code/contrib/pgtap
make 
make install

psql
create extension pgtap;

# ################################################################################
# Install on linux VM

sudo su - 
yum -y install cpan
yum -y update cpan
yum -y install perl-Module-Build
cpan App::cpanminus
cpan TAP::Parser::SourceHandler::pgTAP

sudo su - postgres
echo 'export PATH=${PATH}:/root/perl5/bin' >> ${HOME}/.bash_profile
echo 'export PERL5LIB=${PERL5LIB}:/root/perl5/lib/perl5' >> ${HOME}/.bash_profile

# ################################################################################
# create extension 

psql
create extension pgtap;

# ################################################################################
# test - manual

psql
\i /tmp/pgtap_obj.sql
\i /tmp/pgtap_run.sql

# ################################################################################
# Run pg_prove test case

sudo su - postgres
pg_prove /tmp/pgtap_run.sql

# ################################################################################
# Run pg_prove test cases

sudo su - postgres
pg_prove t/*.sql

# ################################################################################


