<?php
namespace XYZBank\Collections;

use IteratorAggregate;
use ArrayIterator;
use XYZBank\Accounts\BankAccount;

class AccountCollection implements IteratorAggregate {
    private array $accounts = [];

    public function addAccount(BankAccount $account): void {
        $this->accounts[] = $account;
    }

    public function getIterator(): ArrayIterator {
        return new ArrayIterator($this->accounts);
    }

    public function getHighBalanceAccounts(float $minBalance): array {
        return array_filter($this->accounts, fn($account) => $account->getBalance() >= $minBalance);
    }
}
