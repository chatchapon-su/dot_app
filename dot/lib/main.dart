//shared_preferences
//https://grassrootengineer.medium.com/flutter-shared-preferences-9f0f31bdbf89
//image_picker
//https://pub.dev/packages/image_picker/install
//https://medium.com/%E0%B8%A1%E0%B8%B2%E0%B8%AA%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C-%E0%B8%AD%E0%B8%B6%E0%B9%88%E0%B8%87/image-picker-60b8b03535d3
//Flutter run -d chrome --web-port=65000
//flutter run -d chrome --web-browser-flag "--disable-web-security"
//flutter run -d chrome --web-browser-flag "--disable-web-security" --web-port=65000

import 'dart:convert';
import 'package:dot/login.dart';
import 'package:dot/menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String readUsername = '';
  late String readPassword = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _navigateToNextScreen());
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // แสดงหน้าโลโก 3 วินาที
    await readData();
    //showMessageDialog(context, 'Error', 'Username : $readUsername\nPassword : $readPassword');
    await checkdata();
    // if (mounted) {
    // if (readUsername.isNotEmpty && readPassword.isNotEmpty) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const Menu()), // เปลี่ยนไปที่หน้าหลักหรือหน้าถัดไป
    //   );
    // } else {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const Login()),
    // );
    // }
    // }
  }

  Future<void> login() async {
    //if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse('http://103.216.159.116:8100/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'useremail': readUsername,
            'userpassword': readPassword,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userid =
              responseData['userid'] ?? '';

          if (userid.isNotEmpty) {
            await saveData(userid);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Menu()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        } else {
          //showMessageDialog(context, 'Error', 'Invalid credentials');
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
        }
      } catch (e) {
        showMessageDialog(context, 'Error', 'Failed to login');
      }
    //}
  }

  Future<void> saveData(String userid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', readUsername);
      await prefs.setString('password', readPassword);
      await prefs.setString('userid', userid); // Save userid
    } catch (e) {
      showMessageDialog(context, 'Error', 'Failed to save data');
    }
  }

  Future<void> checkdata() async {
    try {
      //showMessageDialog(
      //    context, 'waiting', 'Checkdata');
      if (readUsername.isNotEmpty && readPassword.isNotEmpty) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const Menu()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error checkdata: $e');
    }
  }

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      readUsername = prefs.getString('username') ?? '';
      readPassword = prefs.getString('password') ?? '';
    } catch (e) {
      // ignore: avoid_print
      //print('Error reading SharedPreferences: $e');
      showMessageDialog(
          context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      body: Center(
        child: Image(
          image: AssetImage('assets/images/D_t.jpg'),
          width: 300,
          height: 300,
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
            title: Text(
              headerMsg,
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(msg),
                ],
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
