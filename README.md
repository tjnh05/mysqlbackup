# mysqlbackup

使用ansible和xtrabackup对远程MYSQL数据库进行物理热备份，
备份后把整个新备份目录从远程MYSQL数据库主机回传到本机。

部署方法：
在ansible所在主机的root用户的HOME目录下运行如下命令：
1. 下载软件
git clone https://github.com/tjnh05/mysqlbackup.git

2. 创建目录和修改权限
下面命令创建数据备份目录/data/backups/full和日志目录/var/log/xtrabackup。
出于安全考虑，需要设置相应目录和文件的访问权限。
chown 0700 ~/mysqlbackup/scripts &&  \
chmod 0600 ~/mysqlbackup/scripts/*.yml && \
chmod 0700 ~/mysqlbackup/scripts/xtrabackup.sh && \
mkdir -p /data/backups/full && \
chmod -R 0750 /data/backups && \ 
mkdir -p /var/log/xtrabackup && \
chmod 0755 /var/log/xtrabackup

3. 配置





