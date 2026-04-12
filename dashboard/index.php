<?php
declare(strict_types=1);

// ── Bancos de dados ──────────────────────────────────────────────────────────
$services = [
    'MySQL'   => ['host' => 'mysql',   'port' => 3306],
    'MariaDB' => ['host' => 'mariadb', 'port' => 3306],
];

function checkDb(string $host, int $port): string {
    try {
        new PDO("mysql:host=$host;port=$port", 'root', 'root', [PDO::ATTR_TIMEOUT => 2]);
        return '<span class="ok">&#10003; Online</span>';
    } catch (PDOException) {
        return '<span class="err">&#10007; Offline</span>';
    }
}

// ── Scan recursivo de /var/www/projects ──────────────────────────────────────
//
// Regra:
//   • Pasta COM index.php ou index.html  → projeto  (card clicável)
//   • Pasta SEM index                    → categoria (expansível, escaneia filhos)
//
function scanProjects(string $dir, string $urlBase): array {
    $items = [];
    if (!is_dir($dir)) return $items;

    foreach (new DirectoryIterator($dir) as $entry) {
        if (!$entry->isDir() || $entry->isDot() || str_starts_with($entry->getFilename(), '.')) {
            continue;
        }
        $name     = $entry->getFilename();
        $fullPath = $dir . '/' . $name;
        $url      = $urlBase . '/' . $name;
        $hasIndex = file_exists($fullPath . '/index.php')
                 || file_exists($fullPath . '/index.html');

        $items[] = [
            'name'     => $name,
            'url'      => $url,
            'hasIndex' => $hasIndex,
            // só recorre em categorias (sem index)
            'children' => $hasIndex ? [] : scanProjects($fullPath, $url),
        ];
    }

    usort($items, fn($a, $b) => strcasecmp($a['name'], $b['name']));
    return $items;
}

// Conta projetos (folhas com index) recursivamente
function countProjects(array $items): int {
    $n = 0;
    foreach ($items as $item) {
        $n += $item['hasIndex'] ? 1 : countProjects($item['children']);
    }
    return $n;
}

// Renderiza a árvore como HTML
function renderTree(array $items): void {
    if (empty($items)) return;

    $projects   = array_values(array_filter($items, fn($i) =>  $i['hasIndex']));
    $categories = array_values(array_filter($items, fn($i) => !$i['hasIndex']));

    // projetos aparecem primeiro (grade de cards)
    if (!empty($projects)) {
        echo '<div class="projects-grid">';
        foreach ($projects as $p) {
            $href  = htmlspecialchars($p['url'] . '/');
            $label = htmlspecialchars($p['name']);
            echo "<a class=\"project-card\" href=\"{$href}\" target=\"_blank\">"
               . '<span class="p-icon">&#127760;</span>'
               . "<span>{$label}</span>"
               . '</a>';
        }
        echo '</div>';
    }

    // categorias aparecem depois (expansíveis)
    foreach ($categories as $cat) {
        $label = htmlspecialchars($cat['name']);
        $count = countProjects($cat['children']);
        $badge = $count > 0
               ? "<span class=\"badge\">{$count} " . ($count === 1 ? 'projeto' : 'projetos') . '</span>'
               : '<span class="badge badge-empty">vazia</span>';

        echo "<details class=\"category\">"
           . "<summary class=\"cat-header\">"
           . '<span class="cat-arrow">&#9656;</span>'
           . '<span class="cat-icon">&#128193;</span>'
           . "<span class=\"cat-name\">{$label}</span>"
           . $badge
           . '</summary>';

        if (!empty($cat['children'])) {
            echo '<div class="cat-body">';
            renderTree($cat['children']);
            echo '</div>';
        } else {
            echo '<p class="empty-cat">Pasta vazia — adicione projetos ou subpastas aqui.</p>';
        }

        echo '</details>';
    }
}

$tree  = scanProjects('/var/www/projects', '/www');
$total = countProjects($tree);

