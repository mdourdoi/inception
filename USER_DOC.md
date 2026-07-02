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

## Locating and managing credentials

Credentials are never stored in the repository. They live in local files, which
are ignored by git:

- `secrets/db_password.txt` - password of the database application user.
- `secrets/db_root_password.txt` - password of the database root user.
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
  The three services (`mariadb`, `wordpress`, `nginx`) should show `Up`.

- Check that the website answers over HTTPS:
  ```
  curl -k https://mdourdoi.42.fr
  ```
  This should return the WordPress home page HTML.

- Follow the logs of a service (for example NGINX):
  ```
  docker compose -f srcs/docker-compose.yml logs -f nginx
  ```