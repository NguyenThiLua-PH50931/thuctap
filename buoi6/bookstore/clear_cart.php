<?php
session_start();
session_destroy();
unlink('cart_data.json'); // Xóa file giỏ hàng nếu có
header('Location: index.php');
