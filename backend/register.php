<?php
header('Content-Type: application/json');

$host = 'localhost';
$user = 'root';
$password = '';
$database = 'magang';

$connection = mysqli_connect($host, $user, $password, $database);

if (!$connection) {
    http_response_code(500);
    echo json_encode(['error' => 'Connection failed: ' . mysqli_connect_error()]);
    exit();
}

if (isset($_POST['username']) && isset($_POST['email']) && isset($_POST['password'])) {
    $username = mysqli_real_escape_string($connection, $_POST['username']);
    $email = mysqli_real_escape_string($connection, $_POST['email']);
    $password = mysqli_real_escape_string($connection, $_POST['password']);
    $role = 2;

    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $sql = "INSERT INTO pengguna (nama_pengguna, surel, kata_sandi, peran) VALUES ('$username', '$email', '$hashed_password', $role)";

    if (mysqli_query($connection, $sql)) {
        http_response_code(200);
        echo json_encode(['message' => 'Registration successful']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Error: ' . mysqli_error($connection)]);
    }
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Error: Data is not set']);
}

mysqli_close($connection);
?>