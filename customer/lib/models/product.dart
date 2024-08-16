class Product {
  final int id;
  final String nama;
  final String? deskripsi;
  final String kategori;
  final double harga;
  final double stok;
  final DateTime tanggalProduksi;
  final double totalTerjual;
  final String gambar;

  Product({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.tanggalProduksi,
    required this.totalTerjual,
    required this.gambar,
  });
}
