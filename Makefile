# =============================================================
# Makefile — atalhos para o ambiente Docker de desenvolvimento
# =============================================================
.PHONY: help up down build rebuild logs shell shell-nginx \
        mysql-cli mariadb-cli postgres-cli composer npm status clean info

COMPOSE = docker compose
WEB     = dev_web_apache
NGINX   = dev_web_nginx

# Exibe esta ajuda
help:
	@echo ""
	@echo "  Ambiente de desenvolvimento Docker"
	@echo "  ─────────────────────────────────"
	@echo "  make up           Sobe todos os containers"
	@echo "  make down         Para e remove os containers"
	@echo "  make build        Builda as imagens customizadas"
	@echo "  make rebuild      Rebuild sem cache"
	@echo "  make status       Lista containers e status"
	@echo "  make logs         Exibe logs de todos os serviços"
	@echo "  make logs s=web   Exibe logs de um serviço específico"
	@echo "  make shell        Abre shell no container Apache/PHP"
	@echo "  make shell-nginx  Abre shell no container Nginx/PHP"
	@echo "  make mysql-cli    Abre cliente MySQL"
	@echo "  make mariadb-cli  Abre cliente MariaDB"
	@echo "  make postgres-cli Abre cliente PostgreSQL (psql)"
	@echo "  make composer cmd='install'   Roda Composer no container web"
	@echo "  make npm cmd='install'        Roda npm no container web"
	@echo "  make clean        Remove volumes de dados (CUIDADO!)"
	@echo ""

# Inicia o ambiente e exibe informações de acesso
up:
	$(COMPOSE) up -d
	@bash scripts/info.sh

# Exibe informações de acesso sem subir o ambiente
info:
	@bash scripts/info.sh

# Para o ambiente
down:
	$(COMPOSE) down

# Builda as imagens
build:
	$(COMPOSE) build

# Rebuild sem cache
rebuild:
	$(COMPOSE) build --no-cache

# Status dos containers
status:
	$(COMPOSE) ps

# Logs (todos ou de um serviço: make logs s=web)
logs:
	$(COMPOSE) logs -f $(s)

# Shell no container Apache
shell:
	docker exec -it $(WEB) bash

# Shell no container Nginx
shell-nginx:
	docker exec -it $(NGINX) bash

# CLI MySQL
mysql-cli:
	docker exec -it dev_mysql mysql -u root -p

# CLI MariaDB
mariadb-cli:
	docker exec -it dev_mariadb mariadb -u root -p

# CLI PostgreSQL
postgres-cli:
	docker exec -it dev_postgres psql -U dev -d app_db

# Composer (ex: make composer cmd="require vendor/pkg")
composer:
	docker exec -it $(WEB) composer $(cmd)

# npm (ex: make npm cmd="run build")
npm:
	docker exec -it $(WEB) npm $(cmd)

# CUIDADO: remove volumes persistentes dos bancos
clean:
	@read -p "Isso apagará todos os dados dos bancos. Confirmar? [s/N] " ans; \
	[ "$$ans" = "s" ] && $(COMPOSE) down -v || echo "Operação cancelada."
