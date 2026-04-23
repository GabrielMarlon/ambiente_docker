# =============================================================
# Makefile — atalhos para o ambiente Docker de desenvolvimento
# =============================================================
.PHONY: help apache nginx down build rebuild logs shell \
        mysql-cli mariadb-cli composer npm status clean info

COMPOSE = docker compose

# Servidor ativo (lido do .env ou padrão apache)
WEB_SERVER ?= $(shell grep '^WEB_SERVER=' .env 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
WEB_SERVER  := $(if $(WEB_SERVER),$(WEB_SERVER),apache)

# Container do servidor ativo
ifeq ($(WEB_SERVER),nginx)
  WEB_CONTAINER = dev_web_nginx
else
  WEB_CONTAINER = dev_web_apache
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

# Para todos os containers (todos os profiles)
down:
	$(COMPOSE) --profile apache --profile nginx down

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
