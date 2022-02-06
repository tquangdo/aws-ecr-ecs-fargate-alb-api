FROM composer:2 AS composer
FROM php:7.4-fpm AS release

ARG APP_ENV=develop
ENV BASIC_AUTH_USER=labor
ENV BASIC_AUTH_PW=@Password

# Composer settings
ENV COMPOSER_HOME /usr/local/lib/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_CACHE_DIR /dev/null

# Install composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=composer /tmp/keys.dev.pub /tmp/keys.tags.pub ${COMPOSER_HOME}/

# Install OS Packages
RUN apt update \
    && apt upgrade --yes \
    && apt install --yes --no-install-recommends \
    # tiny is small init module https://github.com/krallin/tini \
    tini \
    # Web server
    nginx \
    # for zip
    zip \
    # for unzip
    unzip \
    # for gd php extension
    libgd-dev \
    # for xsl php extension
    libxslt1-dev \
    # for zip php extension
    libzip-dev \
    # for editor
    nano \
    # for editor
    vim \
    # for phantomjs
    libfontconfig \
    # japanese fonts
    libfreetype6 \
    xfonts-cyrillic \
    xfonts-scalable \
    fonts-noto-cjk \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP Extensions
RUN pecl install \
    redis \
    && docker-php-ext-install \
    calendar exif gd gettext pcntl pdo pdo_mysql shmop sockets sysvmsg sysvsem sysvshm xsl opcache zip \
    && docker-php-ext-enable \
    opcache redis

RUN apt-get update && apt-get install -y awscli && aws --version

# Copy middleware config files
COPY rootfs/ /

# Copy custom php ini
COPY deployment/env/${APP_ENV}/php/custom.ini  /etc/php/${PHP_VERSION}/conf.d/

WORKDIR /usr/src/app

# Copy all source files to /usr/src/app for production.
# But available to overwrite by volume option when development.
COPY . .

RUN echo "$BASIC_AUTH_USER:$(openssl passwd -apr1 $BASIC_AUTH_PW)\n" >> "/etc/nginx/.htpasswd"

RUN chown -R root:www-data storage && chmod -R 775 storage

# Install package
RUN if [ ${APP_ENV} != develop ]; then \
    composer install --no-dev --quiet --optimize-autoloader && \
    cd / && \
    curl -sLO https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar && \
    chmod +x cachetool.phar && \
    mv cachetool.phar /usr/local/bin/cachetool \
    ;else \
    composer install \
    ;fi

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["laravel"]