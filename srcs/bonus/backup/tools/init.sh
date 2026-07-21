#!/bin/bash

set -e

cat > /usr/local/bin/backup.sh <<EOF
#!/bin/bash
mariadb-dump -h mariadb -P $MYSQL_PORT -u root -p"\$(cat /run/secrets/db_root_password)" --all-databases > /backups/dump_\$(date +%F_%H%M).sql
ls -t /backups/dump_*.sql | tail -n +8 | xargs -r rm
EOF
chmod +x /usr/local/bin/backup.sh

echo "0 * * * * root /usr/local/bin/backup.sh" > /etc/cron.d/backup
chmod 644 /etc/cron.d/backup

/usr/local/bin/backup.sh || true

exec cron -f
