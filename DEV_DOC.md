# Developer Documentation

This document explains how to set up, build and run the Inception project from
scratch, and where its data lives.

## Prerequisites

- A virtual machine running Linux (this project was developed on Debian 13).
- Docker Engine and the Docker Compose plugin installed.
- The domain `mdourdoi.42.fr` resolving to `127.0.0.1` (add it to `/etc/hosts`).
- Git, to clone the repository.

## Setting up the environment from scratch

1. Clone the repository into the VM.

2. Create the environment file `srcs/.env` with the non-sensitive configuration
(complete after the =, only the mandatory values are filled here):

   ```
   DOMAIN_NAME=mdourdoi.42.fr
   MYSQL_DATABASE=
   MYSQL_USER=
   MYSQL_PORT=3306
   WORDPRESS_PORT=9000
   NGINX_PORT=443
   WP_TITLE=
   WP_ADMIN_USER=
   WP_ADMIN_EMAIL=
   WP_USER=
   WP_USER_EMAIL=
   ```

3. Create the secret files under `secrets/` (raw value, one per file - except
   `credentials.txt` which uses `KEY=value` lines):

   - `secrets/db_password.txt` - the database application user's password.
   - `secrets/db_root_password.txt` - the database root password.
   - `secrets/credentials.txt`:
     ```
     WP_ADMIN_PASSWORD=<admin password>
     WP_USER_PASSWORD=<user password>
     ```

   These files are ignored by git and must never be committed.

## Building and running

From the project root, the Makefile wraps Docker Compose:

- `make` / `make up` - create the host data directories, build the images and
  start the stack detached.
- `make down` - stop and remove the containers and the network.
- `make re` - restart (down + up), keeping the data.
- `make clean` - stop the stack and remove its images.
- `make fclean` - remove the images and delete the persisted data (full reset).

Under the hood, `make up` runs:

```
docker compose -f srcs/docker-compose.yml up --build -d
```

## Managing containers and volumes

- List containers: `docker compose -f srcs/docker-compose.yml ps`
- Follow logs: `docker compose -f srcs/docker-compose.yml logs -f <service>`
- Open a shell in a container: `docker exec -it srcs-<service>-1 bash`
- List volumes: `docker volume ls`
- Inspect a volume: `docker volume inspect srcs_mariadb_data`

## Architecture overview

- **Network:** a single bridge network, `inception`; containers reach each other
  by service name.
- **mariadb:** installs MariaDB on Debian bookworm, initialises the database and
  users on first run via `mariadbd --init-file`, and runs `mariadbd` in the
  foreground as PID 1. Listens on `MYSQL_PORT` (3306), internal only.
- **wordpress:** installs php-fpm 8.2 and WP-CLI, waits for MariaDB to accept
  connections, downloads and configures WordPress on first run, then runs
  `php-fpm` in the foreground. Listens on `WORDPRESS_PORT` (9000), internal only.
- **nginx:** generates a self-signed certificate on first run, serves the
  WordPress files over TLS, and forwards `.php` requests to
  `wordpress:9000` via FastCGI. Published on `NGINX_PORT` (443) - the only
  exposed port.

## Where the data is stored and how it persists

Two named volumes back the persistent data, each bound to a directory on the
host:

- `mariadb_data` → `/home/mdourdoi/data/mariadb` - the database files
  (`/var/lib/mysql` in the container).
- `wordpress_data` → `/home/mdourdoi/data/wordpress` - the website files
  (`/var/www/wordpress` in the container), shared with NGINX so it can serve the
  static files.

Because these directories live on the host, the data survives container
destruction and recreation: `make down` followed by `make up` keeps everything.
Only `make fclean` deletes the data. Everything else - the TLS certificate,
generated configuration files, runtime directories - lives inside the containers
and is recreated on each start.