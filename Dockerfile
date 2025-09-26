# main image
FROM php:8.3-fpm

# installing main dependencies
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    procps \
    nginx \
    curl \
    varnish

# installing unzip dependencies
RUN apt-get install -y \
    libzip-dev \
    zlib1g-dev \
    unzip

# gd extension configure and install
RUN apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install gd

# imagick extension configure and install
RUN apt-get install -y libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# intl extension configure and install
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# other extensions install
RUN docker-php-ext-install bcmath calendar exif gmp mysqli pdo pdo_mysql zip

# installing composer
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# installing node js
COPY --from=node:23 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:23 /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# installing global node dependencies
RUN npm install -g npx
RUN npm install -g laravel-echo-server

# arguments
ARG container_project_path
ARG uid
ARG user

# copy php-fpm pool configuration
COPY ./.configs/nginx/pools/www.cnf /usr/local/etc/php-fpm.d/www.conf

# copy nginx configuration
COPY ./.configs/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# copy varnish configuration
COPY ./.configs/varnish/default.vcl /etc/varnish/default.vcl

# set default varnish working directory and secret file for varnishadm
ENV VARNISH_DEFAULT_N=/var/lib/varnish
ENV VARNISH_DEFAULT_S=/etc/varnish/secret
ENV VARNISH_DEFAULT_T=localhost:6082

# adding user
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# create a group for varnishadm access
RUN groupadd -r varnishadm && \
    usermod -aG varnishadm www-data && \
    usermod -aG varnishadm $user

# change ownership of varnish secret
RUN chown root:varnishadm /etc/varnish/secret && \
    chmod 640 /etc/varnish/secret

# give group access to instance directory and make it sticky
RUN mkdir -p /var/lib/varnish \
    && chown -R root:varnishadm /var/lib/varnish \
    && chmod -R 775 /var/lib/varnish \
    && chmod g+s /var/lib/varnish

# ensure varnishadm binary has proper permissions
RUN chmod 755 /usr/bin/varnishadm

# add custom user to varnish system group if it exists
RUN getent group varnish && usermod -aG varnish $user || true

# setting up project from `src` folder
RUN chmod -R 775 $container_project_path
RUN chown -R $user:www-data $container_project_path

# changing user
USER $user

# setting work directory
WORKDIR $container_project_path
