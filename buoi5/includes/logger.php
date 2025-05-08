<?php
function write_log($action, $filename = null) {
    $date = date('Y-m-d');
    $time = date('H:i:s');
    $ip = $_SERVER['REMOTE_ADDR'];
    $log_dir = __DIR__ . '/../logs';
    if (!is_dir($log_dir)) mkdir($log_dir, 0755, true);
    $log_file = "$log_dir/log_$date.txt";

    $log_entry = "[$time] - IP: $ip - Hành động: $action";
    if ($filename) {
        $log_entry .= " - File: $filename";
    }
    $log_entry .= PHP_EOL;

    file_put_contents($log_file, $log_entry, FILE_APPEND);
}
?>
