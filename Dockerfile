FROM php:8.2-fpm

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libssl-dev \
    curl \
    npm \
    nodejs \
    libkrb5-dev \
    wget \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && curl -L -o c-client.tar.gz https://github.com/ThomasWaldmann/c-client/archive/refs/tags/2007f.tar.gz \
    && tar -xzf c-client.tar.gz \
    && cd c-client-2007f \
    && make lnp \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install intl pdo_mysql zip mbstring opcache gd imap

# Set git safe directory
RUN git config --global --add safe.directory /var/www/html

# Install Composer
COPY --from=composer:2.9 /usr/bin/composer /usr/bin/composer

# Copy source code
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader

# Install Node dependencies and build assets
RUN npm ci --prefer-offline --no-audit
RUN npm run build

EXPOSE 9000

CMD ["php-fpm"]
