FROM volkulion/php_base_image:latest
LABEL Description="Application container"

# Xdebug
RUN pecl install xdebug

# NPM installation
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && apt-get install -y nodejs python-dev --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Nginx configuration
COPY docker/helpers/nginx/server.conf /etc/nginx/sites-available/
#COPY docker/helpers/nginx/conf.d/* etc/nginx/conf.d/

COPY ./docker/helpers/keep-alive.sh /scripts/keep-alive.sh
RUN chmod +x /scripts/keep-alive.sh

COPY ./docker/helpers/fpm-entrypoint.sh fpm-entrypoint.sh
COPY ./docker/helpers/aliases/* /scripts/aliases/

RUN mkdir -p /src /var/www/.composer /var/www/.npm /var/www/.config;chown -R www-data:www-data /src /var/www/.composer /var/www/.npm /var/www/.config

# Switch to www-data
USER www-data

# cd to working directory
WORKDIR /src

# Code. AFTER THIS POINT YOU CAN'T USE DOCKER LAYERS CACHE SINCE CODE ALWAYS CHANGES!
COPY --chown=www-data:www-data ./ /src

RUN chmod -R 0777 /src/storage && mkdir -p /src/bootstrap/cache && chmod -R 0777 /src/bootstrap/cache

# Composer
#RUN rm -rf /src/vendor && \
#    composer install

# NPM
RUN rm -rf /src/node_modules && \
    npm install


WORKDIR /src

USER root
#ENTRYPOINT ["/scripts/keep-alive.sh"]
EXPOSE 9000
CMD ["supervisord"]
