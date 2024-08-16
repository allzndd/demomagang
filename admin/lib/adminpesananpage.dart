import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPesananPage extends StatefulWidget {
  @override
  _AdminPesananPageState createState() => _AdminPesananPageState();
}

class _AdminPesananPageState extends State<AdminPesananPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchPesanan();
  }

  Future<void> fetchPesanan() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/api/demo/get_pesanan.php'));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Update orders based on "orders" key from the JSON
        setState(() {
          orders = decodedData['orders'];
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Error decoding JSON');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Masuk'),
        backgroundColor: Color(0xFF2B8249),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.exit_to_app, color: Color(0xFFFFFFFF)),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Card(
            color: Color(0xFFE0F752),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penerima: ${order['nama_penerima']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  Text('Alamat: ${order['alamat_penerima']}', style: TextStyle(color: Colors.black)),
                  SizedBox(height: 8.0),
                  Text('Metode Pembayaran: ${order['metode_pembayaran']}', style: TextStyle(color: Colors.black)),
                  SizedBox(height: 8.0),
                  Text('Total Harga: Rp${order['total_harga']}', style: TextStyle(color: Colors.black)),
                  SizedBox(height: 8.0),
                  Text('Tanggal: ${order['dibuat_pada']}', style: TextStyle(color: Colors.black)),
                  Divider(color: Color(0xFF2B8249)),
                  ...order['items'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['id_produk']} x${item['kuantitas']}', style: TextStyle(color: Colors.black)),
                          Text('Rp${item['harga']}', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: Color(0xFF020306),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin logout?',
            style: TextStyle(color: Color(0xFF020306)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00BFF3),
              ),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00BFF3),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
