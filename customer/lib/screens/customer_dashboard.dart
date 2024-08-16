import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../../models/product.dart';
import 'product_detail.dart';

class CustomerDashboard extends StatefulWidget {
  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<Product> products = [];
  int _selectedIndex = 0;

  // Method to connect to the MySQL database and fetch products
  Future<void> _fetchProducts() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '',
      db: 'magang',
    ));

    var results = await conn.query('SELECT * FROM barang');

    List<Product> fetchedProducts = [];
    for (var row in results) {
      fetchedProducts.add(Product(
        id: row['id'],
        nama: row['nama_barang'],
        deskripsi: row['deskripsi'],
        kategori: row['kategori'],
        harga: row['harga'],
        stok: row['stok'],
        tanggalProduksi: row['tanggal_produksi'],
        totalTerjual: row['total_terjual'],
        gambar: row['gambar'],
      ));
    }

    await conn.close();

    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic can be added here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Customer'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(product: products[i]),
              ),
            );
          },
          child: GridTile(
            child: Image.asset(
              'assets/images/${products[i].gambar}',
              fit: BoxFit.cover,
            ),
            footer: Container(
              color: Colors.black54,
              child: ListTile(
                title: Text(
                  products[i].nama,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histori',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
