ECHO () {
echo "######################################################################"
echo `date`
echo "RaogaruDB PostgreSQL ..."
echo "$*"
echo "`date` $*" >> bootstrap.log
}

ECHODO () {
echo "######################################################################"
echo `date`
echo "RaogaruDB PostgreSQL ..."
echo "$*"
echo "`date` $*" >> bootstrap.log
$*
}

echo "bootstrap.sh Started !"

ECHODO "sudo timedatectl set-timezone America/New_York"

ECHODO "sudo yum update -y -q -e 0"

ECHODO "sudo yum install -y -q -e 0 bison-devel readline-devel zlib-devel openssl-devel wget ccache cmake"

sudo yum groups install 'Development Tools' -y 

ECHODO "sudo adduser postgres"

sudo echo '
export PGCODE=$HOME/code
export PGDATA=$HOME/data
export PGSOFT=$HOME/soft
export PGLOG=$HOME/logs
export PGBIN=$PGSOFT/bin
export PGLIB=$PGSOFT/lib
export PGINC=$PGSOFT/include
export PGEXT=$PGSOFT/share/extension
export PATH=$PATH:$PGBIN
alias PGinit="${PGBIN}/initdb -D ${PGDATA}"
alias PGstart="${PGBIN}/pg_ctl -D ${PGDATA} start -l ${PGLOG}/postgres.log"
alias PGstop="${PGBIN}/pg_ctl -D ${PGDATA} stop"
alias PGstatus="${PGBIN}/pg_ctl -D ${PGDATA} status"
set -o vi
' >> ~postgres/.bash_profile

sudo -u postgres bash -c 'env|grep PG'

ECHO "git clone https://github.com/postgres/postgres.git"
sudo -u postgres bash -c 'git clone https://github.com/postgres/postgres.git $HOME/code'

ECHO "Reset timestamp on all source code"
sudo -u postgres bash -c 'cd $HOME/code; find . -type f -exec touch -t 202401010000 {} \;'

ECHO "Run AutoConfigure ..."
sudo -u postgres bash -c 'cd $HOME/code; autoconf'

ECHO "Run Configure ..."
sudo -u postgres bash -c 'cd $HOME/code; ./configure --prefix=$HOME/soft --without-icu -q'

ECHO  "make clean ..."
sudo -u postgres bash -c 'cd $HOME/code; make -s clean'

ECHO  "make ..."
sudo -u postgres bash -c 'cd $HOME/code; make -s'

ECHO  "make check ..."
sudo -u postgres bash -c 'cd $HOME/code; make -s check'

ECHO  "make install ..."
sudo -u postgres bash -c 'cd $HOME/code; make -s install'

sudo -u postgres bash -c 'mkdir -p $HOME/logs $HOME/data'

ECHO  "initdb ..."
sudo -u postgres bash -c '$HOME/soft/bin/initdb -D $HOME/data'

ECHO  "start db ..."
sudo -u postgres bash -c '$HOME/soft/bin/pg_ctl -D $HOME/data start -l $HOME/logs/postgres.log'

ECHO  "status db ..."
sudo -u postgres bash -c '$HOME/soft/bin/pg_ctl -D $HOME/data status -l $HOME/logs/postgres.log'

echo "bootstrap.sh Completed !"

