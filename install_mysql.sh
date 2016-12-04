#!/bin/bash
software=/server/tools
app=/application
install needed software
yum install ncurses-devel bison gcc gcc-c++ -y

[ ! -d $software ]&&mkdir -p /server/tools

#install cmake
cd "$software"
git clone https://github.com/daiqing150/db.git && \
cd "$software"/db
tar xf cmake-2.8.8.tar.gz && cd cmake-2.8.8
./configure && \
gmake && gmake install

install mysql
useradd mysql -s /sbin/nologin -M

cd "$software"/db/mysql-5.5.32
tar xf mysql-5.5.32.tar.gz && cd mysql-5.5.32
cmake . -DCMAKE_INSTALL_PREFIX=/application/mysql-5.5.32 \
-DMYSQL_DATADIR=/application/mysql-5.5.32/data \
-DMYSQL_UNIX_ADDR=/application/mysql-5.5.32/tmp/mysql.sock \
-DEXTRA_CHARSETS=gbk,gb2312,utf8,ascii \
-DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci  \
-DENABLED_LOCAL_INFILE=ON \
-DWITH_INNOmakeBASE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGERSETS=gbk,gb2312,utf8,ascii \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci  \
-DENABLED_LOCAL_INFILE=ON \
-DWITH_INNOmakeBASE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_EXAMPLE_STORAGE_ENGINE=1 \
-DWITH_FAST_MUTEXES=1 \
-DWITH_ZLIB=bundled \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_READLINE=1 \
-DWITH_EMBEDDED_SERVER=1 \
-DWITH_DEBUG=0
make && make install

#link
ln -s $app/mysql-5.5.32/ $app/mysql

#update config file
/bin/cp $app/mysql/support-files/my-small.cnf /etc/my.cnf

#env
echo 'export PATH=/application/mysql/bin:$PATH'>>/etc/profile
source /etc/profile

#chown
chown -R mysql.mysql $app/mysql
chown -R 1777 /tmp/

#init
$app/mysql/scripts/mysql_install_db --basedir=$app/mysql --datadir=$app/mysql/data --user=mysql

#copy start script
cp /application/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld

#start service
/etc/init.d/mysqld start
