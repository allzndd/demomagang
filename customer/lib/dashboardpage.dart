import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopee Clone',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('id_pengguna');
    });
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      const url =
          'http://localhost/api/demo/get_product.php'; // Ganti dengan IP komputer Anda
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
        print('Data produk berhasil diambil: $_products');
      } else {
        print('Error: Status code ${response.statusCode}');
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching products: $e');
      print(stacktrace);
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToProductDetail(Product product) {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductDetailPage(product: product, userId: _userId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID tidak ditemukan. Harap login ulang.'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1 && _userId != null) {
        // Indeks 1 untuk 'Keranjang'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(userId: _userId!),
          ),
        );
      } else if (index == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID tidak ditemukan. Harap login ulang.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Aksi ketika ikon profil diklik
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : DashboardContent(
                  products: _products,
                  onProductTap: _navigateToProductDetail,
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histori Transaksi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF007250),
        unselectedItemColor: const Color(0xFF589E4B),
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onProductTap;

  const DashboardContent({
    required this.products,
    required this.onProductTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => onProductTap(product),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'assets/images/${product.gambar}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaBarang,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${product.harga.toString()}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Product {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final String kategori;
  final double harga;
  final double stok;
  final String tanggalProduksi;
  final double totalTerjual;
  final String gambar;
  final int? jumlah;

  Product({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.tanggalProduksi,
    required this.totalTerjual,
    required this.gambar,
    this.jumlah,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      stok: double.tryParse(json['stok'].toString()) ?? 0.0,
      tanggalProduksi: json['tanggal_produksi'],
      totalTerjual: double.tryParse(json['total_terjual'].toString()) ?? 0.0,
      gambar: json['gambar'],
      jumlah: json['jumlah'] != null
          ? int.tryParse(json['jumlah'].toString())
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'tanggal_produksi': tanggalProduksi,
      'total_terjual': totalTerjual,
      'gambar': gambar,
      'jumlah': jumlah,
    };
  }
}

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final int userId;

  const ProductDetailPage({
    required this.product,
    required this.userId,
    super.key,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  void _addToCart() async {
    final success = await _addToCartAPI(widget.product.id, _quantity);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Produk berhasil ditambahkan ke keranjang')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan produk ke keranjang')),
      );
    }
  }

  Future<bool> _addToCartAPI(int productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_pengguna');

      if (userId == null) {
        // Tampilkan pesan error jika ID pengguna tidak ditemukan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID pengguna tidak ditemukan di sesi')),
        );
        return false;
      }

      final url =
          'http://localhost/api/demo/add_to_cart.php'; // Ganti dengan URL Anda
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':
              'application/json', // Ubah sesuai dengan header yang diperlukan
        },
        body: jsonEncode({
          'user_id': userId.toString(),
          'product_id': productId.toString(),
          'quantity': quantity.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          // Tampilkan pesan error jika API mengindikasikan kegagalan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal menambahkan produk ke keranjang: ${data['message'] ?? 'Unknown error'}')),
          );
          return false;
        }
      } else {
        // Tampilkan pesan error jika status code tidak sesuai
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Terjadi kesalahan dengan status code: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      // Tangani kesalahan yang mungkin terjadi selama permintaan HTTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.namaBarang),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/${product.gambar}',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.namaBarang,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${product.harga.toString()}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                product.deskripsi,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        _quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rp ${(_quantity * product.harga).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007250),
                ),
                child: const Text('Tambah ke Keranjang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final int userId;

  const CartPage({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> _cartProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _totalBelanja = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartProducts();
  }

  Future<void> fetchCartProducts() async {
    try {
      final url =
          'http://localhost/api/demo/get_cart.php?user_id=${widget.userId}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _cartProducts = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
          _calculateTotalBelanja();
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load cart products: ${response.body}';
        });
      }
    } catch (e, stacktrace) {
      print('Error fetching cart products: $e');
      print(stacktrace);
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _removeFromCart(int productId) async {
    final success = await _removeFromCartAPI(productId);
    if (success) {
      setState(() {
        _cartProducts.removeWhere((product) => product.id == productId);
        _calculateTotalBelanja();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus dari keranjang')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus produk dari keranjang')),
      );
    }
  }

  Future<bool> _removeFromCartAPI(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_pengguna');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ID pengguna tidak ditemukan. Harap login ulang.')),
        );
        return false;
      }

      final url = 'http://localhost/api/demo/remove_from_cart.php';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId.toString(),
          'product_id': productId.toString(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal menghapus produk dari keranjang: ${data['message'] ?? 'Unknown error'}')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Terjadi kesalahan dengan status code: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      return false;
    }
  }

  void _calculateTotalBelanja() {
    double total = 0.0;
    for (var product in _cartProducts) {
      total += product.harga *
          (product.jumlah ?? 1); // If jumlah is null, default to 1
    }
    setState(() {
      _totalBelanja = total;
    });
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _cartProducts.isEmpty
                  ? const Center(child: Text('Keranjang belanja kosong'))
                  : ListView.builder(
                      itemCount: _cartProducts.length,
                      itemBuilder: (context, index) {
                        final product = _cartProducts[index];
                        return ListTile(
                          leading: Image.asset(
                            'assets/images/${product.gambar}',
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.namaBarang),
                          subtitle: Text(
                              'Rp ${product.harga.toStringAsFixed(2)} x ${product.jumlah ?? 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_shopping_cart),
                            onPressed: () => _removeFromCart(product.id),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rp ${_totalBelanja.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _checkout,
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final int userId;

  const CheckoutPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _recipientNameController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  String _selectedPaymentMethod = 'Transfer ke Rekening BRI';
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _checkoutProducts = []; // Ganti dengan model produk yang sesuai
  double _totalPrice =
      0.0; // Inisialisasi sesuai dengan total harga yang sesuai
  String _recipientName = '';
  String _recipientAddress = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipientInfo();
    _fetchCartProducts();
  }

  Future<void> _fetchRecipientInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_pengguna');

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID tidak ditemukan. Silakan login ulang.';
        });
        return;
      }

      final url = 'http://localhost/api/demo/get_user_info.php?user_id=$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recipientName = data['name'] ?? '';
          _recipientAddress = data['address'] ?? '';
          _recipientNameController.text = _recipientName;
          _recipientAddressController.text = _recipientAddress;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat informasi pengguna: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchCartProducts() async {
    try {
      final url =
          'http://localhost/api/demo/get_cart.php?user_id=${widget.userId}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _checkoutProducts =
              data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
          _calculateTotalPrice();
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load cart products: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var product in _checkoutProducts) {
      total += product.harga * (product.jumlah ?? 1);
    }
    setState(() {
      _totalPrice = total;
    });
  }

  void _confirmCheckout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_pengguna');

    if (userId == null) {
      setState(() {
        _errorMessage = 'User ID tidak ditemukan. Silakan login ulang.';
      });
      return;
    }

    final recipientName = _recipientNameController.text;
    final recipientAddress = _recipientAddressController.text;

    if (recipientName.isEmpty || recipientAddress.isEmpty) {
      setState(() {
        _errorMessage = 'Nama penerima dan alamat penerima tidak boleh kosong.';
      });
      return;
    }

    final url = 'http://localhost/api/demo/confirm_checkout.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'id_pengguna': userId.toString(),
        'nama_penerima': recipientName,
        'alamat_penerima': recipientAddress,
        'metode_pembayaran': _selectedPaymentMethod,
        'total_harga': _totalPrice.toString(),
        'produk': jsonEncode(_checkoutProducts.map((product) => product.toJson()).toList()),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dikonfirmasi')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Checkout gagal: ${data['message']}';
        });
      }
    } else {
      setState(() {
        _errorMessage =
            'Checkout gagal dengan kode status: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Checkout'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text('Error: $_errorMessage'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Penerima',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _recipientNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Penerima',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _recipientAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Penerima',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     final recipientName =
                        //         _recipientNameController.text;
                        //     final recipientAddress =
                        //         _recipientAddressController.text;

                        //     if (recipientName.isEmpty || recipientAddress.isEmpty) {
                        //       setState(() {
                        //         _errorMessage =
                        //             'Nama penerima dan alamat penerima tidak boleh kosong.';
                        //       });
                        //     } else {
                        //       _confirmCheckout();
                        //     }
                        //   },
                        //   child: const Text('Konfirmasi Pesanan'),
                        // ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedPaymentMethod,
                          hint: const Text('Pilih metode pembayaran'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPaymentMethod = newValue!;
                            });
                          },
                          items: <String>[
                            'Transfer ke Rekening BRI',
                            'Transfer ke Rekening Mandiri',
                            'Transfer ke Rekening BNI',
                            'Transfer ke Rekening BCA'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _checkoutProducts.length,
                      itemBuilder: (context, index) {
                        final product = _checkoutProducts[index];
                        return ListTile(
                          leading: Image.asset(
                            'assets/images/${product.gambar}',
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.namaBarang),
                          subtitle: Text(
                              'Rp ${product.harga.toStringAsFixed(2)} x ${product.jumlah ?? 1}'),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${_totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
  padding: const EdgeInsets.all(16.0),
  child: Center(
    child: ElevatedButton(
      onPressed: () {
        final recipientName = _recipientNameController.text;
        final recipientAddress = _recipientAddressController.text;

        if (recipientName.isEmpty || recipientAddress.isEmpty) {
          setState(() {
            _errorMessage = 'Nama penerima dan alamat penerima tidak boleh kosong.';
          });
        } else {
          setState(() {
            _errorMessage = null; // Reset error message if input is valid
          });
          _confirmCheckout();
        }
      },
      child: const Text('Konfirmasi Pesanan'),
    ),
  ),
),

                ],
              ),
  );
}
}