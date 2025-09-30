# -----------------------------
# Main Image
# -----------------------------
FROM php:8.3-fpm

# -----------------------------
# ARGs
# -----------------------------
ARG container_project_path
ARG uid
ARG user

# -----------------------------
# System Dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    procps \
    curl \
    unzip \
    libzip-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libicu-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libmagickwand-dev \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# PHP Extensions
# -----------------------------
# GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Intl
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Other Common Extensions
RUN docker-php-ext-install bcmath calendar exif gmp mysqli pdo pdo_mysql zip

# -----------------------------
# Composer
# -----------------------------
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# -----------------------------
# Node JS & Global NPM
# -----------------------------
COPY --from=node:23 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:23 /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && npm install -g npx laravel-echo-server

# -----------------------------
# Nginx
# -----------------------------
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

COPY ./.configs/nginx/pools/www.cnf /usr/local/etc/php-fpm.d/www.conf
COPY ./.configs/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# -----------------------------
# Varnish
# -----------------------------
RUN apt-get update && apt-get install -y varnish \
    && rm -rf /var/lib/apt/lists/*

COPY ./.configs/varnish/default.vcl /etc/varnish/default.vcl

ENV VARNISH_DEFAULT_N=/var/lib/varnish
ENV VARNISH_DEFAULT_S=/etc/varnish/secret
ENV VARNISH_DEFAULT_T=localhost:6082

RUN groupadd -r varnishadm \
    && usermod -aG varnishadm www-data \
    && usermod -aG varnishadm $user \
    && mkdir -p /var/lib/varnish \
    && chown -R root:varnishadm /var/lib/varnish \
    && chmod -R 775 /var/lib/varnish \
    && chmod g+s /var/lib/varnish \
    && chown root:varnishadm /etc/varnish/secret \
    && chmod 640 /etc/varnish/secret \
    && chmod 755 /usr/bin/varnishadm \
    && getent group varnish && usermod -aG varnish $user || true

# -----------------------------
# Project User Setup
# -----------------------------
RUN useradd -G www-data,root -u $uid -d /home/$user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user \
    && chmod -R 775 $container_project_path \
    && chown -R $user:www-data $container_project_path

# -----------------------------
# Working Directory & User
# -----------------------------
USER $user

WORKDIR $container_project_path
