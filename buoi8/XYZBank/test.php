<?php
require_once __DIR__ . '/../vendor/autoload.php';

use XYZBank\Accounts\SavingsAccount;
use XYZBank\Accounts\CheckingAccount;
use XYZBank\Utils\Bank;
use XYZBank\Collections\AccountCollection;

// Khởi tạo collection
$collection = new AccountCollection();

// Tài khoản tiết kiệm
$acc1 = new SavingsAccount("10201122", "Nguyễn Thị A", 20000000);
Bank::incrementAccountCount();
$collection->addAccount($acc1);

// Tài khoản thanh toán 1
$acc2 = new CheckingAccount("20301123", "Lê Văn B", 8000000);
Bank::incrementAccountCount();
$acc2->deposit(5000000);
$collection->addAccount($acc2);

// Tài khoản thanh toán 2
$acc3 = new CheckingAccount("20401124", "Trần Minh C", 12000000);
Bank::incrementAccountCount();
$acc3->withdraw(2000000);
$collection->addAccount($acc3);



foreach ($collection as $account) {
    echo "<br><br>Tài khoản: {$account->getAccountNumber()} - {$account->getOwnerName()} <br> Loại: {$account->getAccountType()} <br> Số dư: " . number_format($account->getBalance(), 0, '', '.') . " VNĐ <br><br>";
}

// Hiển thị lãi suất hàng năm cho tài khoản tiết kiệm
echo "Lãi suất hàng năm cho Nguyễn Thị A: " . number_format($acc1->calculateAnnualInterest(), 0, '', '.') . " VNĐ<br><br>";

// Thống kê
echo "Tổng số tài khoản đã tạo: " . Bank::$totalAccounts . "<br><br>";
echo "Tên ngân hàng: " . Bank::getBankName() . "<br><br>";

