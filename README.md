# Ambiente de Desenvolvimento Docker

Ambiente completo para desenvolvimento web com **PHP 8.3**, **Apache**, **Nginx**, **MySQL**, **MariaDB** e **PostgreSQL**, orquestrado com Docker Compose.

---

## Estrutura de pastas

```
ambiente_docker/
├── docker-compose.yml        # Orquestração dos serviços
├── Dockerfile                # PHP 8.3 + Apache
├── Dockerfile.nginx          # PHP 8.3-FPM + Nginx
├── Makefile                  # Atalhos de comandos
├── .env                      # Variáveis de ambiente (senhas, portas)
├── config/
│   ├── apache/
│   │   └── vhost.conf        # VirtualHost Apache
│   ├── nginx/
│   │   ├── default.conf      # Server block Nginx
│   │   └── start.sh          # Script de inicialização (FPM + Nginx)
│   ├── php/
│   │   └── custom.ini        # Configurações PHP (erros, Xdebug, etc.)
│   └── mysql/
│       └── init/
│           └── 01_schema.sql # Script SQL executado na primeira subida
└── www/                      # Raiz dos seus projetos (bind mount)
    ├── index.php             # Página de status do ambiente
    └── phpinfo.php           # Informações do PHP
```

---

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) ≥ 24
- [Docker Compose](https://docs.docker.com/compose/install/) ≥ 2.20 (plugin `docker compose`)
- `make` (opcional, mas recomendado)

---

## Subindo o ambiente

```bash
# 1. Clone ou copie este diretório
cd ambiente_docker

# 2. (Opcional) Ajuste senhas e portas no .env

# 3. Build e inicialização
make build
make up

# — ou sem make —
docker compose build
docker compose up -d
```

Aguarde o build das imagens (primeira vez demora alguns minutos).

---

## Serviços e portas

| Serviço     | URL / Endereço              | Porta padrão |
|-------------|-----------------------------|--------------|
| Apache/PHP  | http://localhost            | 80           |
| Nginx/PHP   | http://localhost:8080       | 8080         |
| phpMyAdmin  | http://localhost:8081       | 8081         |
| pgAdmin     | http://localhost:5050       | 5050         |
| MySQL       | localhost:3306              | 3306         |
| MariaDB     | localhost:3307              | 3307         |
| PostgreSQL  | localhost:5432              | 5432         |

> Para mudar portas, edite o arquivo `.env`.

---

## Credenciais padrão

### MySQL / MariaDB
| Campo    | Valor     |
|----------|-----------|
| Host     | `mysql` / `mariadb` (interno) ou `localhost` (externo) |
| Database | `app_db`  |
| User     | `dev`     |
| Password | `dev123`  |
| Root pw  | `root`    |

### PostgreSQL
| Campo    | Valor     |
|----------|-----------|
| Host     | `postgres` (interno) ou `localhost` (externo) |
| Database | `app_db`  |
| User     | `dev`     |
| Password | `dev123`  |

### pgAdmin
| Campo | Valor            |
|-------|------------------|
| Email | admin@dev.local  |
| Senha | admin123         |

---

## Conectando ferramentas externas (DBeaver, TablePlus…)

Use `localhost` como host e as portas expostas:

- MySQL → `localhost:3306`
- MariaDB → `localhost:3307`
- PostgreSQL → `localhost:5432`

---

## Desenvolvendo projetos

Coloque seus projetos dentro da pasta `www/`:

```
www/
├── index.php          ← página de status (pode substituir)
├── meu-projeto/
│   └── index.php
└── outro-projeto/
    └── index.php
```

Acesse em: `http://localhost/meu-projeto/`

As alterações são refletidas instantaneamente — **sem necessidade de rebuild**.

---

## Comandos úteis (Makefile)

```bash
make up              # Sobe todos os containers
make down            # Para os containers
make build           # Builda as imagens
make rebuild         # Rebuild sem cache (útil após mudar Dockerfile)
make status          # Lista containers
make logs            # Logs de todos os serviços
make logs s=web      # Logs de um serviço específico
make shell           # Shell no container Apache/PHP
make shell-nginx     # Shell no container Nginx/PHP
make mysql-cli       # Cliente MySQL interativo
make mariadb-cli     # Cliente MariaDB interativo
make postgres-cli    # psql interativo
make composer cmd="require laravel/framework"
make npm cmd="install"
make clean           # Remove volumes (apaga dados dos bancos!)
```

---

## Extensões PHP instaladas

`pdo`, `pdo_mysql`, `pdo_pgsql`, `mysqli`, `pgsql`, `gd`, `zip`, `mbstring`, `exif`, `bcmath`, `xml`, `curl`, `intl`, `opcache`, `redis`, `xdebug`

---

## Xdebug

Configurado no modo `develop,debug,coverage`. Para usar com VS Code, instale a extensão **PHP Debug** e crie `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/var/www/html": "${workspaceFolder}/www"
      }
    }
  ]
}
```

---

## Parando e limpando

```bash
# Para sem apagar dados
make down

# Para e apaga volumes (irreversível!)
make clean
```
