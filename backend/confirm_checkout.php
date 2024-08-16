<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Koneksi ke database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "magang";

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(array("error" => "Koneksi gagal: " . $conn->connect_error)));
}

// Ambil data dari POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data dari POST
    $id_pengguna = isset($_POST['id_pengguna']) ? trim($_POST['id_pengguna']) : null;
    $nama_penerima = isset($_POST['nama_penerima']) ? trim($_POST['nama_penerima']) : null;
    $alamat_penerima = isset($_POST['alamat_penerima']) ? trim($_POST['alamat_penerima']) : null;
    $metode_pembayaran = isset($_POST['metode_pembayaran']) ? trim($_POST['metode_pembayaran']) : null;
    $total_harga = isset($_POST['total_harga']) ? trim($_POST['total_harga']) : null;
    $produk = isset($_POST['produk']) ? json_decode($_POST['produk'], true) : null;

    // Log data untuk debugging
    file_put_contents('debug.log', json_encode([
        'id_pengguna' => $id_pengguna,
        'nama_penerima' => $nama_penerima,
        'alamat_penerima' => $alamat_penerima,
        'metode_pembayaran' => $metode_pembayaran,
        'total_harga' => $total_harga,
        'produk' => $produk
    ]) . PHP_EOL, FILE_APPEND);

    // Periksa apakah data lengkap
    if ($id_pengguna && $nama_penerima && $alamat_penerima && $metode_pembayaran && $total_harga && $produk) {
        // Query untuk memasukkan data pesanan
        $sql = "INSERT INTO pesanan (id_pengguna, nama_penerima, alamat_penerima, metode_pembayaran, total_harga) 
                VALUES (?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            die(json_encode(array("error" => "Gagal menyiapkan query: " . $conn->error)));
        }
        $stmt->bind_param("isssd", $id_pengguna, $nama_penerima, $alamat_penerima, $metode_pembayaran, $total_harga);
        
        if ($stmt->execute()) {
            $id_pesanan = $stmt->insert_id;
            $stmt->close();
            
            // Query untuk memasukkan data item pesanan
            $sql = "INSERT INTO item_pesanan (id_pesanan, id_produk, kuantitas, harga) VALUES (?, ?, ?, ?)";
            $stmt = $conn->prepare($sql);
            
            if (!$stmt) {
                die(json_encode(array("error" => "Gagal menyiapkan query item pesanan: " . $conn->error)));
            }
            
            foreach ($produk as $item) {
                $stmt->bind_param("iiid", $id_pesanan, $item['id'], $item['jumlah'], $item['harga']);
                if (!$stmt->execute()) {
                    die(json_encode(array("error" => "Gagal menambahkan item pesanan: " . $stmt->error)));
                }
            }

            $stmt->close();
            $response = array("success" => true, "message" => "Pesanan telah berhasil ditempatkan.");
        } else {
            $response = array("success" => false, "message" => "Gagal menempatkan pesanan: " . $stmt->error);
        }
        
    } else {
        $response = array("success" => false, "message" => "Data tidak lengkap. Data yang diterima: " . json_encode([
            'id_pengguna' => $id_pengguna,
            'nama_penerima' => $nama_penerima,
            'alamat_penerima' => $alamat_penerima,
            'metode_pembayaran' => $metode_pembayaran,
            'total_harga' => $total_harga,
            'produk' => $produk
        ]));
    }

    $conn->close();
} else {
    $response = array("success" => false, "message" => "Metode permintaan tidak valid.");
}

echo json_encode($response);
?>
