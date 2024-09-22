import 'dart:convert';
import 'package:dot/login.dart';
import 'package:dot/menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  File? _userimage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _userid = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> _countries = [];
  String? _selectedCountryCode;

  bool validateEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _username.dispose();
    _userid.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> saveData(String userid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username.text.trim());
      await prefs.setString('password', _passwordController.text.trim());
      await prefs.setString('userid', userid);
    } catch (e) {
      showMessageDialog(context, 'Error', 'Failed to save data');
    }
  }

  Future<void> getPhotoGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _userimage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<File> _createTempFileFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> fetchCountries() async {
    try {
      final response =
          await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _countries = data.map<String>((country) => country['cca2']).toList();
        });
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Failed to load countries: $e');
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://103.216.159.116:8000/signup'),
        );

        request.fields['userid'] = _userid.text.trim();
        request.fields['useremail'] = _emailController.text.trim();
        request.fields['username'] = _username.text.trim();
        request.fields['userpassword'] = _passwordController.text.trim();
        request.fields['usercountry'] = _selectedCountryCode ?? '';

        if (_userimage != null) {
          request.files.add(
            await http.MultipartFile.fromPath('userimage', _userimage!.path),
          );
        } else {
          final tempFile =
              await _createTempFileFromAssets('assets/images/Dot.jpg');
          request.files.add(
            await http.MultipartFile.fromPath('userimage', tempFile.path),
          );
        }

        final response = await request.send();

        if (response.statusCode == 201) {
          await saveData(_userid.text.trim());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Menu()),
          );
        } else {
          final responseBody = await response.stream.bytesToString();
          if (response.statusCode == 409) {
            showMessageDialog(
                context, 'Error', 'User ID or email already exists');
          } else {
            showMessageDialog(
                context, 'Error', 'Failed to sign up: $responseBody');
          }
        }
      } catch (e) {
        showMessageDialog(context, 'Error', 'Failed to sign up: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('Sign Up',
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 251, 237, 218),
                         elevation: 0,
                         shadowColor: Colors.transparent, // ลบเงาตอน hover
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(Colors.transparent), // ลบเอฟเฟกต์สีตอน hover
                      ),
                      onPressed: getPhotoGallery,
                      child: CircleAvatar(
                        //backgroundColor: Colors.transparent, // ตั้งค่าพื้นหลังให้โปร่งใสเพื่อลบขอบ
                        backgroundImage: _userimage != null
                            ? FileImage(_userimage!)
                            : const AssetImage('assets/images/D t.jpg')
                                as ImageProvider,
                        radius: 50,
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // DropdownButtonFormField<String>(
                    //   value: _selectedCountryCode,
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     hintText: 'Select Country',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   items: _countries
                    //       .map((country) => DropdownMenuItem<String>(
                    //             value: country,
                    //             child: Text(country),
                    //           ))
                    //       .toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _selectedCountryCode = value;
                    //     });
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'กรุณาเลือกประเทศ';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 117, 84, 55), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก Email';
                        } else if (!validateEmail(value)) {
                          return 'รูปแบบ Email ไม่ถูกต้อง';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Username',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 117, 84, 55), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก Username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _userid,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'User ID',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 117, 84, 55), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก User ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCountryCode,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Select Country',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 117, 84, 55), width: 2.0),
                        ),
                      ),
                      items: _countries
                          .map((country) => DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาเลือกประเทศ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 117, 84, 55), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก Password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          signUp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 117, 84, 55),
                      ),
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        //if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                        //}
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 251, 237, 218),
                        onPrimary: Color.fromARGB(255, 117, 84, 55),
                        elevation: 0,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showMessageDialog(
    BuildContext context, String headerMsg, String msg) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(headerMsg, style: const TextStyle(fontSize: 16)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(msg)],
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ]);
      });
}
