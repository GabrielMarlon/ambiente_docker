<?php
declare(strict_types=1);
header('Content-Type: application/json');

$socketPath = '/var/run/docker.sock';

if (!file_exists($socketPath)) {
    echo json_encode(['error' => 'socket_not_found']);
    exit;
}

function dockerGet(string $path, string $socketPath): mixed {
    $ch = curl_init("http://localhost{$path}");
    curl_setopt_array($ch, [
        CURLOPT_UNIX_SOCKET_PATH => $socketPath,
        CURLOPT_RETURNTRANSFER   => true,
        CURLOPT_TIMEOUT          => 5,
    ]);
    $json = curl_exec($ch);
    curl_close($ch);
    return $json ? json_decode($json, true) : null;
}

$containers = dockerGet('/containers/json', $socketPath);
if (!is_array($containers) || empty($containers)) {
    echo json_encode($containers === null ? ['error' => 'failed_to_list'] : []);
    exit;
}

// Busca stats de todos os containers em paralelo
$mh = curl_multi_init();
$handles = [];
foreach ($containers as $c) {
    $id = $c['Id'];
    $ch = curl_init("http://localhost/containers/{$id}/stats?stream=false");
    curl_setopt_array($ch, [
        CURLOPT_UNIX_SOCKET_PATH => $socketPath,
        CURLOPT_RETURNTRANSFER   => true,
        CURLOPT_TIMEOUT          => 8,
    ]);
    curl_multi_add_handle($mh, $ch);
    $handles[$id] = ['handle' => $ch, 'container' => $c];
}

$running = null;
do {
    curl_multi_exec($mh, $running);
    curl_multi_select($mh, 1.0);
} while ($running > 0);

$stats = [];
foreach ($handles as $id => $info) {
    $ch   = $info['handle'];
    $c    = $info['container'];
    $json = curl_multi_getcontent($ch);
    curl_multi_remove_handle($mh, $ch);
    curl_close($ch);

    if (!$json) continue;
    $s = json_decode($json, true);
    if (!is_array($s)) continue;

    $name = ltrim($c['Names'][0] ?? $id, '/');

    // Memória
    $memUsage  = (int)($s['memory_stats']['usage'] ?? 0);
    $memLimit  = (int)($s['memory_stats']['limit'] ?? 0);
    $memCache  = (int)($s['memory_stats']['stats']['cache']
              ?? $s['memory_stats']['stats']['inactive_file']
              ?? 0);
    $memActual = max(0, $memUsage - $memCache);
    $memPct    = $memLimit > 0 ? round($memActual / $memLimit * 100, 1) : 0.0;

    // CPU
    $cpuCurr   = (int)($s['cpu_stats']['cpu_usage']['total_usage']    ?? 0);
    $cpuPrev   = (int)($s['precpu_stats']['cpu_usage']['total_usage'] ?? 0);
    $sysCurr   = (int)($s['cpu_stats']['system_cpu_usage']            ?? 0);
    $sysPrev   = (int)($s['precpu_stats']['system_cpu_usage']         ?? 0);
    $cpuDelta  = $cpuCurr - $cpuPrev;
    $sysDelta  = $sysCurr - $sysPrev;
    $numCpus   = (int)($s['cpu_stats']['online_cpus']
              ?? count($s['cpu_stats']['cpu_usage']['percpu_usage'] ?? [0]));
    $cpuPct    = ($sysDelta > 0 && $cpuDelta >= 0 && $numCpus > 0)
               ? round($cpuDelta / $sysDelta * $numCpus * 100, 2)
               : 0.0;

    $stats[] = [
        'name'      => $name,
        'memActual' => $memActual,
        'memLimit'  => $memLimit,
        'memPct'    => $memPct,
        'cpuPct'    => $cpuPct,
    ];
}

curl_multi_close($mh);
usort($stats, fn($a, $b) => strcmp($a['name'], $b['name']));
echo json_encode($stats);
