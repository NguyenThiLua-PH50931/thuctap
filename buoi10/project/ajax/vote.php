<?php
session_start();
$vote = $_POST['vote'];
$_SESSION['poll'][$vote] = ($_SESSION['poll'][$vote] ?? 0) + 1;
$total = array_sum($_SESSION['poll']);
foreach ($_SESSION['poll'] as $key => $count) {
    $percent = round($count / $total * 100);
    echo "<p>{$key}: {$percent}%</p>";
}
?>