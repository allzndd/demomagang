import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_pengguna');
      final username = prefs.getString('username');
      final email = prefs.getString('surel');

      if (userId == null || username == null || email == null) {
        throw Exception('User data is incomplete');
      }

      setState(() {
        nameController.text = username;
        emailController.text = email;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveUserData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_pengguna');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID pengguna tidak ditemukan di sesi')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost/api/profil.php'), // Ganti dengan alamat server yang benar
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id': userId.toString(),
          'nama_pengguna': nameController.text,
          'surel': emailController.text,
        },
      );

      print('Mengirim data: ${{
        'id': userId.toString(),
        'nama_pengguna': nameController.text,
        'surel': emailController.text,
      }}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data pengguna berhasil diperbarui')),
        );
        setState(() {
          isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data pengguna')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: const Color(0xFF020306)),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/your_illustration.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Pengguna',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: nameController,
                              enabled: isEditing,
                              decoration: InputDecoration(labelText: 'Nama Pengguna'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama pengguna tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: emailController,
                              enabled: isEditing,
                              decoration: InputDecoration(labelText: 'Surel'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Surel tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                  child: Text('Edit'),
                                ),
                                ElevatedButton(
                                  onPressed: isEditing
                                      ? () {
                                          print('Menyimpan dengan nilai: ${nameController.text}, ${emailController.text}');
                                          saveUserData(context);
                                        }
                                      : null,
                                  child: Text('Simpan'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                    });
                                  },
                                  child: Text('Batal'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
