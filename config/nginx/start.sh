#!/bin/sh
# Inicia PHP-FPM em background e Nginx em foreground
php-fpm -D
nginx -g "daemon off;"
