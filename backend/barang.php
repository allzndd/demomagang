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

// Get the request method
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
  case 'GET':
    $sql = "SELECT * FROM barang";
    $result = $conn->query($sql);

    $items = array();

    if ($result->num_rows > 0) {
      while($row = $result->fetch_assoc()) {
        $items[] = $row;
      }
    }

    echo json_encode($items);
    break;

  case 'POST':
    $data = json_decode(file_get_contents('php://input'), true);
    $nama_barang = $data['nama_barang'];
    $deskripsi = $data['deskripsi'];
    $kategori = $data['kategori'];
    $harga = $data['harga'];
    $stok = $data['stok'];
    $tanggal_produksi = $data['tanggal_produksi'];
    $gambar_barang = $data['gambar_barang'];

    $sql = "INSERT INTO barang (nama_barang, deskripsi, kategori, harga, stok, tanggal_produksi, gambar_barang)
            VALUES ('$nama_barang', '$deskripsi', '$kategori', '$harga', '$stok', '$tanggal_produksi', '$gambar_barang')";

    if ($conn->query($sql) === TRUE) {
      $data['id'] = $conn->insert_id;
      echo json_encode($data);
    } else {
      echo json_encode(['error' => $conn->error]);
    }
    break;

  case 'PUT':
    $id = $_GET['id'];
    $data = json_decode(file_get_contents('php://input'), true);
    $nama_barang = $data['nama_barang'];
    $deskripsi = $data['deskripsi'];
    $kategori = $data['kategori'];
    $harga = $data['harga'];
    $stok = $data['stok'];
    $tanggal_produksi = $data['tanggal_produksi'];
    $gambar_barang = $data['gambar_barang'];

    $sql = "UPDATE barang SET 
            nama_barang='$nama_barang', deskripsi='$deskripsi', kategori='$kategori', harga='$harga', stok='$stok', 
            tanggal_produksi='$tanggal_produksi', gambar_barang='$gambar_barang'
            WHERE id=$id";

    if ($conn->query($sql) === TRUE) {
      echo json_encode($data);
    } else {
      echo json_encode(['error' => $conn->error]);
    }
    break;

  case 'DELETE':
    $id = $_GET['id'];
    $sql = "DELETE FROM barang WHERE id=$id";

    if ($conn->query($sql) === TRUE) {
      echo json_encode(['success' => true]);
    } else {
      echo json_encode(['error' => $conn->error]);
    }
    break;
}

$conn->close();
?>
