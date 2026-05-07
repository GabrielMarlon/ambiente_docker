#!/bin/sh
# Entrypoint do container Node.js — seleciona o projeto e inicia o app

if [ -z "$NODE_PROJECT" ]; then
    printf '\n  NODE_PROJECT nao definido no .env.\n'
    printf '  Defina o projeto e rode: make node\n\n'
    sleep infinity
fi

APP_DIR="/app/projects/$NODE_PROJECT"

if [ ! -d "$APP_DIR" ]; then
    printf '\n  Pasta nao encontrada: www/%s\n' "$NODE_PROJECT"
    printf '  Verifique NODE_PROJECT no .env\n\n'
    sleep infinity
fi

cd "$APP_DIR" || exit 1

if [ ! -f "package.json" ]; then
    printf '\n  package.json nao encontrado em www/%s\n' "$NODE_PROJECT"
    printf '  Certifique-se de que eh um projeto Node.js valido.\n\n'
    sleep infinity
fi

printf '\n  >> Projeto : www/%s\n' "$NODE_PROJECT"
printf '  >> Porta   : %s\n' "${PORT:-3000}"
printf '  >> Comando : %s\n' "${NODE_CMD:-npm start}"
printf '  >> Instalando dependencias...\n\n'

npm install

printf '\n  >> Iniciando app...\n\n'
exec sh -c "${NODE_CMD:-npm start}"
