#!/bin/bash

# Executing the backup immediately
echo "Executing the backup immediately..."
/backup_script.sh

cp ./backup_script.sh /root/backup_script.sh

printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' > /root/cron.sh

cat <<EOT >> /root/cron.sh

echo "Executing the backup..."
./backup_script.sh
EOT

chmod +x /root/cron.sh

# Checking if the initial backup was successful
if [ $? -ne 0 ]; then
    echo "Initial backup failed. Aborting execution."
    exit 1
fi

touch /mongo_backup.log

# Setting up the cron...
echo "Setting up the cron..."

echo "${CRON_SCHEDULE} /root/cron.sh >> /mongo_backup.log 2>&1" > /crontab.conf
crontab  /crontab.conf
echo "Running cron job"
cron && tail -f /mongo_backup.log