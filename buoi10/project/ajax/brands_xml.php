<?php
$xml = simplexml_load_file("../data/brands.xml");
$cat = $_GET['category'];
$options = "";
foreach ($xml->brand as $brand) {
    if ((string)$brand['category'] === $cat) {
        $options .= "<option>{$brand}</option>";
    }
}
echo $options;
?>