import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> products = [];
  Map<int, int> cart = {}; // Track product ID and quantity

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/api/demo/product_list.php'));
      if (response.statusCode == 200) {
        setState(() {
          products = List<Map<String, dynamic>>.from(json.decode(response.body)['products']);
        });
      } else {
        print('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _addToCart(int productId, int quantity) {
    setState(() {
      if (quantity > 0) {
        cart[productId] = (cart[productId] ?? 0) + quantity;
      }
    });
  }

  void _proceedToCheckout() {
    Navigator.pushNamed(context, '/checkout', arguments: cart);
  }

  void _viewCart() {
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF2B8249),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _viewCart,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Kami',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B8249)),
            ),
            SizedBox(height: 16.0),
            ...products.map((item) => _buildProductCard(item)).toList(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _proceedToCheckout,
              child: Text('Checkout'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF007250),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Color(0xFF007250),
        unselectedItemColor: Color(0xFF88C14F),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    int quantity = cart[item['id_barang']] ?? 0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      color: Color(0xFFB8E052),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('${item['gambar_barang']}', width: 100, height: 100, fit: BoxFit.cover),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nama_barang'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text('Stok: ${item['stok']} Kg'),
                  Text('Harga: ${item['harga']}'),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 0) {
                              quantity--;
                              cart[item['id_barang']] = quantity;
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: quantity.toString()),
                          onChanged: (value) {
                            int qty = int.tryParse(value) ?? 0;
                            setState(() {
                              cart[item['id_barang']] = qty;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            cart[item['id_barang']] = quantity;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          int qty = cart[item['id_barang']] ?? 0;
                          _addToCart(item['id_barang'], qty);
                        },
                        child: Text('Tambah ke Keranjang'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF007250),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          int qty = cart[item['id_barang']] ?? 0;
                          if (qty > 0) {
                            Navigator.pushNamed(context, '/checkout', arguments: {item['id_barang']: qty});
                          }
                        },
                        child: Text('Beli Sekarang'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF007250),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
