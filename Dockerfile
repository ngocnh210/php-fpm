FROM php:7.3-fpm-alpine

LABEL maintainer="Ngọc Nguyễn <me@ngocnh.info>"

EXPOSE 9000
WORKDIR /var/www

RUN apk --update add --no-cache --virtual build-dependencies \
      build-base openssl-dev autoconf freetype icu make libpng libjpeg-turbo freetype-dev \
      libmemcached-dev libpng-dev libjpeg-turbo-dev libmcrypt-dev zlib-dev libzip-dev icu-dev g++ \
      && pecl install mongodb \
      && pecl install mcrypt \
      && pecl install memcached \
      && pecl install xdebug

RUN NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure gd \
                    --with-gd \
                    --with-freetype-dir=/usr/include/ \
                    --with-png-dir=/usr/include/ \
                    --with-jpeg-dir=/usr/include/ \
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
    && docker-php-ext-enable mongodb mcrypt memcached xdebug opcache \
    && sed -i '1 a xdebug.remote_autostart=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.remote_port=9990' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.remote_host=127.0.0.1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.profiler_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.profiler_output_dir=/var/log/xdebug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && sed -i '1 a xdebug.idekey=PHPSTORM' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apk del build-dependencies && rm -rf /var/cache/apk/*

CMD ["php-fpm"]



