#! /bin/bash
# Install softwares in remote MYSQL database host.
# written by bodhi wang
# jyxz5@qq.com
# Dec 2017

SCRIPT_HOME=~/mysqlbackup/scripts/
PRCSS_DATE=$(date +%Y%m%d)
BASE_DIR=$(grep base_dir: ${SCRIPT_HOME}dbavars.yml|awk '{print $2}')
EXPIRED_DAYS=$(grep expired_days: ${SCRIPT_HOME}dbavars.yml|awk '{print $2}')

cd ${SCRIPT_HOME} && ansible-playbook xtrabackup.yml --extra-vars="backup_date=$PRCSS_DATE" | tee /var/log/xtrabackup/$PRCSS_DATE.log
find ${BASE_DIR:-/data/backups/full} -mtime +${EXPIRED_DAYS:-15} -type d -print0 | xargs -0 rm -rf
