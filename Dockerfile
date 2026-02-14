FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
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
    libc-client-dev \
    libimap-dev \
    curl \
    npm \
    nodejs \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install intl pdo_mysql zip mbstring opcache gd imap

# Set git safe directory
RUN git config --global --add safe.directory /var/www/html

# Install Composer
COPY --from=composer:2.9 /usr/bin/composer /usr/bin/composer

# Copy Mautic source code
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader

# Install Node dependencies and build assets
RUN npm ci --prefer-offline --no-audit
RUN npm run build

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
