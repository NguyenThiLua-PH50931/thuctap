<?php

class AffiliatePartner {
    protected string $name;
    protected string $email;
    protected float $commissionRate;
    protected bool $isActive;

    const PLATFORM_NAME = "VietLink Affiliate";

    public function __construct(string $name, string $email, float $commissionRate, bool $isActive = true) {
        $this->name = $name;
        $this->email = $email;
        $this->commissionRate = $commissionRate;
        $this->isActive = $isActive;
    }

    public function __destruct() {
        echo "[Log] Đã hủy đối tượng: {$this->name}<br><br>";
    }

    public function calculateCommission(float $orderValue): float {
        return $orderValue * $this->commissionRate / 100;
    }

    public function getSummary(): string {
        return sprintf(
            "Tên: %-20s | Email: %-25s | Hoa hồng: %5.1f%% | Trạng thái: %-15s | Nền tảng: %s",
            $this->name,
            $this->email,
            $this->commissionRate,
            $this->isActive ? "Đang hoạt động" : "Ngừng hoạt động",
            self::PLATFORM_NAME
        );
    }

    public function getName(): string {
        return $this->name;
    }
}

class PremiumAffiliatePartner extends AffiliatePartner {
    private float $bonusPerOrder;

    public function __construct(string $name, string $email, float $commissionRate, float $bonusPerOrder, bool $isActive = true) {
        parent::__construct($name, $email, $commissionRate, $isActive);
        $this->bonusPerOrder = $bonusPerOrder;
    }

    public function calculateCommission(float $orderValue): float {
        return parent::calculateCommission($orderValue) + $this->bonusPerOrder;
    }

    public function getSummary(): string {
        return parent::getSummary() . sprintf(" | Bonus: %s VNĐ", number_format($this->bonusPerOrder));
    }
}

class AffiliateManager {
    private array $partners = [];

    public function addPartner(AffiliatePartner $affiliate): void {
        $this->partners[] = $affiliate;
    }

    public function listPartners(): void {
        echo "<strong>Danh sách cộng tác viên:</strong><br><br>";
        foreach ($this->partners as $partner) {
            echo $partner->getSummary() . "<br>";
        }
        echo "<br>";
    }

    public function totalCommission(float $orderValue): float {
        $total = 0;
        echo "<strong>Chi tiết hoa hồng cho mỗi đơn hàng " . number_format($orderValue) . " VNĐ:</strong><br>";
        foreach ($this->partners as $partner) {
            $commission = $partner->calculateCommission($orderValue);
            echo "- " . $partner->getName() . ": Hoa hồng = " . number_format($commission) . " VNĐ<br>";
            $total += $commission;
        }
        echo "<br>";
        return $total;
    }
}

// Dữ liệu mẫu
$orderValue = 2000000;

$ctv1 = new AffiliatePartner("Nguyễn Văn A", "a@example.com", 5);
$ctv2 = new AffiliatePartner("Trần Thị B", "b@example.com", 7);
$ctv3 = new PremiumAffiliatePartner("Lê Văn C", "c@example.com", 4, 50000);

$manager = new AffiliateManager();
$manager->addPartner($ctv1);
$manager->addPartner($ctv2);
$manager->addPartner($ctv3);

$manager->listPartners();

$total = $manager->totalCommission($orderValue);

echo "<strong>Tổng hoa hồng hệ thống cần chi trả: " . number_format($total) . " VNĐ</strong><br><br>";

?>
