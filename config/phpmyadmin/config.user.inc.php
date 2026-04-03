<?php
// Collation padrão na tela de login e no formulário "Criar banco de dados"
$cfg['DefaultConnectionCollation'] = 'utf8mb4_general_ci';
$cfg['DefaultCharset']             = 'utf8mb4';
$cfg['DefaultCollation']           = 'utf8mb4_general_ci';

// --- Armazenamento de configurações avançadas ---
$cfg['Servers'][1]['pmadb']                    = 'phpmyadmin';
$cfg['Servers'][1]['controlhost']              = 'mysql';
$cfg['Servers'][1]['controlport']              = '3306';
$cfg['Servers'][1]['controluser']              = getenv('PMA_CONTROLUSER') ?: 'pma';
$cfg['Servers'][1]['controlpass']              = getenv('PMA_CONTROLPASS') ?: '';

$cfg['Servers'][1]['bookmarktable']            = 'pma__bookmark';
$cfg['Servers'][1]['relation']                 = 'pma__relation';
$cfg['Servers'][1]['table_info']               = 'pma__table_info';
$cfg['Servers'][1]['table_coords']             = 'pma__table_coords';
$cfg['Servers'][1]['pdf_pages']                = 'pma__pdf_pages';
$cfg['Servers'][1]['column_info']              = 'pma__column_info';
$cfg['Servers'][1]['history']                  = 'pma__history';
$cfg['Servers'][1]['table_uiprefs']            = 'pma__table_uiprefs';
$cfg['Servers'][1]['tracking']                 = 'pma__tracking';
$cfg['Servers'][1]['userconfig']               = 'pma__userconfig';
$cfg['Servers'][1]['recent']                   = 'pma__recent';
$cfg['Servers'][1]['favorite']                 = 'pma__favorite';
$cfg['Servers'][1]['users']                    = 'pma__users';
$cfg['Servers'][1]['usergroups']               = 'pma__usergroups';
$cfg['Servers'][1]['navigationhiding']         = 'pma__navigationhiding';
$cfg['Servers'][1]['savedsearches']            = 'pma__savedsearches';
$cfg['Servers'][1]['central_columns']          = 'pma__central_columns';
$cfg['Servers'][1]['designer_settings']        = 'pma__designer_settings';
$cfg['Servers'][1]['export_templates']         = 'pma__export_templates';
