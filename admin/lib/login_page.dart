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

  bool _isPasswordHidden = true;
  bool _showErrorUsername = false;
  bool _showErrorPassword = false;


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
          Uri.parse('http://localhost/api/demo/loginadmin.php'),
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

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
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
            color: Color(0xFFFFFFFF).withOpacity(0.5),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'logo.png',
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF2B8249),
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
                              fillColor: Colors.white,
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
                                return null;
                              }
                              return null;
                            },
                          ),
                          if (_showErrorUsername)
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Please enter your username or email',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 18.0),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock,
                                  color: const Color(0xFF2B8249)
                                      .withOpacity(0.7)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFF2B8249)
                                      .withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: _isPasswordHidden,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              return null;
                            },
                          ),
                          if (_showErrorPassword)
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Please enter your password',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _showErrorUsername = _usernameOrEmailController.text.isEmpty;
                                  _showErrorPassword = _passwordController.text.isEmpty;
                                });

                                if (!_showErrorUsername && !_showErrorPassword) {
                                  _login(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF1C5734),
                              backgroundColor: const Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5.0,
                              shadowColor: const Color(0xFF1C5734),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Text('Masuk'),
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
                              foregroundColor: const Color(0xFFFFFFFF),
                            ),
                            child: const Text('Daftar Admin'),
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
