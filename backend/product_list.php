<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

header('Content-Type: application/json'); // Set header untuk JSON

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "magang";

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
  die(json_encode(array("error" => "Connection failed: " . $conn->connect_error)));
}

$sql = "SELECT id, nama_barang, stok, harga, gambar_barang FROM barang";
$result = $conn->query($sql);

$products = array(); // Array untuk menyimpan produk

while($row = $result->fetch_assoc()) {
  $products[] = $row;
}

// Kembalikan JSON yang valid
echo json_encode(['products' => $products]);

$conn->close();
?>
