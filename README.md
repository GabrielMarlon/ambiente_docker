# Ambiente de Desenvolvimento Docker

Ambiente completo para desenvolvimento web com **PHP 8.3**, **Apache**, **Nginx**, **MySQL** e **MariaDB**, orquestrado com Docker Compose.

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
│   ├── mysql/
│   │   ├── my.cnf            # Charset e collation padrão (utf8mb4_general_ci)
│   │   └── init/
│   │       └── 01_schema.sql # Script SQL executado na primeira subida
│   └── phpmyadmin/
│       └── config.user.inc.php # Collation padrão no phpMyAdmin
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

Ao final do `make up` as informações de acesso são exibidas automaticamente no terminal.

---

## Serviços e portas

| Serviço    | URL / Endereço        | Porta padrão |
|------------|-----------------------|--------------|
| Apache/PHP | http://localhost      | 80           |
| Nginx/PHP  | http://localhost:8080 | 8080         |
| phpMyAdmin | http://localhost:8081 | 8081         |
| MySQL      | localhost:3306        | 3306         |
| MariaDB    | localhost:3307        | 3307         |

> Para alterar portas, edite o arquivo `.env`.

---

## Credenciais padrão

### MySQL
| Campo    | Valor    |
|----------|----------|
| Host     | `mysql` (interno) · `localhost:3306` (externo) |
| User     | `dev`    |
| Password | `dev123` |
| Root pw  | `root`   |

### MariaDB
| Campo    | Valor    |
|----------|----------|
| Host     | `mariadb` (interno) · `localhost:3307` (externo) |
| User     | `dev`    |
| Password | `dev123` |
| Root pw  | `root`   |

### phpMyAdmin
| Campo    | Valor                    |
|----------|--------------------------|
| URL      | http://localhost:8081    |
| Servidor | `mysql`                  |
| Usuário  | `root` (ou `dev`)        |
| Senha    | `root` (ou `dev123`)     |

> A collation padrão ao criar banco está configurada como **utf8mb4_general_ci**.

---

## Conectando ferramentas externas (DBeaver, TablePlus…)

Use `localhost` como host e as portas expostas:

- MySQL → `localhost:3306`
- MariaDB → `localhost:3307`

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
make up                # Sobe todos os containers e exibe info de acesso
make down              # Para os containers
make build             # Builda as imagens
make rebuild           # Rebuild sem cache (útil após mudar Dockerfile)
make status            # Lista containers
make info              # Exibe informações de acesso novamente
make logs              # Logs de todos os serviços
make logs s=web        # Logs de um serviço específico
make shell             # Shell no container Apache/PHP
make shell-nginx       # Shell no container Nginx/PHP
make mysql-cli         # Cliente MySQL interativo
make mariadb-cli       # Cliente MariaDB interativo
make composer cmd="require laravel/framework"
make npm cmd="install"
make clean             # Remove volumes (apaga dados dos bancos!)
```

---

## Extensões PHP instaladas

`pdo`, `pdo_mysql`, `mysqli`, `gd`, `zip`, `mbstring`, `exif`, `bcmath`, `xml`, `curl`, `intl`, `opcache`, `redis`, `xdebug`

---

## Xdebug

Configurado no modo `develop,debug,coverage` na porta `9003`. Para usar com VS Code, instale a extensão **PHP Debug** e crie `.vscode/launch.json`:

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
