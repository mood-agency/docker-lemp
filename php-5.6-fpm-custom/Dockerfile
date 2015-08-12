FROM php:5.6-fpm

# Install PHP extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install gd mysqli mcrypt zip

ADD ext-mysqli.ini /usr/local/etc/php/conf.d/ext-mysqli.ini

CMD ["php-fpm"]
