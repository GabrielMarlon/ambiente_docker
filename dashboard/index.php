<?php
declare(strict_types=1);

// --- Bancos de dados ---
$services = [
    'MySQL'   => ['host' => 'mysql',   'port' => 3306],
    'MariaDB' => ['host' => 'mariadb', 'port' => 3306],
];

function checkDb(string $host, int $port): string {
    try {
        $pdo = new PDO(
            "mysql:host=$host;port=$port",
            'root', 'root',
            [PDO::ATTR_TIMEOUT => 2]
        );
        return '<span class="ok">&#10003; Online</span>';
    } catch (PDOException) {
        return '<span class="err">&#10007; Offline</span>';
    }
}

// --- Projetos: escaneia subpastas de /var/www/html/www ---
$projects = [];
$root     = '/var/www/projects';

foreach (new DirectoryIterator($root) as $item) {
    if (!$item->isDir() || $item->isDot() || str_starts_with($item->getFilename(), '.')) {
        continue;
    }
    $name = $item->getFilename();
    $projects[] = $name;
}
natcasesort($projects);
$projects = array_values($projects);
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ambiente Docker Dev</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: system-ui, -apple-system, sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            min-height: 100vh;
            padding: 2.5rem 1.5rem;
        }

        .layout {
            max-width: 900px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.25rem;
        }

        @media (max-width: 640px) { .layout { grid-template-columns: 1fr; } }

        .card {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 1.5rem;
        }

        .card-full { grid-column: 1 / -1; }

        h1 { font-size: 1.4rem; color: #38bdf8; margin-bottom: .2rem; }
        .subtitle { color: #64748b; font-size: .8rem; margin-bottom: 1.5rem; }
        h2 { font-size: .7rem; font-weight: 600; text-transform: uppercase;
             letter-spacing: .08em; color: #64748b; margin-bottom: 1rem; }

        /* Tabela de serviços */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: .5rem .6rem; text-align: left;
                 border-bottom: 1px solid #273349; font-size: .82rem; }
        th { color: #64748b; font-weight: 500; }
        tr:last-child td { border-bottom: none; }
        .ok  { color: #22c55e; }
        .err { color: #ef4444; }

        /* Links de ferramentas */
        .tools { display: flex; flex-direction: column; gap: .5rem; }
        .tool-link {
            display: flex; align-items: center; gap: .6rem;
            padding: .5rem .75rem;
            background: #0f172a;
            border: 1px solid #273349;
            border-radius: 8px;
            color: #e2e8f0;
            text-decoration: none;
            font-size: .82rem;
            transition: border-color .15s;
        }
        .tool-link:hover { border-color: #38bdf8; color: #38bdf8; }
        .tool-link .port { margin-left: auto; color: #475569; font-size: .75rem; }

        /* Grade de projetos */
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: .75rem;
        }

        .project-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: .5rem;
            padding: 1.1rem .75rem;
            background: #0f172a;
            border: 1px solid #273349;
            border-radius: 10px;
            text-decoration: none;
            color: #e2e8f0;
            font-size: .82rem;
            font-weight: 500;
            text-align: center;
            transition: border-color .15s, background .15s;
            word-break: break-word;
        }
        .project-card:hover { border-color: #38bdf8; background: #162032; }
        .project-card .icon { font-size: 1.6rem; line-height: 1; }

        .empty { color: #475569; font-size: .82rem; }
    </style>
</head>
<body>
<div class="layout">

    <!-- Cabeçalho -->
    <div class="card card-full">
        <h1>Ambiente Docker Dev</h1>
        <p class="subtitle">PHP <?= PHP_VERSION ?> &bull; <?= date('d/m/Y H:i:s') ?></p>
    </div>

    <!-- Status dos bancos -->
    <div class="card">
        <h2>Bancos de dados</h2>
        <table>
            <thead><tr><th>Serviço</th><th>Status</th><th>Host</th></tr></thead>
            <tbody>
            <?php foreach ($services as $name => $cfg): ?>
                <tr>
                    <td><?= $name ?></td>
                    <td><?= checkDb($cfg['host'], $cfg['port']) ?></td>
                    <td style="color:#475569"><?= $cfg['host'] ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <!-- Ferramentas -->
    <div class="card">
        <h2>Ferramentas</h2>
        <div class="tools">
            <a class="tool-link" href="http://localhost:8081" target="_blank">
                &#128200; phpMyAdmin
                <span class="port">:8081</span>
            </a>
            <a class="tool-link" href="phpinfo.php" target="_blank">
                &#128196; phpinfo()
            </a>
        </div>
    </div>

    <!-- Projetos -->
    <div class="card card-full">
        <h2>Projetos em www/</h2>
        <?php if (empty($projects)): ?>
            <p class="empty">Nenhuma pasta encontrada. Crie um diretório dentro de <code>www/</code> para ele aparecer aqui.</p>
        <?php else: ?>
            <div class="projects-grid">
            <?php foreach ($projects as $project): ?>
                <a class="project-card" href="/www/<?= htmlspecialchars($project) ?>/" target="_blank">
                    <span class="icon">&#128193;</span>
                    <?= htmlspecialchars($project) ?>
                </a>
            <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>

</div>
</body>
</html>
