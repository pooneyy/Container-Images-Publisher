#Reference Links ：https://github.com/docker-library/php/issues/926#issuecomment-567230723

FROM php:8.4.17-fpm-bookworm

ARG UNAME=www-data
ARG UGROUP=www-data
ARG UID=1000
ARG GID=1000

RUN usermod  --uid $UID $UNAME; \
    groupmod --gid $GID $UGROUP

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        build-essential \
        libxml2-dev \
        libssl-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libfreetype6-dev \
        libxpm-dev \
        libgmp-dev \
        libmcrypt-dev \
        libreadline-dev \
        libxslt1-dev \
        libonig-dev \
        libzip-dev \
        libc-client-dev \
        libkrb5-dev \
        libmemcached-dev \
        libmagickwand-dev \
        libicu-dev; \
    rm -rf /var/lib/apt/lists/*

RUN pecl install memcached; \
    docker-php-ext-enable memcached; \
    pecl install mcrypt; \
    docker-php-ext-enable mcrypt; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    pecl install imap; \
    docker-php-ext-enable imap; \
    pecl install imagick; \
    docker-php-ext-enable imagick

#pecl temporarily does not support PHP8.1 api installation rar
#Reference Links ：https://stackoverflow.com/questions/73564424/error-while-installing-php-rar-extension-on-ubuntu-server
# rar
#RUN pecl install rar
#RUN docker-php-ext-enable rar

# configure
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-configure intl; \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
    docker-php-ext-configure zip; \
    docker-php-ext-install -j "$(nproc)" \
        gd \
        intl \
        mysqli \
        pdo_mysql \
        zip \
        fileinfo \
        xsl \
        bcmath \
        gettext \
        exif \
        curl \
        mbstring

WORKDIR /www
