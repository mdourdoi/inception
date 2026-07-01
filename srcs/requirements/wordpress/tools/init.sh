#!/bin/bash
set -e

until (echo > /dev/tcp/mariadb/${MYSQL_PORT}) 2>/dev/null; do
    sleep 1
done

if [ ! -f /var/www/wordpress/wp-settings.php ]; then
    wp core download --path=/var/www/wordpress --allow-root
fi

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    wp config create --path=/var/www/wordpress --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$(cat /run/secrets/db_password)" --dbhost=mariadb --allow-root
fi

if ! wp core is-installed --path=/var/www/wordpress --allow-root 2>/dev/null; then
    wp core install \
        --path=/var/www/wordpress \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d= -f2)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d= -f2)" \
        --path=/var/www/wordpress \
        --allow-root
fi

cat > /etc/php/8.2/fpm/pool.d/www.conf <<EOF
[www]
user = www-data
group = www-data
listen = 0.0.0.0:$WORDPRESS_PORT
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
EOF

exec /usr/sbin/php-fpm8.2 -F
