<?php
function handle_upload($file) {
    $allowed_types = ['image/jpeg', 'image/png', 'application/pdf'];
    $max_size = 2 * 1024 * 1024; // 2MB

    if ($file['error'] !== UPLOAD_ERR_OK) return false;

    if (!in_array($file['type'], $allowed_types)) return false;
    if ($file['size'] > $max_size) return false;

    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $new_name = 'upload_' . time() . '_' . rand(1000,9999) . '.' . $ext;
    $upload_dir = __DIR__ . '/../uploads/';
    if (!is_dir($upload_dir)) mkdir($upload_dir, 0755, true);

    $destination = $upload_dir . $new_name;
    move_uploaded_file($file['tmp_name'], $destination);

    return $new_name;
}
?>
