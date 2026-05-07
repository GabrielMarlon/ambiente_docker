#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Seleciona qual app Node.js será executado.
# - Procura package.json em www/ (ignora node_modules)
# - Salva NODE_PROJECT no .env
# ────────────────────────────────────────────────────────────────

BOLD='\033[1m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
WWW_DIR="$ROOT_DIR/www"
ENV_FILE="$ROOT_DIR/.env"

echo ""
echo -e "${CYAN}${BOLD}  Qual app Node.js executar?${RESET}"
echo -e "  ─────────────────────────────"
echo ""

# Monta lista de projetos Node.js (tem package.json, fora de node_modules)
paths=()
names=()

while IFS= read -r pkg; do
    dir=$(dirname "$pkg")
    rel="${dir#$WWW_DIR/}"
    paths+=("$rel")
    names+=("$(basename "$dir")  ${DIM}↳ www/$rel${RESET}")
done < <(find "$WWW_DIR" -mindepth 2 -maxdepth 6 -name "package.json" \
            ! -path "*/node_modules/*" 2>/dev/null | sort)

if [ ${#paths[@]} -eq 0 ]; then
    echo -e "  ${YELLOW}Nenhum projeto Node.js encontrado em www/${RESET}"
    echo -e "  ${DIM}(busca por package.json, ignora node_modules)${RESET}"
    echo ""
    exit 0
fi

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
label="$(basename "$selected")"

# Persiste NODE_PROJECT no .env
if grep -q '^NODE_PROJECT=' "$ENV_FILE" 2>/dev/null; then
    sed -i "s|^NODE_PROJECT=.*|NODE_PROJECT=$selected|" "$ENV_FILE"
else
    printf '\nNODE_PROJECT=%s\n' "$selected" >> "$ENV_FILE"
fi

echo -e "  ${GREEN}✔${RESET}  ${BOLD}$label${RESET}"
echo ""
