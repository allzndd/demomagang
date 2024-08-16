<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

header('Content-Type: application/json');
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "magang";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Get POST data
$nama_barang = $_POST['nama_barang'];
$stok = $_POST['stok'];
$harga = $_POST['harga'];
$gambar_barang = $_POST['gambar_barang'];

// Insert data into database
$sql = "INSERT INTO barang (nama_barang, stok, harga, gambar_barang) VALUES ('$nama_barang', '$stok', '$harga', '$gambar_barang')";

if ($conn->query($sql) === TRUE) {
  echo json_encode(array("status" => "success"));
} else {
  echo json_encode(array("status" => "error", "message" => $conn->error));
}

$conn->close();
?>
