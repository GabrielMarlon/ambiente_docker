<?php
declare(strict_types=1);

$services = [
    'MySQL'      => ['host' => 'mysql',    'port' => 3306, 'type' => 'mysql'],
    'MariaDB'    => ['host' => 'mariadb',  'port' => 3306, 'type' => 'mysql'],
    'PostgreSQL' => ['host' => 'postgres', 'port' => 5432, 'type' => 'pgsql'],
];

function checkDb(string $type, string $host, int $port): string {
    try {
        $dsn = $type === 'pgsql'
            ? "pgsql:host=$host;port=$port;dbname=app_db"
            : "mysql:host=$host;port=$port;dbname=app_db";
        $user = 'dev';
        $pass = 'dev123';
        $pdo  = new PDO($dsn, $user, $pass, [PDO::ATTR_TIMEOUT => 2]);
        return '<span style="color:#22c55e">&#10003; Conectado</span>';
    } catch (PDOException $e) {
        return '<span style="color:#ef4444">&#10007; ' . htmlspecialchars($e->getMessage()) . '</span>';
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ambiente de Desenvolvimento Docker</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: system-ui, -apple-system, sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }
        .card {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 2rem;
            max-width: 640px;
            width: 100%;
        }
        h1 { font-size: 1.5rem; color: #38bdf8; margin-bottom: .25rem; }
        .subtitle { color: #94a3b8; font-size: .875rem; margin-bottom: 2rem; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
        th, td { padding: .6rem .75rem; text-align: left; border-bottom: 1px solid #334155; font-size: .875rem; }
        th { color: #94a3b8; font-weight: 500; }
        .badge {
            display: inline-block;
            padding: .15rem .55rem;
            border-radius: 999px;
            font-size: .75rem;
            font-weight: 600;
            background: #0ea5e9;
            color: #fff;
        }
        .links a {
            display: inline-block;
            margin-right: .75rem;
            color: #38bdf8;
            text-decoration: none;
            font-size: .875rem;
        }
        .links a:hover { text-decoration: underline; }
        .info { font-size: .75rem; color: #64748b; margin-top: 1.5rem; }
    </style>
</head>
<body>
<div class="card">
    <h1>Ambiente Docker Dev</h1>
    <p class="subtitle">PHP <?= PHP_VERSION ?> &bull; <?= date('d/m/Y H:i:s') ?></p>

    <table>
        <thead>
            <tr><th>Serviço</th><th>Status PDO</th><th>Extensão</th></tr>
        </thead>
        <tbody>
        <?php foreach ($services as $name => $cfg): ?>
            <tr>
                <td><?= $name ?></td>
                <td><?= checkDb($cfg['type'], $cfg['host'], $cfg['port']) ?></td>
                <td><span class="badge"><?= $cfg['type'] === 'pgsql' ? 'pdo_pgsql' : 'pdo_mysql' ?></span></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

    <div class="links">
        <strong>Links:</strong>
        <a href="http://localhost:8081" target="_blank">phpMyAdmin</a>
        <a href="http://localhost:5050" target="_blank">pgAdmin</a>
        <a href="http://localhost:8080" target="_blank">Nginx</a>
        <a href="phpinfo.php">phpinfo()</a>
    </div>

    <p class="info">
        Coloque seus projetos dentro de <code>www/</code>.<br>
        Alterações são refletidas instantaneamente (bind mount).
    </p>
</div>
</body>
</html>
