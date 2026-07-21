# User Documentation

This document explains how an end user or administrator can operate the
Inception stack.

## Services provided

The stack serves a WordPress website over HTTPS. It is composed of three
services:

- **NGINX** - the web server and single entry point, reachable on port 443
  (HTTPS, TLS v1.2 / v1.3).
- **WordPress + php-fpm** - runs the website itself.
- **MariaDB** - stores the website's data (posts, users, settings).

Only NGINX is reachable from outside; WordPress and MariaDB are internal to the
Docker network.

Five bonus services complete the stack:

- **Redis** - speeds up the website by caching WordPress data in memory
  (internal, no direct access).
- **FTP** - lets you upload files directly into the website's folder.
- **Static website** - a separate page presenting the project itself, in plain
  HTML/CSS.
- **Adminer** - a web interface to browse the database.
- **Backup** - saves a copy of the database every hour (internal, no direct
  access).

## Starting and stopping the project

From the project root:

- **Start:** `make` - builds the images if needed and starts the stack in the
  background.
- **Stop:** `make down`.
- **Restart:** `make re`.

## Accessing the website and the admin panel

- Website: `https://mdourdoi.42.fr`
- Administration panel: `https://mdourdoi.42.fr/wp-admin`

The TLS certificate is self-signed, so the browser will warn about it - accept
it to continue.

Two WordPress accounts exist:

- an administrator (`owner`), created during installation;
- a standard author account (`user`).

Log in to the admin panel with the administrator account to create posts, change
settings or manage users.

## Accessing the bonus services

Ports below are the defaults from `srcs/.env`; change them there if needed.

- **Static website:** `http://localhost:8081` in a browser.
- **Adminer:** `http://localhost:8082` in a browser. The server field is
  pre-filled automatically with the right database address and port; just enter
  the database user name from `srcs/.env` and the password from
  `secrets/db_password.txt`.
- **FTP:** connect a client (FileZilla, `lftp`, ...) to `localhost`, port `21`,
  in passive mode, with the user from `srcs/.env` (`FTP_USER`) and the password
  from `secrets/ftp_password.txt`. You land directly in the website's folder.
- **Backups:** the hourly database dumps are plain `.sql` files in
  `/home/mdourdoi/data/backups/` on the host; the 7 most recent are kept.
- **Redis cache:** nothing to do - it is used automatically by WordPress. To
  check it is working: `docker exec srcs-redis-1 redis-cli -p <REDIS_PORT> monitor`
  (port from `srcs/.env`) while browsing the site shows the cache traffic live.

## Locating and managing credentials

Credentials are never stored in the repository. They live in local files, which
are ignored by git:

- `secrets/db_password.txt` - password of the database application user.
- `secrets/db_root_password.txt` - password of the database root user.
- `secrets/ftp_password.txt` - password of the FTP user.
- `secrets/credentials.txt` - WordPress passwords, as
  `WP_ADMIN_PASSWORD=...` and `WP_USER_PASSWORD=...`.

Non-sensitive settings (database name, user names, domain, ports, WordPress
admin/user names and emails) are stored in `srcs/.env`.

To change a password, edit the corresponding secret file and restart the stack
with `make re`. Note that the database and WordPress are only initialised on the
first run: changing a password after initialisation may require resetting the
data with `make fclean` followed by `make`.

## Checking that the services are running

- List the containers and their state:
  ```
  docker compose -f srcs/docker-compose.yml ps
  ```
  The eight services (`mariadb`, `wordpress`, `nginx`, `redis`, `ftp`,
  `static`, `adminer`, `backup`) should show `Up`.

- Check that the website answers over HTTPS:
  ```
  curl -k https://mdourdoi.42.fr
  ```
  This should return the WordPress home page HTML.

- Follow the logs of a service (for example NGINX):
  ```
  docker compose -f srcs/docker-compose.yml logs -f nginx
  ```