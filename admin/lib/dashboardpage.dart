import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'profil_page.dart';
import 'login_page.dart';
import 'adminpesananpage.dart'; // Import halaman AdminPesananPage
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalUsers = 0;
  List<double> salesData = [];
  List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _fetchDashboardData() async {
    try {
      // Fetch user count
      final userResponse = await http.get(Uri.parse('http://localhost/api/demo/user_count.php'));
      if (userResponse.statusCode == 200) {
        var userJson = json.decode(userResponse.body);
        setState(() {
          totalUsers = userJson['user_count'] as int; // Pastikan parsing sebagai int
        });
      }

      // Fetch sales data
      final salesResponse = await http.get(Uri.parse('http://localhost/api/demo/sales_data.php'));
      if (salesResponse.statusCode == 200) {
        var salesJson = json.decode(salesResponse.body);
        setState(() {
          salesData = List<double>.from(salesJson['sales']); // Pastikan parsing sebagai double
        });
      }

      // Fetch stock data
      final stockResponse = await http.get(Uri.parse('http://localhost/api/demo/stock_data.php'));
      if (stockResponse.statusCode == 200) {
        var stockJson = json.decode(stockResponse.body);
        setState(() {
          stockData = List<Map<String, dynamic>>.from(stockJson['stock']); // Pastikan parsing ke List<Map>
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF2B8249),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.white), // Ikon untuk halaman AdminPesanan
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPesananPage()),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.exit_to_app, color: Color(0xFFFFFFFF)),
            onSelected: (value) {
              if (value == 'akun_saya') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'logout') {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserCountCard(),
            SizedBox(height: 16.0),
            _buildSalesChart(),
            SizedBox(height: 16.0),
            _buildStockDiagram(),
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
            icon: Icon(Icons.inventory), // Ikon untuk menggambarkan daftar barang
            label: 'Daftar Barang',
          ),
        ],
        selectedItemColor: Color(0xFF007250),
        unselectedItemColor: Color(0xFF88C14F),
        onTap: (index) {
          if (index == 0) {
            _fetchDashboardData(); // Refresh halaman dashboard
          } else if (index == 1) {
            Navigator.pushNamed(context, '/barang'); // Arahkan ke halaman ItemListPage
          }
        },
      ),
    );
  }

  Widget _buildUserCountCard() {
    return Card(
      color: Color(0xFFE0F752),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Users',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Text(
              '$totalUsers',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      color: Color(0xFFB8E052),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Sales by Month',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 200,
              child: salesData.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: salesData.asMap().entries.map((entry) {
                              int idx = entry.key;
                              double sales = entry.value;
                              return FlSpot(idx.toDouble(), sales);
                            }).toList(),
                            isCurved: true,
                            colors: [Colors.black],
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true, colors: [
                              Color(0xFF2B8249).withOpacity(0.3),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : Center(child: Text("No sales data available")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDiagram() {
    return Card(
      color: Color(0xFF88C14F),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Stock Levels',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 200,
              child: stockData.isNotEmpty
                  ? BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        barGroups: stockData.map((stock) {
                          return BarChartGroupData(
                            x: stock['id_barang'],
                            barRods: [
                              BarChartRodData(
                                y: (stock['stok'] as int).toDouble(),
                                colors: [Colors.black],
                                width: 16,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Center(child: Text("No stock data available")),
            ),
          ],
        ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
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
