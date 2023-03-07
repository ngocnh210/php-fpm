FROM php:8.2-fpm-alpine

LABEL maintainer="Ngọc Nguyễn <me@ngocnh.info>"

EXPOSE 9990 9000 80

WORKDIR /var/www

RUN apk --update add --no-cache --virtual build-dependencies \
      build-base openssl-dev autoconf freetype icu make libpng libjpeg-turbo freetype-dev \
      libmemcached-dev libpng-dev libjpeg-turbo-dev libmcrypt-dev zlib-dev libzip-dev icu-dev g++ \
      && pecl install mongodb \
      && pecl install mcrypt \
      && pecl install memcached

RUN NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure gd --with-freetype --with-jpeg
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        bcmath \
        mysqli \
        pcntl \
        intl \
        pdo_mysql \
        sockets \
        -j${NPROC} gd \
        zip \
        opcache \
    && docker-php-ext-enable mongodb mcrypt memcached opcache

RUN apk del build-dependencies && rm -rf /var/cache/apk/*

RUN apk add nodejs npm composer

CMD php-fpm