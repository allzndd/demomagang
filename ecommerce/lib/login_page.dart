import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'dashboardpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primaryColor: const Color(0xFFE0F752),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFF9C416),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF020306)),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    String usernameOrEmail = _usernameOrEmailController.text;
    String password = _passwordController.text;

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your username/email and password.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        final response = await http.post(
          Uri.parse('http://localhost/api/login.php'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': usernameOrEmail,
            'password': password,
          },
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 &&
            responseData['message'] == 'Login successful') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              duration: Duration(seconds: 2),
            ),
          );

          // Periksa apakah id_pengguna, username, dan surel tidak null sebelum menyimpan
          if (responseData['id_pengguna'] != null &&
              responseData['username'] != null &&
              responseData['surel'] != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('id_pengguna', responseData['id_pengguna']);
            await prefs.setString('username', responseData['username']);
            await prefs.setString('surel', responseData['surel']);

            // Print id_pengguna, username, dan surel yang disimpan
            print('ID Pengguna yang disimpan: ${responseData['id_pengguna']}');
            print('Username yang disimpan: ${responseData['username']}');
            print('Surel yang disimpan: ${responseData['surel']}');

            // Navigator.push(
            //   // context,
            //   // MaterialPageRoute(builder: (context) => DashboardPage()),
            // );
          } else {
            throw Exception('User data is incomplete');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${responseData['message']}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred during login: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Positioned.fill(
            child: Container(
              color: Color(0xFF2B8249).withOpacity(
                  0.5), // Mengubah background overlay menjadi hijau tua dengan transparansi
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: MediaQuery.of(context).size.width *
                        0.4, // Sesuaikan ukuran logo
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  const SizedBox(height: 20), // Jarak antara logo dan form
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.42,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(
                              0xFF2B8249), // Warna hijau tua untuk container child
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameOrEmailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors
                                    .white, // Background putih untuk TextField
                                labelText: 'Username or Email',
                                prefixIcon: Icon(Icons.person,
                                    color: const Color(0xFF2B8249)
                                        .withOpacity(0.7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username or email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors
                                    .white, // Background putih untuk TextField
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock,
                                    color: const Color(0xFF2B8249)
                                        .withOpacity(0.7)),
                                // obscureText: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24.0),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _login(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color(
                                    0xFF1C5734), // Warna teks lebih gelap
                                backgroundColor:
                                    const Color(0xFFFFFFFF), // Background putih
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 5.0,
                                shadowColor: const Color(
                                    0xFF1C5734), // Shadow berwarna hijau tua
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 12.0),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(
                                    0xFF1C5734), // Warna teks lebih gelap
                              ),
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
