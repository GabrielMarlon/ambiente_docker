#!/usr/bin/env bash
# =============================================================
# Exibe informações de acesso após o ambiente subir
# =============================================================

BOLD='\033[1m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
DIM='\033[2m'
RESET='\033[0m'

ENV_FILE="$(dirname "$0")/../.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi

PORT_HTTP="${PORT_HTTP:-80}"
PORT_PHPMYADMIN="${PORT_PHPMYADMIN:-8081}"
PORT_MYSQL="${PORT_MYSQL:-3306}"
PORT_MARIADB="${PORT_MARIADB:-3307}"
PORT_NGROK="${PORT_NGROK:-4040}"
PORT_NODE="${PORT_NODE:-3000}"
NODE_PROJECT="${NODE_PROJECT:-}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
MYSQL_USER="${MYSQL_USER:-dev}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-dev123}"
MARIADB_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD:-root}"
MARIADB_USER="${MARIADB_USER:-dev}"
MARIADB_PASSWORD="${MARIADB_PASSWORD:-dev123}"
WEB_SERVER="${WEB_SERVER:-apache}"

wait_healthy() {
    local name="$1"
    local max=30 i=0
    printf "${DIM}  Aguardando %s ficar pronto..." "$name"
    while [ $i -lt $max ]; do
        status=$(docker inspect --format='{{.State.Health.Status}}' "$name" 2>/dev/null)
        [ "$status" = "healthy" ] && printf " ok${RESET}\n" && return 0
        sleep 2; i=$((i+1))
    done
    printf " timeout${RESET}\n"
}

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║        Ambiente de Desenvolvimento Docker            ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

wait_healthy dev_mysql
wait_healthy dev_mariadb

echo ""
echo -e "${BOLD}  Servidor Web${RESET}"
if [ "$WEB_SERVER" = "nginx" ]; then
    echo -e "  ${GREEN}►${RESET} Nginx  / PHP   ${CYAN}http://localhost:${PORT_HTTP}${RESET}"
else
    echo -e "  ${GREEN}►${RESET} Apache / PHP   ${CYAN}http://localhost:${PORT_HTTP}${RESET}"
fi
echo ""

LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
if [ -n "$LOCAL_IP" ]; then
    echo -e "${BOLD}  Acesso na rede local (celular/outros dispositivos)${RESET}"
    echo -e "  ${GREEN}►${RESET} Site        ${CYAN}http://${LOCAL_IP}:${PORT_HTTP}${RESET}"
    echo -e "  ${GREEN}►${RESET} phpMyAdmin  ${CYAN}http://${LOCAL_IP}:${PORT_PHPMYADMIN}${RESET}"
    echo ""
fi

echo -e "${BOLD}  Gerenciamento de Banco${RESET}"
echo -e "  ${GREEN}►${RESET} phpMyAdmin     ${CYAN}http://localhost:${PORT_PHPMYADMIN}${RESET}"
echo ""

echo -e "${BOLD}  Bancos de Dados${RESET}"
echo -e "  ${YELLOW}▸ MySQL${RESET}"
echo -e "    Host:     ${DIM}localhost:${PORT_MYSQL}${RESET}"
echo -e "    Database: ${DIM}${MYSQL_DATABASE}${RESET}"
echo -e "    Root:     ${DIM}root  /  ${MYSQL_ROOT_PASSWORD}${RESET}"
echo -e "    User:     ${DIM}${MYSQL_USER}  /  ${MYSQL_PASSWORD}${RESET}"

echo -e "  ${YELLOW}▸ MariaDB${RESET}"
echo -e "    Host:     ${DIM}localhost:${PORT_MARIADB}${RESET}"
echo -e "    Database: ${DIM}${MYSQL_DATABASE}${RESET}"
echo -e "    Root:     ${DIM}root  /  ${MARIADB_ROOT_PASSWORD}${RESET}"
echo -e "    User:     ${DIM}${MARIADB_USER}  /  ${MARIADB_PASSWORD}${RESET}"

echo ""
echo -e "${BOLD}  phpMyAdmin — Login${RESET}"
echo -e "  ${DIM}Servidor: mysql${RESET}"
echo -e "  ${DIM}Usuário:  root   Senha: ${MYSQL_ROOT_PASSWORD}${RESET}"
echo -e "  ${DIM}  —ou—${RESET}"
echo -e "  ${DIM}Usuário:  ${MYSQL_USER}   Senha: ${MYSQL_PASSWORD}${RESET}"
echo ""

NGROK_URL=$(curl -s "http://localhost:${PORT_NGROK}/api/tunnels" 2>/dev/null \
    | grep -o '"public_url":"[^"]*"' | grep https | cut -d'"' -f4)
if [ -n "$NGROK_URL" ]; then
    NGROK_PROJECT="${NGROK_PROJECT:-}"
    echo -e "${BOLD}  Túnel Público (ngrok)${RESET}"
    if [ -n "$NGROK_PROJECT" ]; then
        echo -e "  ${GREEN}►${RESET} Projeto       ${CYAN}${NGROK_URL}/www/${NGROK_PROJECT}/${RESET}"
        echo -e "  ${DIM}    (raiz)     ${NGROK_URL}${RESET}"
    else
        echo -e "  ${GREEN}►${RESET} URL pública   ${CYAN}${NGROK_URL}${RESET}"
    fi
    echo -e "  ${GREEN}►${RESET} Painel ngrok  ${CYAN}http://localhost:${PORT_NGROK}${RESET}"
    echo ""
fi

if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^dev_node$'; then
    echo -e "${BOLD}  Node.js${RESET}"
    echo -e "  ${GREEN}►${RESET} App            ${CYAN}http://localhost:${PORT_NODE}${RESET}"
    [ -n "$NODE_PROJECT" ] && echo -e "  ${DIM}    Projeto: www/${NODE_PROJECT}${RESET}"
    echo ""
fi

echo -e "${BLUE}${BOLD}  Dica:${RESET} ${DIM}make apache  |  make nginx  |  make node  |  make ngrok-nginx${RESET}"
echo ""
