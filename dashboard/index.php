<?php
declare(strict_types=1);

// ── Bancos de dados ──────────────────────────────────────────────────────────
$services = [
    'MySQL'   => ['host' => 'mysql',   'port' => 3306],
    'MariaDB' => ['host' => 'mariadb', 'port' => 3306],
];

function checkDb(string $host, int $port): array {
    try {
        new PDO("mysql:host=$host;port=$port", 'root', 'root', [PDO::ATTR_TIMEOUT => 2]);
        return ['online' => true];
    } catch (PDOException) {
        return ['online' => false];
    }
}

// ── Scan recursivo de /var/www/projects ──────────────────────────────────────
function scanProjects(string $dir, string $urlBase): array {
    $items = [];
    if (!is_dir($dir)) return $items;
    foreach (new DirectoryIterator($dir) as $entry) {
        if (!$entry->isDir() || $entry->isDot() || str_starts_with($entry->getFilename(), '.')) continue;
        $name     = $entry->getFilename();
        $fullPath = $dir . '/' . $name;
        $url      = $urlBase . '/' . $name;
        $hasIndex = file_exists($fullPath . '/index.php') || file_exists($fullPath . '/index.html');
        $items[]  = [
            'name'     => $name,
            'url'      => $url,
            'hasIndex' => $hasIndex,
            'children' => $hasIndex ? [] : scanProjects($fullPath, $url),
        ];
    }
    usort($items, fn($a, $b) => strcasecmp($a['name'], $b['name']));
    return $items;
}

function countProjects(array $items): int {
    $n = 0;
    foreach ($items as $item) $n += $item['hasIndex'] ? 1 : countProjects($item['children']);
    return $n;
}

function renderTree(array $items, int $depth = 0): void {
    if (empty($items)) return;
    $projects   = array_values(array_filter($items, fn($i) =>  $i['hasIndex']));
    $categories = array_values(array_filter($items, fn($i) => !$i['hasIndex']));

    if (!empty($projects)) {
        echo '<div class="proj-grid">';
        foreach ($projects as $p) {
            $href  = htmlspecialchars($p['url'] . '/');
            $label = htmlspecialchars($p['name']);
            echo "<a class=\"proj-card\" href=\"{$href}\" target=\"_blank\">"
               . '<svg class="proj-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>'
               . "<span>{$label}</span>"
               . '<svg class="ext-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>'
               . '</a>';
        }
        echo '</div>';
    }

    foreach ($categories as $cat) {
        $label = htmlspecialchars($cat['name']);
        $count = countProjects($cat['children']);
        $badge = $count > 0
               ? "<span class=\"cat-badge\">{$count}</span>"
               : '<span class="cat-badge cat-badge-empty">0</span>';

        echo "<details class=\"cat-details\">"
           . "<summary class=\"cat-summary\">"
           . '<svg class="chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>'
           . '<svg class="folder-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7z"/></svg>'
           . "<span class=\"cat-label\">{$label}</span>"
           . $badge
           . '</summary>';

        if (!empty($cat['children'])) {
            echo '<div class="cat-children">';
            renderTree($cat['children'], $depth + 1);
            echo '</div>';
        } else {
            echo '<p class="cat-empty">Pasta vazia — nenhum projeto ou subpasta encontrado.</p>';
        }
        echo '</details>';
    }
}

$tree  = scanProjects('/var/www/projects', '/www');
$total = countProjects($tree);

$currentHost = strtok($_SERVER['HTTP_HOST'] ?? 'localhost', ':');
$pmaUrl      = 'http://' . $currentHost . ':8081';

$dbResults = [];
foreach ($services as $name => $cfg) {
    $dbResults[$name] = checkDb($cfg['host'], $cfg['port']);
    $dbResults[$name]['host'] = $cfg['host'];
    $dbResults[$name]['port'] = $cfg['port'];
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dev Environment</title>
    <link rel="stylesheet" href="dashboard.css">
</head>
<body>

<!-- ── Topbar ──────────────────────────────────────────────────────────────── -->
<header class="topbar">
    <div class="topbar-inner">
        <div class="brand">
            <span class="brand-pulse"></span>
            <span class="brand-name">Dev Environment</span>
            <span class="brand-tag">local</span>
        </div>
        <div class="topbar-meta">
            <span class="meta-pill">PHP <?= PHP_VERSION ?></span>
            <span class="meta-time" id="clock"><?= date('H:i:s') ?></span>
        </div>
    </div>
</header>

<!-- ── Conteúdo ────────────────────────────────────────────────────────────── -->
<main class="main">

    <!-- Linha: Bancos + Ferramentas -->
    <div class="row">

        <!-- Bancos de dados -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                        <ellipse cx="12" cy="5" rx="9" ry="3"/>
                        <path d="M3 5v14c0 1.657 4.03 3 9 3s9-1.343 9-3V5"/>
                        <path d="M3 12c0 1.657 4.03 3 9 3s9-1.343 9-3"/>
                    </svg>
                    Databases
                </span>
            </div>
            <div class="card-body">
                <table class="db-table">
                    <thead>
                        <tr>
                            <th>Serviço</th>
                            <th>Status</th>
                            <th>Host</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php foreach ($dbResults as $name => $res): ?>
                        <tr>
                            <td><?= $name ?></td>
                            <td>
                                <?php if ($res['online']): ?>
                                    <span class="status status-online">
                                        <span class="status-dot"></span>Online
                                    </span>
                                <?php else: ?>
                                    <span class="status status-offline">
                                        <span class="status-dot"></span>Offline
                                    </span>
                                <?php endif; ?>
                            </td>
                            <td class="col-host"><?= $res['host'] ?>:<?= $res['port'] ?></td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Ferramentas -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                        <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
                    </svg>
                    Tools
                </span>
            </div>
            <div class="card-body">
                <div class="tools-list">
                    <a class="tool-link" href="<?= htmlspecialchars($pmaUrl) ?>" target="_blank">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <rect x="3" y="3" width="18" height="18" rx="2"/>
                            <path d="M3 9h18M9 21V9"/>
                        </svg>
                        phpMyAdmin
                        <span class="tool-badge">:8081</span>
                    </a>
                    <a class="tool-link" href="phpinfo.php" target="_blank">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="12" y1="8" x2="12" y2="12"/>
                            <line x1="12" y1="16" x2="12.01" y2="16"/>
                        </svg>
                        phpinfo()
                    </a>
                </div>
            </div>
        </div>

    </div>

    <!-- Projetos -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7z"/>
                </svg>
                Projects
            </span>
            <?php if ($total > 0): ?>
                <span class="count-pill">
                    <?= $total ?> <?= $total === 1 ? 'projeto' : 'projetos' ?>
                </span>
            <?php endif; ?>
        </div>
        <div class="card-body">
            <?php if (empty($tree)): ?>
                <p class="empty-root">
                    Nenhuma pasta encontrada. Crie um diretório dentro de <code>www/</code> para ele aparecer aqui.
                </p>
            <?php else: ?>
                <?php renderTree($tree); ?>
            <?php endif; ?>
        </div>
    </div>

</main>

<script>
    // Atualiza o relógio a cada segundo
    const clock = document.getElementById('clock');
    setInterval(() => {
        const now = new Date();
        clock.textContent = now.toLocaleTimeString('pt-BR', { hour12: false });
    }, 1000);
</script>
</body>
</html>
