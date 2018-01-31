# mysqlbackup

使用ansible和xtrabackup对目标mysql数据库进行物理热备份，
备份后把备份数据从目标mysql数据库主机回传到本机。

## 约定

- 本机： 安装了ansible的控制主机， 也是备份机。
- 远程mysql数据库：需要备份的mysql数据库，也叫目标mysql数据库。

## 先决条件
- 本软件运行在centos 7, 并且ansible已安装， sshd服务已启动。
- 目标mysql数据库服务器的操作系统也是centos 7，sshd服务已启动。


## 部署过程
在ansible所在主机的root用户的HOME目录下运行如下命令：

- 下载软件

   git clone https://github.com/tjnh05/mysqlbackup.git

- 创建目录和修改权限

  下面命令创建数据备份目录/data/backups/full和日志目录/var/log/xtrabackup。
  出于安全考虑，需要设置相关目录和文件的访问权限。
  
    >chown 0700 ~/mysqlbackup/scripts 
    >chmod 0600 ~/mysqlbackup/scripts/*.yml
    >chmod 0700 ~/mysqlbackup/scripts/xtrabackup.sh
    >mkdir -p /data/backups/full
    >chmod -R 0750 /data/backups 
    >mkdir -p /var/log/xtrabackup 
    >chmod 0755 /var/log/xtrabackup


- 配置
  - Ansible 配置
    修改配置文件/etc/ansible/hosts, 增加mysql数据库服务器配置，示例如下，
    把IP地址10.13.1.103修改成目标mysql数据库服务器的IP地址或域名，ansible_user可以
    设置为root或其他通过运行sudo命令自动切换到root的用户， ansible_password修改为
    ansible_user对应用户的密码。

[mysqldbserv]
10.13.1.103  ansible_user=root ansible_password=password

    如果是通过无密码ssh访问方式，则需要修改/etc/ansible/ansible.cfg, 设置私钥文件,
    示例如下：
    private_key_file=/root/.ssh/id_rsa
    如果RSA密钥对没有，可以运行如下命令：
    ssl-keygen -t rsa
    具体过程请参考以下链接：
    https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s3-openssh-rsa-keys-v2.html

  - 设置目标mysql数据库root用户密码
    修改配置文件~/mysqlbackup/scripts/tdbvars.yml，设置目标mysql数据库的root用户，用于
    后续创建备份用户，如果备份用户已存在，可以不修改该文件。

mysql_root_password: "8f2370778b445915157a"

  - 设置目标mysql数据库备份用户和密码
    修改配置文件~/mysqlbackup/scripts/dbvars.yml。

#目标mysql数据库的备份用户
backup_user: backup
#备份用户的密码
backup_password: "536b43778f5883433969"

#存储数据库备份的基础目录
#该目录在本机和目标MYSQL主机上是相同的
base_dir:   /data/backups/full/
#目标MYSQL数据库的数据目录
datadir: "/data/mysql"
#备份保存天数，陈旧的备份将被删除
expired_days: 15

  - 安装软件到目标MYSQL主机
    在MYSQL主机上安装软件Xtrabackup，rsync， MYSQL-python。需要连互联网。
    在本机目录~/mysqlbackup/scripts下运行如下命令：
 
    ansible-playbook  installremote.yml

    如果安装报错，则运行如下命令以安装：
    ansible-playbook  installremote.yml --extra-vars="mysql_compat=yes"

  - 创建备份用户
    如果备份用户在目标mysql数据库上已存在，则忽略本步骤。
    
    ansible-playbook  backupuser.yml

## 备份，回传备份，并清理过期的备份
  在本机的部署目录~/mysqlbackup/scripts运行如下命令：
    
  ansible-playbook  xtrabackup.yml --extra-vars="backup_date=$(date +%Y%m%d)"

  回传的备份放在/data/backups/full/目录下。
  备份的过期天数在配置文件dbavars.yml里由配置项expired_days设置，单位天。
  目标mysql主机过期的备份将被删除。

## 定时执行备份
  如果需要定时备份数据库，可以把备份命令放在crontab里由cron定时执行。
  假设是每天凌晨两点运行，则运行命令crontab -e，并增加如下内容：
    
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/ibutils/bin:/root/bin:/root/scripts
MAILTO=root@localhost
0 2 * * * /root/mysqlbackup/scripts/xtrabackup.sh

## 恢复 
  注意：本过程只在做数据库恢复时才使用。
  在本机的部署目录~/mysqlbackup/scripts
  运行如下命令，其中20171123需替换成相应的全量备份日期。
  
  ansible-playbook  restore.yml --extra-vars="backup_date=20171123"







