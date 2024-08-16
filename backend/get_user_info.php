<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

$host = 'localhost'; // replace with your database host
$user = 'root'; // replace with your database username
$pass = ''; // replace with your database password
$db_name = 'magang'; // replace with your database name

// Connect to the database
$conn = new mysqli($host, $user, $pass, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set content type to JSON
header('Content-Type: application/json');

// Check if the user_id parameter is provided
if (!isset($_GET['user_id'])) {
    echo json_encode(["success" => false, "message" => "Parameter user_id tidak ditemukan"]);
    exit();
}

$user_id = intval($_GET['user_id']);

// Prepare the SQL statement
$stmt = $conn->prepare("SELECT id, nama_pengguna, surel, peran, dibuat_pada, diperbarui_pada FROM pengguna WHERE id = ?");
$stmt->bind_param("i", $user_id);

// Execute the statement
$stmt->execute();

// Fetch the result
$result = $stmt->get_result();

// Check if a user was found
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode(["success" => true, "data" => $user]);
} else {
    echo json_encode(["success" => false, "message" => "Pengguna tidak ditemukan"]);
}

// Close the statement and the connection
$stmt->close();
$conn->close();
?>