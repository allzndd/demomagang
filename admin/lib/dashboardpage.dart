import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Pastikan paket ini ditambahkan di pubspec.yaml
import 'package:http/http.dart' as http;
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
        setState(() {
          totalUsers = json.decode(userResponse.body)['user_count'];
        });
      }

      // Fetch sales data
      final salesResponse = await http.get(Uri.parse('http://localhost/api/demo/sales_data.php'));
      if (salesResponse.statusCode == 200) {
        setState(() {
          salesData = List<double>.from(json.decode(salesResponse.body)['sales']);
        });
      }

      // Fetch stock data
      final stockResponse = await http.get(Uri.parse('http://localhost/api/demo/stock_data.php'));
      if (stockResponse.statusCode == 200) {
        setState(() {
          stockData = List<Map<String, dynamic>>.from(json.decode(stockResponse.body)['stock']);
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
        backgroundColor: Color(0xFF2B8249), // Warna top bar
      ),
      body: SingleChildScrollView( // Menambahkan scroll untuk menghindari overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Count
            _buildUserCountCard(),

            SizedBox(height: 16.0),

            // Sales Graph
            _buildSalesChart(),

            SizedBox(height: 16.0),

            // Stock Diagram
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
            icon: Icon(Icons.analytics),
            label: 'Reports',
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
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2B8249)),
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
                            colors: [Color(0xFF2B8249)],
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
                                y: (stock['stok'] as num).toDouble(),
                                colors: [Color(0xFF007250)],
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
}
