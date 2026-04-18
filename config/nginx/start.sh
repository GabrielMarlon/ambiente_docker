#!/bin/sh
# Inicia PHP-FPM em background e Nginx em foreground

# Dá permissão de leitura ao socket do Docker para o PHP-FPM (www-data)
chmod 666 /var/run/docker.sock 2>/dev/null || true

php-fpm -D
nginx -g "daemon off;"
