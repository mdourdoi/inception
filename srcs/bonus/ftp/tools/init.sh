#!/bin/bash

set -e

if ! id "$FTP_USER" >/dev/null 2>&1 ; then
	useradd -d /var/www/wordpress -s /usr/sbin/nologin "$FTP_USER"
	usermod -aG www-data "$FTP_USER"
fi
echo "$FTP_USER:$(cat /run/secrets/ftp_password)" | chpasswd

chmod -R g+w /var/www/wordpress

cat > /etc/vsftpd.conf <<EOF
listen=YES
listen_port=$FTP_PORT
local_enable=YES
write_enable=YES
local_umask=002
local_root=/var/www/wordpress
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=$FTP_PASV_MIN
pasv_max_port=$FTP_PASV_MAX
seccomp_sandbox=NO
EOF

exec /usr/sbin/vsftpd /etc/vsftpd.conf