// URL do phpMyAdmin usando o mesmo host do request (funciona no celular via IP local)
$currentHost = strtok($_SERVER['HTTP_HOST'] ?? 'localhost', ':'); // remove porta se houver
$pmaUrl      = 'http://' . $currentHost . ':8081';
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
            max-width: 960px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.25rem;
        }

        @media (max-width: 640px) { .layout { grid-template-columns: 1fr; } }

        /* ── Cards base ─────────────────────────────────── */
        .card {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 1.5rem;
        }
        .card-full { grid-column: 1 / -1; }

        h1 { font-size: 1.4rem; color: #38bdf8; margin-bottom: .2rem; }
        .subtitle { color: #64748b; font-size: .8rem; margin-bottom: 1.5rem; }

        h2 {
            font-size: .7rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: .08em;
            color: #64748b; margin-bottom: 1rem;
            display: flex; align-items: center; gap: .5rem;
        }
        h2 .total {
            font-size: .68rem; background: #273349; color: #94a3b8;
            padding: .1rem .45rem; border-radius: 20px; font-weight: 500;
            text-transform: none; letter-spacing: 0;
        }

        /* ── Tabela de serviços ──────────────────────────── */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: .5rem .6rem; text-align: left;
                 border-bottom: 1px solid #273349; font-size: .82rem; }
        th { color: #64748b; font-weight: 500; }
        tr:last-child td { border-bottom: none; }
        .ok  { color: #22c55e; }
        .err { color: #ef4444; }

        /* ── Links de ferramentas ─────────────────────────── */
        .tools { display: flex; flex-direction: column; gap: .5rem; }
        .tool-link {
            display: flex; align-items: center; gap: .6rem;
            padding: .5rem .75rem;
            background: #0f172a; border: 1px solid #273349;
            border-radius: 8px; color: #e2e8f0;
            text-decoration: none; font-size: .82rem;
            transition: border-color .15s;
        }
        .tool-link:hover { border-color: #38bdf8; color: #38bdf8; }
        .tool-link .port { margin-left: auto; color: #475569; font-size: .75rem; }

        /* ── Grade de projetos (cards) ───────────────────── */
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: .65rem;
            margin-bottom: .5rem;
        }

        .project-card {
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            gap: .45rem; padding: 1rem .75rem;
            background: #0f172a; border: 1px solid #273349;
            border-radius: 10px; text-decoration: none;
            color: #e2e8f0; font-size: .8rem; font-weight: 500;
            text-align: center; word-break: break-word;
            transition: border-color .15s, background .15s;
        }
        .project-card:hover { border-color: #38bdf8; background: #162032; color: #38bdf8; }
        .p-icon { font-size: 1.5rem; line-height: 1; }

        /* ── Categoria (details/summary) ─────────────────── */
        .category {
            border: 1px solid #273349;
            border-radius: 10px;
            margin-top: .75rem;
            overflow: hidden;
        }

        /* remove o marcador padrão do navegador */
        .cat-header { list-style: none; }
        .cat-header::-webkit-details-marker { display: none; }

        .cat-header {
            display: flex; align-items: center; gap: .55rem;
            padding: .65rem 1rem;
            background: #152035; cursor: pointer;
            font-size: .82rem; font-weight: 600; color: #94a3b8;
            user-select: none;
            transition: background .15s, color .15s;
        }
        .cat-header:hover { background: #1c2d45; color: #e2e8f0; }

        .cat-arrow {
            font-size: .55rem; color: #475569;
            transition: transform .2s;
            display: inline-block;
        }
        details[open] > .cat-header .cat-arrow { transform: rotate(90deg); }

        .cat-icon  { font-size: 1rem; }
        .cat-name  { flex: 1; }

        .badge {
            font-size: .68rem; font-weight: 500;
            background: #1e3a5f; color: #38bdf8;
            padding: .1rem .5rem; border-radius: 20px;
            white-space: nowrap;
        }
        .badge-empty { background: #1e293b; color: #475569; }

        /* Conteúdo interno da categoria */
        .cat-body {
            padding: .85rem 1rem .85rem 1.75rem;
            border-top: 1px solid #1e2d40;
            /* linha vertical de indentação */
            border-left: 2px solid #1e3a5f;
            margin-left: 1.1rem;
        }

        /* Categoria vazia */
        .empty-cat {
            padding: .75rem 1rem;
            color: #475569; font-size: .78rem;
            border-top: 1px solid #1e2d40;
            font-style: italic;
        }

        /* Mensagem quando www/ está totalmente vazio */
        .empty-root { color: #475569; font-size: .82rem; }
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
            <?php foreach ($services as $svcName => $cfg): ?>
                <tr>
                    <td><?= $svcName ?></td>
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
            <a class="tool-link" href="<?= htmlspecialchars($pmaUrl) ?>" target="_blank">
                &#128200; phpMyAdmin
                <span class="port">:8081</span>
            </a>
            <a class="tool-link" href="phpinfo.php" target="_blank">
                &#128196; phpinfo()
            </a>
        </div>
    </div>

    <!-- Projetos: árvore recursiva -->
    <div class="card card-full">
        <h2>
            Projetos em www/
            <?php if ($total > 0): ?>
                <span class="total"><?= $total ?> <?= $total === 1 ? 'projeto' : 'projetos' ?></span>
            <?php endif; ?>
        </h2>

        <?php if (empty($tree)): ?>
            <p class="empty-root">
                Nenhuma pasta encontrada. Crie um diretório dentro de <code>www/</code> para ele aparecer aqui.
            </p>
        <?php else: ?>
            <?php renderTree($tree); ?>
        <?php endif; ?>
    </div>

</div>
</body>
</html>
