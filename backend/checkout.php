<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

include_once '../config/database.php';
include_once '../objects/transaksi.php';

$database = new Database();
$db = $database->getConnection();

$transaksi = new Transaksi($db);

// Mendapatkan data POST
$data = json_decode(file_get_contents("php://input"));

// Memeriksa data yang diperlukan
if (
    !isset($data->id_pengguna) ||
    !isset($data->nama_penerima) ||
    !isset($data->alamat_penerima) ||
    !isset($data->metode_pembayaran) ||
    !isset($data->total_harga) ||
    !isset($data->produk)
) {
    echo json_encode(array("success" => false, "message" => "Data tidak lengkap."));
    http_response_code(400);
    exit();
}

// Menyimpan transaksi
$transaksi->id_pengguna = $data->id_pengguna;
$transaksi->nama_penerima = $data->nama_penerima;
$transaksi->alamat_penerima = $data->alamat_penerima;
$transaksi->metode_pembayaran = $data->metode_pembayaran;
$transaksi->total_harga = $data->total_harga;

if ($transaksi->create()) {
    // Menyimpan detail transaksi
    $produk = json_decode($data->produk);
    foreach ($produk as $item) {
        $transaksi->addItem(
            $item->id_barang,
            $item->jumlah_barang,
            $item->jumlah_transaksi
        );
    }

    echo json_encode(array("success" => true));
    http_response_code(200);
} else {
    echo json_encode(array("success" => false, "message" => "Gagal menyimpan transaksi."));
    http_response_code(500);
}
?>
