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

  Future<void> _fetchItems() async {
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

  Future<void> _addItem(Map<String, dynamic> newItem) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/api/demo/create_barang.php"),
        body: newItem,
      );
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _fetchItems();
      }
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<void> _updateItem(Map<String, dynamic> updatedItem) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/api/demo/update_barang.php"),
        body: updatedItem,
      );
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _fetchItems();
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/api/demo/delete_barang.php"),
        body: {'id': id.toString()},
      );
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _fetchItems();
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  void _showForm({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final namaBarangController = TextEditingController(text: isEdit ? item!['nama_barang'] : '');
    final stokController = TextEditingController(text: isEdit ? item!['stok'].toString() : '');
    final hargaController = TextEditingController(text: isEdit ? item!['harga'].toString() : '');
    final gambarBarangController = TextEditingController(text: isEdit ? item!['gambar_barang'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Item' : 'Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaBarangController,
                decoration: InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok'),
              ),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: gambarBarangController,
                decoration: InputDecoration(labelText: 'Gambar Barang'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newItem = {
                  'id': isEdit ? item!['id'].toString() : '',
                  'nama_barang': namaBarangController.text,
                  'stok': stokController.text,
                  'harga': hargaController.text,
                  'gambar_barang': gambarBarangController.text,
                };
                if (isEdit) {
                  _updateItem(newItem);
                } else {
                  _addItem(newItem);
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
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
              leading: Image.asset('${item['gambar_barang']}'), // Display item image
              title: Text(item['nama_barang']),
              subtitle: Text('Stok: ${item['stok']} Kg\nHarga: ${item['harga']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showForm(item: item);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteItem(item['id']);
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
          _showForm();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}