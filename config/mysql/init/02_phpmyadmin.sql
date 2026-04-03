-- =============================================================
-- Banco de configuração do phpMyAdmin (armazenamento avançado)
-- Executado automaticamente na primeira subida do container
-- =============================================================

CREATE DATABASE IF NOT EXISTS `phpmyadmin`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

-- Usuário de controle exclusivo para o phpMyAdmin
CREATE USER IF NOT EXISTS 'pma'@'%' IDENTIFIED BY 'pmapass';
GRANT ALL PRIVILEGES ON `phpmyadmin`.* TO 'pma'@'%';
FLUSH PRIVILEGES;

USE `phpmyadmin`;

-- Tabelas de configuração do phpMyAdmin
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
  `id`       int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `dbase`    varchar(255) NOT NULL DEFAULT '',
  `user`     varchar(255) NOT NULL DEFAULT '',
  `label`    varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query`    text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__column_info` (
  `id`              int(5) UNSIGNED NOT NULL AUTO_INCREMENT,
  `db_name`         varchar(64) NOT NULL DEFAULT '',
  `table_name`      varchar(64) NOT NULL DEFAULT '',
  `column_name`     varchar(64) NOT NULL DEFAULT '',
  `comment`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation`  varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
  `username`  varchar(64) NOT NULL DEFAULT '',
  `settings_data` text NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__export_templates` (
  `id`        int(5) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username`  varchar(64) NOT NULL DEFAULT '',
  `export_type` varchar(10) NOT NULL DEFAULT '',
  `template_name` varchar(64) NOT NULL DEFAULT '',
  `template_data` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__favorite` (
  `username`  varchar(64) NOT NULL DEFAULT '',
  `tables`    text NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__history` (
  `id`        bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username`  varchar(64) NOT NULL DEFAULT '',
  `db`        varchar(64) NOT NULL DEFAULT '',
  `table`     varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sqlquery`  text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`db`,`table`,`timevalue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
  `username`    varchar(64) NOT NULL DEFAULT '',
  `item_name`   varchar(64) NOT NULL DEFAULT '',
  `item_type`   varchar(64) NOT NULL DEFAULT '',
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `table_name`  varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
  `page_nr`     int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `page_descr`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`page_nr`),
  KEY `page_descr` (`page_descr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__recent` (
  `username`  varchar(64) NOT NULL DEFAULT '',
  `tables`    text NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__relation` (
  `master_db`     varchar(64) NOT NULL DEFAULT '',
  `master_table`  varchar(64) NOT NULL DEFAULT '',
  `master_field`  varchar(64) NOT NULL DEFAULT '',
  `foreign_db`    varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`master_db`,`master_table`,`master_field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
  `id`          int(5) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username`    varchar(64) NOT NULL DEFAULT '',
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__table_coords` (
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `table_name`  varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `x`           float UNSIGNED NOT NULL DEFAULT 0,
  `y`           float UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__table_info` (
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `table_name`  varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
  `username`    varchar(64) NOT NULL DEFAULT '',
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `table_name`  varchar(64) NOT NULL DEFAULT '',
  `prefs`       text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`username`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__tracking` (
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `table_name`  varchar(64) NOT NULL DEFAULT '',
  `version`     int(10) UNSIGNED NOT NULL DEFAULT 0,
  `date_created`   datetime NOT NULL,
  `date_updated`   datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql`  text,
  `data_sql`    longtext,
  `tracking`    set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`db_name`,`table_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__userconfig` (
  `username`    varchar(64) NOT NULL DEFAULT '',
  `timevalue`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `config_data` text NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__usergroups` (
  `usergroup`   varchar(64) NOT NULL DEFAULT '',
  `tab`         varchar(64) NOT NULL DEFAULT '',
  `allowed`     enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`usergroup`,`tab`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__central_columns` (
  `db_name`     varchar(64) NOT NULL DEFAULT '',
  `col_name`    varchar(64) NOT NULL DEFAULT '',
  `col_type`    varchar(64) NOT NULL DEFAULT '',
  `col_length`  text,
  `col_collation` varchar(64) NOT NULL DEFAULT '',
  `col_isNull`  enum('YES','NO') NOT NULL DEFAULT 'YES',
  `col_extra`   varchar(255) DEFAULT '',
  `col_default` text,
  PRIMARY KEY (`db_name`,`col_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `pma__users` (
  `username`    varchar(64) NOT NULL DEFAULT '',
  `usergroup`   varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`username`,`usergroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
