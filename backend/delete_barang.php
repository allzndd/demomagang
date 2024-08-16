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
$id = $_POST['id'];

// Delete data from database
$sql = "DELETE FROM barang WHERE id='$id'";

if ($conn->query($sql) === TRUE) {
  echo json_encode(array("status" => "success"));
} else {
  echo json_encode(array("status" => "error", "message" => $conn->error));
}

$conn->close();
?>
