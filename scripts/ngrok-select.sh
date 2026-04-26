#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Seleciona qual projeto será exposto via ngrok.
# - Salva NGROK_PROJECT no .env
# - Grava o redirect em config/nginx/ngrok-redirect.conf
#   e config/apache/ngrok-redirect.conf
# - Recarrega nginx/apache se já estiverem rodando
# ────────────────────────────────────────────────────────────────

BOLD='\033[1m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
DIM='\033[2m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
WWW_DIR="$ROOT_DIR/www"
ENV_FILE="$ROOT_DIR/.env"
NGINX_REDIRECT="$ROOT_DIR/config/nginx/ngrok-redirect.conf"
APACHE_REDIRECT="$ROOT_DIR/config/apache/ngrok-redirect.conf"

echo ""
echo -e "${CYAN}${BOLD}  Qual projeto expor via ngrok?${RESET}"
echo -e "  ──────────────────────────────"
echo ""

# --- Monta lista de projetos ---
paths=("")
names=("Dashboard  (raiz /)")

declare -A seen
while IFS= read -r entry; do
    dir=$(dirname "$entry")
    rel="${dir#$WWW_DIR/}"
    [ "${seen[$rel]+x}" ] && continue
    seen[$rel]=1
    paths+=("$rel")
    names+=("$(basename "$dir")  ${DIM}↳ www/$rel${RESET}")
done < <(find "$WWW_DIR" -mindepth 1 -maxdepth 6 \
            \( -name "index.php" -o -name "index.html" \) 2>/dev/null | sort)

# Exibe o menu
for i in "${!paths[@]}"; do
    echo -e "  ${GREEN}$((i+1)).${RESET}  ${names[$i]}"
done
echo ""

total="${#paths[@]}"
while true; do
    read -r -p "  Escolha [1-${total}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$total" ]; then
        break
    fi
    echo "  Opção inválida. Tente novamente."
done

selected="${paths[$((choice-1))]}"
# Nome limpo sem escape ANSI para exibição
label_clean="$(basename "${paths[$((choice-1))]:-Dashboard}")"
[ -z "$selected" ] && label_clean="Dashboard"

# --- Persiste no .env ---
if grep -q '^NGROK_PROJECT=' "$ENV_FILE" 2>/dev/null; then
    sed -i "s|^NGROK_PROJECT=.*|NGROK_PROJECT=$selected|" "$ENV_FILE"
else
    printf '\nNGROK_PROJECT=%s\n' "$selected" >> "$ENV_FILE"
fi

# --- Grava o redirect nas configs do servidor ---
if [ -n "$selected" ]; then
    cat > "$NGINX_REDIRECT" <<NGINX
# Gerado pelo ngrok-select.sh — não editar manualmente
location = / {
    return 302 /www/$selected/;
}
NGINX

    cat > "$APACHE_REDIRECT" <<APACHE
# Gerado pelo ngrok-select.sh — não editar manualmente
RedirectMatch 302 ^/$ /www/$selected/
APACHE
else
    # Dashboard: remove qualquer redirect anterior
    printf '# Gerado pelo ngrok-select.sh — sem redirect (Dashboard)\n' \
        > "$NGINX_REDIRECT"
    printf '# Gerado pelo ngrok-select.sh — sem redirect (Dashboard)\n' \
        > "$APACHE_REDIRECT"
fi

# --- Recarrega o servidor web se já estiver rodando ---
if docker exec dev_web_nginx nginx -s reload 2>/dev/null; then
    echo -e "  ${DIM}↺ Nginx recarregado${RESET}"
fi
if docker exec dev_web_apache service apache2 reload 2>/dev/null; then
    echo -e "  ${DIM}↺ Apache recarregado${RESET}"
fi

echo -e "  ${GREEN}✔${RESET}  ${BOLD}$label_clean${RESET}"
echo ""
