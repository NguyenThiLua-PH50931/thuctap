<?php
namespace XYZBank\Accounts;

use XYZBank\Accounts\Traits\TransactionLogger;

class CheckingAccount extends BankAccount {
    use TransactionLogger;

    public function deposit(float $amount): void {
        $this->balance += $amount;
        $this->logTransaction("Gửi tiền", $amount, $this->balance);
    }

    public function withdraw(float $amount): void {
        if ($amount > $this->balance) {
            echo "Không thể rút. Số dư không đủ.\n";
            return;
        }
        $this->balance -= $amount;
        $this->logTransaction("Rút tiền", $amount, $this->balance);
    }

    public function getAccountType(): string {
        return "Thanh toán";
    }
}
