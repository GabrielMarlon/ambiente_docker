# =============================================================
# Makefile — atalhos para o ambiente Docker de desenvolvimento
# =============================================================
.PHONY: help apache nginx down build rebuild logs shell \
        mysql-cli mariadb-cli composer npm status clean info \
        ngrok ngrok-apache ngrok-nginx ngrok-stop ngrok-url ngrok-project \
        node node-stop node-shell node-logs node-project

COMPOSE = docker compose

# Servidor ativo (lido do .env ou padrão apache)
WEB_SERVER ?= $(shell grep '^WEB_SERVER=' .env 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
WEB_SERVER  := $(if $(WEB_SERVER),$(WEB_SERVER),apache)

# Container do servidor ativo
ifeq ($(WEB_SERVER),nginx)
  WEB_CONTAINER  = dev_web_nginx
  NGROK_CONTAINER = nginx
else
  WEB_CONTAINER  = dev_web_apache
  NGROK_CONTAINER = web
endif

# Exibe esta ajuda
help:
	@echo ""
	@echo "  Ambiente de desenvolvimento Docker"
	@echo "  ─────────────────────────────────"
	@echo "  make apache            Sobe com PHP + Apache  (porta 80)"
	@echo "  make nginx             Sobe com PHP + Nginx   (porta 80)"
	@echo "  make down              Para e remove todos os containers"
	@echo "  make build             Builda as imagens"
	@echo "  make rebuild           Rebuild sem cache"
	@echo "  make status            Lista containers"
	@echo "  make info              Exibe informações de acesso"
	@echo "  make logs              Logs de todos os serviços"
	@echo "  make logs s=web        Logs de um serviço específico"
	@echo "  make shell             Shell no container web ativo"
	@echo "  make mysql-cli         Cliente MySQL interativo"
	@echo "  make mariadb-cli       Cliente MariaDB interativo"
	@echo "  make composer cmd='install'"
	@echo "  make npm cmd='install'"
	@echo "  make clean             Remove volumes (CUIDADO!)"
	@echo ""
	@echo "  Servidor ativo: $(WEB_SERVER)"
	@echo ""
	@echo "  Túnel público (ngrok)"
	@echo "  ─────────────────────────────────"
	@echo "  make ngrok             Sobe ngrok com o servidor ativo (pede projeto)"
	@echo "  make ngrok-apache      Sobe Apache + ngrok (pede projeto)"
	@echo "  make ngrok-nginx       Sobe Nginx  + ngrok (pede projeto)"
	@echo "  make ngrok-project     Troca o projeto exposto sem reiniciar"
	@echo "  make ngrok-stop        Para o container ngrok"
	@echo "  make ngrok-url         Exibe a URL pública do ngrok"
	@echo ""
	@echo "  Node.js"
	@echo "  ─────────────────────────────────"
	@echo "  make node              Sobe app Node.js (seleciona projeto)"
	@echo "  make node-stop         Para o container Node.js"
	@echo "  make node-shell        Shell no container Node.js"
	@echo "  make node-logs         Logs do app Node.js"
	@echo "  make node-project      Troca o projeto Node.js e reinicia"
	@echo ""

# Sobe com Apache e grava no .env
apache:
	@sed -i 's/^WEB_SERVER=.*/WEB_SERVER=apache/' .env
	$(COMPOSE) --profile apache up -d
	@bash scripts/info.sh

# Sobe com Nginx e grava no .env
nginx:
	@sed -i 's/^WEB_SERVER=.*/WEB_SERVER=nginx/' .env
	$(COMPOSE) --profile nginx up -d
	@bash scripts/info.sh

# Sobe ngrok com o servidor ativo (lê WEB_SERVER do .env)
ngrok:
	@bash scripts/ngrok-select.sh
	NGROK_TARGET=$(NGROK_CONTAINER) $(COMPOSE) --profile $(WEB_SERVER) --profile ngrok up -d
	@bash scripts/info.sh

# Sobe com Apache + ngrok e grava no .env
ngrok-apache:
	@bash scripts/ngrok-select.sh
	@sed -i 's/^WEB_SERVER=.*/WEB_SERVER=apache/' .env
	NGROK_TARGET=web $(COMPOSE) --profile apache --profile ngrok up -d
	@bash scripts/info.sh

# Sobe com Nginx + ngrok e grava no .env
ngrok-nginx:
	@bash scripts/ngrok-select.sh
	@sed -i 's/^WEB_SERVER=.*/WEB_SERVER=nginx/' .env
	NGROK_TARGET=nginx $(COMPOSE) --profile nginx --profile ngrok up -d
	@bash scripts/info.sh

# Troca o projeto exposto sem reiniciar (apenas atualiza o .env e exibe a URL)
ngrok-project:
	@bash scripts/ngrok-select.sh
	@bash scripts/info.sh

# Para o container ngrok
ngrok-stop:
	$(COMPOSE) --profile ngrok stop ngrok

# Exibe a URL pública atual do ngrok
ngrok-url:
	@curl -s http://localhost:$${PORT_NGROK:-4040}/api/tunnels 2>/dev/null \
	    | grep -o '"public_url":"[^"]*"' | grep https \
	    | cut -d'"' -f4 | xargs -I{} echo "  URL pública: {}" \
	    || echo "  ngrok não está rodando ou ainda está inicializando..."

# Sobe app Node.js (seleciona projeto interativamente)
node:
	@bash scripts/node-select.sh
	$(COMPOSE) --profile node up -d
	@bash scripts/info.sh

# Para o container Node.js
node-stop:
	$(COMPOSE) stop node

# Shell no container Node.js
node-shell:
	docker exec -it dev_node sh

# Logs do app Node.js
node-logs:
	$(COMPOSE) logs -f node

# Troca o projeto Node.js e reinicia o container
node-project:
	@bash scripts/node-select.sh
	@docker restart dev_node 2>/dev/null \
	    && echo "  Container reiniciado com novo projeto." \
	    || echo "  Container nao esta rodando. Use: make node"

# Para todos os containers (todos os profiles)
down:
	$(COMPOSE) --profile apache --profile nginx --profile ngrok --profile node down

# Builda as imagens
build:
	$(COMPOSE) --profile apache --profile nginx build

# Rebuild sem cache
rebuild:
	$(COMPOSE) --profile apache --profile nginx build --no-cache

# Status dos containers
status:
	$(COMPOSE) ps

# Exibe informações de acesso
info:
	@bash scripts/info.sh

# Logs (todos ou de um serviço: make logs s=web)
logs:
	$(COMPOSE) logs -f $(s)

# Shell no container web ativo
shell:
	docker exec -it $(WEB_CONTAINER) bash

# CLI MySQL
mysql-cli:
	docker exec -it dev_mysql mysql -u root -p

# CLI MariaDB
mariadb-cli:
	docker exec -it dev_mariadb mariadb -u root -p

# Composer
composer:
	docker exec -it $(WEB_CONTAINER) composer $(cmd)

# npm
npm:
	docker exec -it $(WEB_CONTAINER) npm $(cmd)

# CUIDADO: remove volumes persistentes dos bancos
clean:
	@read -p "Isso apagará todos os dados dos bancos. Confirmar? [s/N] " ans; \
	[ "$$ans" = "s" ] && $(COMPOSE) --profile apache --profile nginx down -v || echo "Operação cancelada."
