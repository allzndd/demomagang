<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

header('Content-Type: application/json');

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

$sql = "SELECT id, nama_barang, stok FROM barang";
$result = $conn->query($sql);

$stock = [];

if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
    $stock[] = [
      'id_barang' => intval($row['id']), // Pastikan nilai di-cast ke integer
      'nama_barang' => $row['nama_barang'],
      'stok' => intval($row['stok']) // Pastikan nilai di-cast ke integer
    ];
  }
}

echo json_encode(['stock' => $stock]);

$conn->close();
?>
