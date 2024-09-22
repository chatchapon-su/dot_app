import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Addfriend extends StatefulWidget {
  const Addfriend({Key? key}) : super(key: key);

  @override
  _AddfriendState createState() => _AddfriendState();
}

class _AddfriendState extends State<Addfriend> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _useridController = TextEditingController();

  late String userId = '';

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userid') ?? '';

      if (userId.isNotEmpty) {
        // เรียกข้อมูลสำเร็จ
      } else {
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  Future<void> addFriend() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final friendId = _useridController.text;

        final body = jsonEncode({
          'userid': userId,
          'friendid': friendId,
        });

        final response = await http.post(
          Uri.parse('http://103.216.159.116:8400/addfriend'),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          showMessageDialog(context, 'Success', 'Friend added successfully');
        } else {
          showMessageDialog(context, 'Error', 'Failed to add friend: ${response.statusCode}');
        }
      } catch (e) {
        showMessageDialog(context, 'Error', 'Error adding friend: $e');
      }
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
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Add Friend', style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 226, 184, 148))),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text('User ID', style: TextStyle(color: Color.fromARGB(255, 226, 184, 148))),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _useridController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 255, 255),
                      hintText: 'User ID',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
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
                  ElevatedButton(
                    onPressed: addFriend,
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 117, 84, 55),
                      onPrimary: const Color.fromARGB(255, 226, 184, 148),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ],
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
        ],
      );
    },
  );
}
