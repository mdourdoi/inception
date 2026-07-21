DOCKER := docker
SRCS := srcs/docker-compose.yml

COMPOSE := $(DOCKER) compose -f $(SRCS)

all: up

up:
	@mkdir -p /home/mdourdoi/data/mariadb
	@mkdir -p /home/mdourdoi/data/wordpress
	@mkdir -p /home/mdourdoi/data/backups
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

re: down up

clean:
	$(COMPOSE) down --rmi all

fclean: clean
	@sudo rm -rf /home/mdourdoi/data/mariadb
	@sudo rm -rf /home/mdourdoi/data/wordpress
	@sudo rm -rf /home/mdourdoi/data/backups

.PHONY: all up down re clean fclean
