import 'dart:convert';
import 'package:dot/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfilePage> {
  late String userId = '';
  late String username = '';
  late String userimage = '';
  late String useremail = '';
  late String usercountry = '';

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userid') ?? '';

      if (userId.isNotEmpty) {
        await fetchUserProfile(userId);
      } else {
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://103.216.159.116:8900/getUserProfile'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          username = data['username'] ?? 'N/A';
          userimage = data['userimage'] ?? '';
          useremail = data['useremail'] ?? 'N/A';
          usercountry = data['usercountry'] ?? 'N/A';
        });
      } else {
        showMessageDialog(context, 'Error', 'Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error fetching user profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 84, 55),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                foregroundImage: userimage.isNotEmpty
                    ? NetworkImage('http://103.216.159.116:8300/images/$userimage')
                    : const AssetImage('assets/images/Dot.jpg') as ImageProvider,
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Color.fromARGB(255, 117, 84, 55)),
                  title: Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.credit_card_rounded, color: Color.fromARGB(255, 117, 84, 55)),
                  title: Text(userId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.email_rounded, color: Color.fromARGB(255, 117, 84, 55)),
                  title: Text(useremail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.flag, color: Color.fromARGB(255, 117, 84, 55)),
                  title: Text(usercountry, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 59, 59),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showMessageDialog(BuildContext context, String headerMsg, String msg) {
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
        ],
      );
    },
  );
}
