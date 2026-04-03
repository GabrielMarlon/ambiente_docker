# =============================================================
# PHP + Apache — imagem de desenvolvimento
# =============================================================
FROM php:8.3-apache

LABEL maintainer="dev@local"

# Dependências de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libpq-dev \
        libonig-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libicu-dev \
        unzip \
        zip \
        git \
        curl \
        nano \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

# Extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        mysqli \
        pgsql \
        gd \
        zip \
        mbstring \
        exif \
        bcmath \
        xml \
        curl \
        intl \
        opcache

# PECL: Redis + Xdebug
RUN pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite headers

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Document root padrão
ENV APACHE_DOCUMENT_ROOT=/var/www/html

# Permissões
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

EXPOSE 80
