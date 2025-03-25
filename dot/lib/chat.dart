import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chatroomview.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<ChatPage> {
  late String userId = '';
  List<Map<String, dynamic>> chatRooms = [];

  late Timer _timer;

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userid') ?? '';

      if (userId.isNotEmpty) {
        fetchChatRooms();
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessageDialog(context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  Future<void> fetchChatRooms() async {
    try {
      final response = await http.get(Uri.parse('http://103.216.159.116:8600/chatrooms/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          chatRooms = List<Map<String, dynamic>>.from(data['chatrooms']);
        });
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'Failed to load chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessageDialog(context, 'Error', 'Error fetching chat rooms: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    readData();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // ฟังก์ชันที่จะเรียกทุกๆ 1 วินาที
      fetchChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 84, 55),
        title: const Text('Chat', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: chatRooms.map((chatRoom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: () async{
                  //await showMessageDialog(context, 'Chat', 'Chat ID : ${chatRoom['chatid']}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatroomPage(chatRoom['chatid'].toString(),chatRoom['userName']),//ChatroomPage(chatRoom['chatid']),
                    ),
                  );
                  //showMessageDialog(context, 'Chat', 'Chat ID : ${chatRoom['chatid']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 251, 237, 218),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        //radius: 30,
                        backgroundImage: NetworkImage(
                          'http://103.216.159.116:8300/images/${chatRoom['userImage']}',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatRoom['userName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                            const SizedBox(height: 5),
                            chatRoom['lastMessage'] != null?
                            Text(
                              chatRoom['lastMessage'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ):Text(
                              '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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
