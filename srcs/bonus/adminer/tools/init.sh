#!/bin/bash

set -e

cat > /var/www/adminer/index.php <<EOF
<?php
if (!isset(\$_GET["server"]) && !isset(\$_POST["auth"])) {
	header("Location: ?server=" . urlencode("mariadb:$MYSQL_PORT"));
	exit;
}
require "/var/www/adminer/adminer.php";
EOF

exec php -S 0.0.0.0:$ADMINER_PORT -t /var/www/adminer
