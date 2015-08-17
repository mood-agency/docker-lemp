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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install WP-CLI
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp \
        && chmod +x  /usr/local/bin/wp

# Install waitforservices
RUN curl --location --silent --show-error --fail \
        https://github.com/Barzahlen/waitforservices/releases/download/v0.1/waitforservices \
        > /usr/local/bin/waitforservices \
        && chmod +x /usr/local/bin/waitforservices

VOLUME /var/www
WORKDIR /var/www

# Copy entry point
COPY docker-entrypoint.sh /entrypoint.sh

# Set CMD
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
