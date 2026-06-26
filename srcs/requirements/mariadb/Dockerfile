FROM debian:bookworm

RUN apt update && apt install -y mariadb-server && apt clean && rm -rf /var/lib/apt/lists/* /var/lib/mysql/*

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]

