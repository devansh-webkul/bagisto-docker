# ---------------------------------------------------------------------------------------
# Main Image
# ---------------------------------------------------------------------------------------
FROM ubuntu:24.04


# ---------------------------------------------------------------------------------------
# ARGs
# ---------------------------------------------------------------------------------------
ARG container_project_path
ARG uid
ARG user


# ---------------------------------------------------------------------------------------
# ENVs
# ---------------------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC


# ---------------------------------------------------------------------------------------
# System Dependencies (Ubuntu 24.04 ships PHP 8.3 natively; PHP 8.4 comes from
# the ondrej/php PPA)
# ---------------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    gosu\
    imagemagick \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg-turbo8-dev \
    libmagickwand-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    nano \
    nginx \
    procps \
    software-properties-common \
    supervisor \
    unzip \
    zlib1g-dev \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update && apt-get install -y \
    php8.4 \
    php8.4-bcmath \
    php8.4-calendar \
    php8.4-cli \
    php8.4-curl \
    php8.4-dev \
    php8.4-exif \
    php8.4-fpm \
    php8.4-gd \
    php8.4-gmp \
    php8.4-intl \
    php8.4-mbstring \
    php8.4-mysql \
    php8.4-pdo \
    php8.4-soap \
    php8.4-sockets \
    php8.4-xml \
    php8.4-zip \
    php8.4-imagick \
    && rm -rf /var/lib/apt/lists/*


# ---------------------------------------------------------------------------------------
# Composer
# ---------------------------------------------------------------------------------------
COPY --from=composer:2.9 /usr/bin/composer /usr/local/bin/composer


# ---------------------------------------------------------------------------------------
# Node JS & Global NPM Dependencies
# ---------------------------------------------------------------------------------------
COPY --from=node:24 /usr/local/bin/node /usr/local/bin/node
COPY --from=node:24 /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && npm install -g laravel-echo-server opencode-ai


# ---------------------------------------------------------------------------------------
# PHP Configuration
# ---------------------------------------------------------------------------------------
COPY ./configs/php/php.ini /etc/php/8.4/fpm/php.ini


# ---------------------------------------------------------------------------------------
# Nginx Configuration
# ---------------------------------------------------------------------------------------
COPY ./configs/nginx/pools/www.cnf /etc/php/8.4/fpm/pool.d/www.conf
COPY ./configs/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./configs/nginx/conf.d/ /etc/nginx/conf.d/
COPY ./configs/nginx/snippets/ /etc/nginx/snippets/
COPY ./configs/nginx/sites/ /etc/nginx/sites/


# ---------------------------------------------------------------------------------------
# Project User Setup
# ---------------------------------------------------------------------------------------
RUN useradd -G www-data,root -u $uid -d /home/$user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user \
    && usermod -aG $user www-data


# ---------------------------------------------------------------------------------------
# Composer Cache — Accessible By Both Root And Project User
# ---------------------------------------------------------------------------------------
RUN mkdir -p /root/.composer \
    && mkdir -p /home/$user/.composer \
    && chmod -R 775 /root/.composer \
    && chown -R $user:$user /home/$user/.composer


# ---------------------------------------------------------------------------------------
# Runtime Directories (Created At Build Time So Permissions Are Correct)
# ---------------------------------------------------------------------------------------
RUN mkdir -p /run/php \
    && mkdir -p /var/www/html \
    && chown -R $user:$user /var/www/html \
    && chmod -R 775 /var/www/html \
    && chmod g+s /var/www/html


# ---------------------------------------------------------------------------------------
# Sudo Setup For Project User
# ---------------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers    


# ---------------------------------------------------------------------------------------
# Git Configuration
# ---------------------------------------------------------------------------------------
RUN git config --system --add safe.directory '*' \
    && git config --system core.fileMode false


# ---------------------------------------------------------------------------------------
# Working Directory
# ---------------------------------------------------------------------------------------
WORKDIR $container_project_path


# ---------------------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------------------
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
