<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Fungsi untuk menghapus produk dari keranjang
function removeFromCart($userId, $productId) {
    $conn = new mysqli("localhost", "root", "", "magang"); // Ubah 'magang' dengan nama database Anda

    if ($conn->connect_error) {
        die(json_encode(['success' => false, 'message' => 'Connection failed: ' . $conn->connect_error]));
    }

    $sql = "DELETE FROM keranjang WHERE user_id = ? AND produk_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $userId, $productId);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_POST['user_id'] ?? 0;
    $productId = $_POST['product_id'] ?? 0;

    if ($userId == 0 || $productId == 0) {
        echo json_encode(['success' => false, 'message' => 'User ID or Product ID is missing']);
        exit;
    }

    removeFromCart($userId, $productId);
}
?>
