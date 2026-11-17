FROM php:8.3-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libsqlite3-dev \
    libonig-dev \
    libxml2-dev \
    default-mysql-client \
    curl \
    && docker-php-ext-install \
       pdo \
       pdo_mysql \
       pdo_sqlite \
       mbstring \
       bcmath \
       zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm ci \
    && npm run build \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN chmod -R 775 storage bootstrap/cache

EXPOSE 10000

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-10000}
