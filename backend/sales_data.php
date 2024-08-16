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

$sql = "SELECT MONTH(tanggal_transaksi) as month, SUM(jumlah_transaksi) as total 
        FROM transaksi 
        GROUP BY MONTH(tanggal_transaksi)";
$result = $conn->query($sql);

$sales = array_fill(0, 12, 0); // Initialize array for 12 months

if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
    $sales[intval($row['month']) - 1] = floatval($row['total']);
  }
}

echo json_encode(['sales' => $sales]);

$conn->close();
?>
