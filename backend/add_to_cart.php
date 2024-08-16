<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Konfigurasi koneksi ke database
$host = 'localhost';
$user = 'root';
$password = ''; // Ganti dengan password MySQL Anda
$database = 'magang';

// Buat koneksi ke database
$connection = mysqli_connect($host, $user, $password, $database);

// Cek koneksi
if (!$connection) {
    die(json_encode(['message' => 'Connection failed: ' . mysqli_connect_error()]));
}

// Ambil data dari permintaan POST
$data = json_decode(file_get_contents('php://input'));
$user_id = $data->user_id ?? 0;
$produk_id = $data->product_id ?? 0;
$jumlah = $data->quantity ?? 0;

// Periksa apakah user_id ada di tabel pengguna
$user_check = $connection->prepare("SELECT id FROM pengguna WHERE id = ?");
$user_check->bind_param("i", $user_id);
$user_check->execute();
$user_check->store_result();

if ($user_check->num_rows === 0) {
    echo json_encode(['status' => 'error', 'message' => 'User ID does not exist']);
    exit();
}

// Query untuk menambahkan produk ke keranjang
$sql = "INSERT INTO keranjang (user_id, produk_id, jumlah) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE jumlah = jumlah + VALUES(jumlah)";

$stmt = $connection->prepare($sql);
$stmt->bind_param("iii", $user_id, $produk_id, $jumlah);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $stmt->error]);
}

// Tutup koneksi
mysqli_stmt_close($stmt);
mysqli_close($connection);

?>
