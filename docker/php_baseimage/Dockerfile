FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

## PREPARE LIST OF PACKAGES
ENV REQUIRED_PACKAGES \
        ca-certificates \
        curl \
        cron \
        wget \
        vim \
        mc \
        less \
        tmux \
        gnupg2 \
        git \
        openssh-client \
        libc6-dev \
        apt-transport-https \
        lsb-release \
        make \
        pkg-config \
        supervisor \
        ssmtp \
        tzdata

ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev \
        file \
        g++ \
        gcc \
        libc-dev \
        libpcre3-dev \
        make \
        pkg-config \
        re2c

ENV PHP_DEPS \
        ca-certificates \
        curl \
        libedit2 \
        libsqlite3-0 \
        libxml2

ENV PHP_BUILD_DEPS \
        libcurl4-openssl-dev \
        libreadline6-dev \
        librecode-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libevent-dev \
        libedit2 \
        libedit-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev

## PREPARE LIST OF PACKAGES

## INSTALL PACKAGES
RUN apt-get update && apt-get install -y --no-install-recommends \
        $REQUIRED_PACKAGES \
        $PHPIZE_DEPS \
        $PHP_DEPS \
        $PHP_BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*
## INSTALL PACKAGES

## PHP CONFIGURE AND ENV
ENV PHP_VERSION 7.2.11
ENV PHP_FILENAME php-7.2.11.tar.gz
ENV PHP_SHA256 180c63a9647c0a50d438b6bd5c7a8e7a11bceee8ad613a59d3ef15151fc158d4
ENV GPG_KEYS 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 1729F83938DA44E27BA0F4D3DBDB397470D12172 A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --with-mysql --with-mysqli --with-pdo-mysql --enable-soap
ENV CONFIGURE_ARGS \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_EXTRA_CONFIGURE_ARGS \
        --disable-cgi \
        --enable-mysqlnd \
        --with-curl \
        --with-openssl \
        --with-readline \
        --with-recode \
        --with-zlib \
        --enable-ftp \
        --enable-mbstring \
        --with-libedit \
        --enable-sockets \
        --enable-shmop \
        --enable-mbstring \
        --with-iconv \
        --with-jpeg-dir \
        --with-png-dir \
        --with-freetype-dir \
        --enable-pcntl \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-sysvmsg \
        --enable-zip \
        --with-gd
## PHP CONFIGURE

## INSTALL PHP
RUN mkdir -p $PHP_INI_DIR/conf.d
RUN set -xe \
    && for key in $GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done
RUN curl -fSL "https://secure.php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
    && echo "$PHP_SHA256 $PHP_FILENAME" | sha256sum -c - \
    && curl -fSL "https://secure.php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o "$PHP_FILENAME.asc" \
    && gpg --batch --verify "$PHP_FILENAME.asc" "$PHP_FILENAME" \
    && mkdir -p /usr/src/php \
    && tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
    && rm "$PHP_FILENAME"*
RUN cd /usr/src/php \
    && ./configure \
        $CONFIGURE_ARGS \
    && make -j"$(nproc)" \
    && make install \
    && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && rm -f /usr/local/etc/php-fpm.d/www.conf.default \
    && make clean
COPY php-helpers/docker-php-ext-* /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-ext-*
## INSTALL PHP

## CONFIGURE NGINX
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
    && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(grep DISTRIB_CODENAME /etc/lsb-release|cut -d = -f 2) main" >/etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install nginx -y \
    && rm -rf ~/.cache /var/lib/apt/lists/*
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/mime.types /etc/nginx/mime.types
COPY nginx/server.conf /etc/nginx/sites-available/server.conf
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    ln -nfs /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf
## CONFIGURE NGINX

# Change www-data to be stable id to share between containers
RUN usermod -u 1000 www-data

## CONFIGURE FPM
COPY ./php-cli.ini $PHP_INI_DIR/cli/php.ini
COPY ./php-fpm.ini $PHP_INI_DIR/php.ini
COPY ./php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf

# Relax open files limits for www-data user
COPY ./www-data.conf /etc/security/limits.d/www-data.conf

## INSTALL EXTENSIONS
RUN pecl install msgpack redis&& docker-php-ext-enable msgpack redis
# Opcache is not enabled by default since devs don't need it
# Enable with docker-php-ext-enable opcache using entrypoint
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=512'; \
        echo 'opcache.interned_strings_buffer=64'; \
        echo 'opcache.max_accelerated_files=20000'; \
        echo 'opcache.validate_timestamps=1'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini
## INSTALL EXTENSIONS

## INSTALL COMPOSER
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    composer --no-interaction global require 'hirak/prestissimo'
## INSTALL COMPOSER

## INSTALL GSFUSE
RUN export GCSFUSE_REPO=gcsfuse-$(grep DISTRIB_CODENAME /etc/lsb-release|cut -d= -f 2) \
  && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get --no-install-recçommends install -y gcsfuse \
  && rm -rf ~/.cache /var/lib/apt/lists/*
## INSTALL GSFUSE

### INSTALL NEWRELIC ####
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list \
    && wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && apt-get update && apt-get install newrelic-php5 -y \
    && NR_INSTALL_USE_CP_NOT_LN=1 NR_INSTALL_SILENT=1 newrelic-install install \
    && mv /usr/local/etc/php/conf.d/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini.disabled \
    && rm -rf ~/.cache /var/lib/apt/lists/*
##### INSTALL NEWRELIC #########

## CONFIGURE SUPERVISOR
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisor/server.conf /etc/supervisor/conf.d/server.conf
COPY supervisor/stop-supervisor.sh /usr/local/bin/
## CONFIGURE SUPERVISOR

EXPOSE 9000

CMD ["supervisord"]
