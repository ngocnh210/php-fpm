FROM php:8.2-fpm-alpine

LABEL maintainer="Ngọc Nguyễn <me@ngocnh.info>"

EXPOSE 9000

WORKDIR /var/www

RUN apk --update add --no-cache --virtual build-dependencies \
    coreutils \
    build-base \
    openssl-dev \
    autoconf \
    freetype \
    icu \
    make \
    libpng \
    libjpeg-turbo \
    freetype-dev \
    libmemcached-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    zlib-dev \
    libzip-dev \
    icu-dev \
    g++ \
    oniguruma-dev \
    gmp-dev

RUN apk add --update linux-headers nodejs npm composer

# Install PHP Extension bcmath
RUN docker-php-ext-configure bcmath --enable-bcmath && \
    docker-php-ext-install bcmath

# Install PHP Extension gd
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j "$(nproc)" gd

# Install PHP Extension pcntl
RUN docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-install pcntl

# Install PHP Extension intl
RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl

# Install PHP Extension mongodb
RUN pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

# Install PHP Extension memcached
RUN pecl install memcached && \
    docker-php-ext-enable memcached

# Install PHP Extension mcrypt
RUN pecl install mcrypt && \
    docker-php-ext-enable mcrypt

# Install PHP Extension opcache
RUN docker-php-ext-install opcache && \
    docker-php-ext-enable opcache

# Install PHP Extension bcmath
RUN docker-php-ext-install bcmath

# Install PHP Extension mysqli
RUN docker-php-ext-install mysqli

# Install PHP Extension pdo_mysql
RUN docker-php-ext-configure pdo_mysql && \
    docker-php-ext-install -j "$(nproc)" pdo_mysql

# Install PHP Extension sockets
RUN docker-php-ext-install sockets

# Install PHP Extension zip
#RUN docker-php-ext-install -j "$(nproc)" zip \

# Install PHP Extension gmp
RUN docker-php-ext-configure gmp && \
    docker-php-ext-install -j "$(nproc)" gmp

# Remove Build dependencies & caches
RUN apk del build-dependencies && rm -rf /var/cache/apk/*

CMD php-fpm