FROM node:20 AS frontend-builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY resources ./resources/
COPY vite.config.js ./
RUN npm run build

FROM php:8.2-fpm AS final

RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*
 	
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer 

WORKDIR /var/www/html

COPY . .
COPY --from=frontend-builder /app/public/build ./public/build
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
