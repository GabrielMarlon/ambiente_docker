-- =============================================================
-- Script de inicialização do MySQL
-- Executado automaticamente na primeira subida do container
-- =============================================================

CREATE DATABASE IF NOT EXISTS `app_db`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `app_db`;

-- Exemplo de tabela
CREATE TABLE IF NOT EXISTS `usuarios` (
    `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nome`       VARCHAR(120) NOT NULL,
    `email`      VARCHAR(200) NOT NULL UNIQUE,
    `criado_em`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dados de exemplo
INSERT INTO `usuarios` (`nome`, `email`) VALUES
    ('Admin',       'admin@dev.local'),
    ('Usuário Demo','demo@dev.local')
ON DUPLICATE KEY UPDATE `nome` = VALUES(`nome`);
