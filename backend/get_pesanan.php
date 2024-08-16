<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

header('Content-Type: application/json'); // Set header untuk JSON

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

$query = "
    SELECT p.id AS id_pesanan, p.nama_penerima, p.alamat_penerima, p.metode_pembayaran, p.total_harga, p.dibuat_pada, 
           i.id AS id_item, i.id_produk, i.kuantitas, i.harga 
    FROM pesanan p
    LEFT JOIN item_pesanan i ON p.id = i.id_pesanan
    ORDER BY p.dibuat_pada DESC
";

$result = $conn->query($query);
$data = [];
$current_order = null;

while($row = $result->fetch_assoc()) {
    if ($current_order === null || $current_order['id'] !== $row['id_pesanan']) {
        if ($current_order !== null) {
            $data[] = $current_order;
        }
        $current_order = [
            'id' => $row['id_pesanan'],
            'nama_penerima' => $row['nama_penerima'],
            'alamat_penerima' => $row['alamat_penerima'],
            'metode_pembayaran' => $row['metode_pembayaran'],
            'total_harga' => $row['total_harga'],
            'dibuat_pada' => $row['dibuat_pada'],
            'items' => []
        ];
    }

    if ($row['id_item'] !== null) {
        $current_order['items'][] = [
            'id_produk' => $row['id_produk'],
            'kuantitas' => $row['kuantitas'],
            'harga' => $row['harga']
        ];
    }
}

if ($current_order !== null) {
    $data[] = $current_order;
}

echo json_encode(['orders' => $data]);

$conn->close();
?>
