<?php

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
$usernameOrEmail = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

// Query untuk mencari pengguna berdasarkan nama_pengguna atau surel
$sql = "SELECT * FROM pengguna WHERE nama_pengguna = ? OR surel = ?";
$stmt = mysqli_prepare($connection, $sql);
mysqli_stmt_bind_param($stmt, 'ss', $usernameOrEmail, $usernameOrEmail);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);
    if (password_verify($password, $user['kata_sandi'])) {
        // Autentikasi berhasil, simpan id_pengguna, username, dan surel ke dalam sesi
        session_start();
        
        // Memastikan nilai id_pengguna, nama_pengguna, dan surel tidak null sebelum menyimpannya
        if (!is_null($user['id']) && !is_null($user['nama_pengguna']) && !is_null($user['surel'])) {
            $_SESSION['id_pengguna'] = $user['id']; // Simpan id_pengguna dari pengguna yang berhasil masuk
            $_SESSION['username'] = $user['nama_pengguna']; // Simpan nama_pengguna dari pengguna yang berhasil masuk
            $_SESSION['surel'] = $user['surel']; // Simpan surel dari pengguna yang berhasil masuk
            echo json_encode(['message' => 'Login successful', 'id_pengguna' => $user['id'], 'username' => $user['nama_pengguna'], 'surel' => $user['surel']]);
        } else {
            echo json_encode(['message' => 'User data is incomplete']);
        }
    } else {
        echo json_encode(['message' => 'Invalid password']);
    }
} else {
    echo json_encode(['message' => 'User not found']);
}

// Tutup koneksi
mysqli_stmt_close($stmt);
mysqli_close($connection);

?>
