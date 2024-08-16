<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

header('Content-Type: application/json');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "magang";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("error" => "Connection failed: " . $conn->connect_error)));
}

$sql = "SELECT id, nama_barang, stok, harga, gambar FROM barang";
$result = $conn->query($sql);

$products = [];

while($row = $result->fetch_assoc()) {
    // Ensure that the image URL is correct
    $row['gambar'] = 'http://localhost/api/demo/images/' . $row['gambar'];
    $products[] = $row;
}

echo json_encode(['products' => $products]);

$conn->close();
?>
