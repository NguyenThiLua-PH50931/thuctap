<?php
namespace XYZBank\Accounts;

abstract class BankAccount {
    protected string $accountNumber;
    protected string $ownerName;
    protected float $balance;

    public function __construct(string $accountNumber, string $ownerName, float $balance) {
        $this->accountNumber = $accountNumber;
        $this->ownerName = $ownerName;
        $this->balance = $balance;
    }

    public function getBalance(): float {
        return $this->balance;
    }

    public function getOwnerName(): string {
        return $this->ownerName;
    }

    abstract public function deposit(float $amount): void;
    abstract public function withdraw(float $amount): void;
    abstract public function getAccountType(): string;

    public function getAccountNumber(): string {
        return $this->accountNumber;
    }
}
