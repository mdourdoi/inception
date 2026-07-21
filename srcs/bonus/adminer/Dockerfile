FROM debian:bookworm

RUN apt update && apt install -y php8.2-cli php8.2-mysql curl && apt clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && curl -Lo /var/www/adminer/adminer.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
