import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final List<Map<String, dynamic>> _items = [];
  final String apiUrl = "http://localhost/api/demo/barang.php"; // Adjust API URL

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _items.clear();
        _items.addAll(data.map((item) => item as Map<String, dynamic>).toList());
      });
    }
  } catch (e) {
    print("Error fetching items: $e");
  }
}


  void _addItem(Map<String, dynamic> newItem) {
    setState(() {
      _items.add(newItem);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _editItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      _items[index] = updatedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang'),
        backgroundColor: Color(0xFF2B8249), // Match theme color
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset('assets/${item['gambar_barang']}'), // Display item image
              title: Text(item['nama_barang']),
              subtitle: Text('Stok: ${item['stok']} Kg\nHarga: ${item['harga']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Edit item
                      _editItem(index, item);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteItem(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2B8249),
        onPressed: () {
          // Add new item
          _addItem({
            'nama_barang': 'New Item',
            'stok': 0,
            'harga': 0.0,
            'gambar_barang': 'default.png',
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
