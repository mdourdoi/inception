#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/nginx.crt ] ; then
	openssl req -x509 -newkey rsa:2048 -noenc -out /etc/nginx/ssl/nginx.crt -keyout /etc/nginx/ssl/nginx.key -subj "/C=FR/L=Lyon/O=42/CN=$DOMAIN_NAME"
fi

cat > /etc/nginx/nginx.conf <<EOF
events {}

http {
	include /etc/nginx/mime.types;

	server {
		listen $NGINX_PORT ssl;
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_certificate /etc/nginx/ssl/nginx.crt;
		ssl_certificate_key /etc/nginx/ssl/nginx.key;
		server_name $DOMAIN_NAME;
		root /var/www/wordpress;
		index index.php;
		location / {
			try_files \$uri \$uri/ =404;
		}
		location ~ \.php\$ {
 	  		include snippets/fastcgi-php.conf;
    			fastcgi_pass wordpress:$WORDPRESS_PORT;
		}
	}
}
EOF

exec nginx -g "daemon off;"
