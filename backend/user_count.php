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

$sql = "SELECT COUNT(*) as user_count FROM pengguna";
$result = $conn->query($sql);

$response = array(); // Array untuk menyimpan respon

if ($result->num_rows > 0) {
  $row = $result->fetch_assoc();
  $response['user_count'] = intval($row['user_count']); // Pastikan nilai di-cast ke integer
} else {
  $response['user_count'] = 0; // Jika tidak ada pengguna
}

// Kembalikan JSON yang valid
echo json_encode($response);

$conn->close();
?>
