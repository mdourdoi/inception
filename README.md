*This project has been created as part of the 42 curriculum by mdourdoi.*

# Inception

## Description

Inception is a system administration project whose goal is to build a small
infrastructure made of several services, each running in its own Docker
container, orchestrated with Docker Compose, inside a virtual machine for the
sake of the exercise. In a real situation, this kind of architecture could be
built without a virtual env (see Virtual Machines vs Docker below).

The infrastructure serves a WordPress website over HTTPS and is composed of
three services:

- **NGINX** - the single entry point, exposed on port 443, serving the site over
  TLS (v1.2 / v1.3 only).
- **WordPress + php-fpm** - the PHP engine that runs WordPress, reachable only
  from the internal network.
- **MariaDB** - the database, reachable only from the internal network.

Two named volumes persist the database and the website files, and a dedicated
Docker network connects the containers.

## Project Description

### Docker usage and sources

Each service is built from its own Dockerfile, based on the penultimate stable
Debian release (bookworm at the moment the project was being done, may have changed).
No pre-built application image is pulled: only the Debian base image is used, and
every service (NGINX, WordPress/php-fpm, MariaDB) is installed and configured by
hand. Each container runs a single service in the foreground as PID 1
(`mariadbd`, `php-fpm -F`, `nginx -g "daemon off;"`), without any hacky keep-alive
trick (`tail -f`, `sleep infinity`, etc.).

The sources are organised under `srcs/`, with one directory per service in
`srcs/requirements/`, each containing a Dockerfile and an entrypoint script
(`tools/init.sh`) that performs first-run initialisation in an idempotent way.

### Main design choices

- **One process per container, run in the foreground.** Each entrypoint ends
  with `exec`, so the real service becomes PID 1 and the container lives exactly
  as long as its service.
- **Idempotent initialisation.** Each entrypoint checks whether the service is
  already initialised (database present, WordPress installed, certificate
  generated) before doing any setup, so restarts never overwrite existing data.
- **Configuration driven by the `.env` file.** All ports and identifiers come
  from a single `.env` avaialable on the machine, so changing a port only requires
  editing one line and re-running the stack.
- **Secrets kept out of the image and out of git.** Passwords are provided
  through Docker secrets, never written into Dockerfiles or the `.env`. They are
  also available on the machin for the exam.

### Virtual Machines vs Docker

A virtual machine emulates a full computer, with its own kernel and a complete
operating system, managed by a hypervisor. It is heavy (several GB, slow to
boot) but fully isolated. A Docker container isolates a process while sharing
the host kernel: it is lightweight (tens of MB), starts almost instantly, and is
reproducible. This project runs Docker *inside* a VM: the VM provides the
isolated, disposable sandbox with the root privileges required for system
administration, while Docker provides the lightweight, reproducible per-service
containers.

### Secrets vs Environment Variables

Environment variables (from the `.env`) are convenient but readable by anyone
who can inspect the container (`docker inspect`, the process environment). They
are therefore used only for non-sensitive values: database name, application
user name, domain name and ports. Sensitive values (the WordPress and root
database passwords) are provided through Docker secrets, which are mounted as
files under `/run/secrets/` in the containers that need them, and never appear
as environment variables or in the built image.

### Docker Network vs Host Network

Using the host network would make the containers share the host's network stack
directly, removing isolation and exposing every port on the host - and it is
forbidden by the subject. Instead, a dedicated bridge network (`inception`) is
used: it is a private, isolated network where containers reach each other by
service name through Docker's internal DNS (for example, WordPress reaches the
database at `mariadb:3306`). Only NGINX publishes a port (443) to the host,
which makes it the single entry point into the infrastructure.

### Docker Volumes vs Bind Mounts

A bind mount maps an explicit host path into the container; the developer
chooses the path, and Docker does not track it as an object. A named volume is
managed by Docker: it is designated by a name, appears in `docker volume ls`,
has its own lifecycle, and its storage location is normally handled by Docker.
The subject requires named volumes but also requires the data to live in
`/home/mdourdoi/data`. To satisfy both, the volumes are declared as named
volumes with `driver_opts` (`type: none`, `o: bind`) pointing at the required
host path: they are named volumes from Docker's point of view (same commands,
same lifecycle), while their underlying storage is a bind to a known,
inspectable directory.

## Instructions

Prerequisites: a Linux host (a virtual machine) with Docker and the Docker
Compose plugin installed, and the domain `mdourdoi.42.fr` resolving to
`127.0.0.1` in `/etc/hosts`.

Before the first run, create the `.env` file and the secret files (see
`DEV_DOC.md`).

From the project root:

```
make        # build the images and start the stack (detached)
make down   # stop and remove the containers
make re     # restarts everything, does down then up
make clean  # stop the stack and remove its images
make fclean # remove images and delete the persisted data
```

The website is then available at `https://mdourdoi.42.fr` and the administration
panel at `https://mdourdoi.42.fr/wp-admin` through the VM (we can't access /etc/hosts
on school's computer)

## Resources

- Docker documentation - https://docs.docker.com
- Docker Compose file reference - https://docs.docker.com/compose/compose-file/
- NGINX documentation - https://nginx.org/en/docs/
- WP-CLI - https://wp-cli.org/
- MariaDB Knowledge Base - https://mariadb.com/kb/

### Use of AI

AI (Claude) was used as a tutor and reviewer throughout the project as an 
addition to documentation to understand the concepts of this project, and 
as a way to be more efficient during documentation researches (what are the
dependecies, how each brick connect to another, verify up-to-date technical
details like binary names, ...)