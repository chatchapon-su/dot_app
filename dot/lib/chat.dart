import 'dart:convert';
import 'package:flutter/material.dart';
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
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
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
        showMessageDialog(context, 'Error', 'Failed to load chat rooms: ${response.statusCode}');
      }
    } catch (e) {
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
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      // ฟังก์ชันที่จะเรียกทุกๆ 1 วินาที
      fetchChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
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
                  primary: Color.fromARGB(255, 251, 237, 218),
                  onPrimary: Colors.white,
                  elevation: 0,
                ),
                child: Card(
                  elevation: 0,
                  color: Color.fromARGB(255, 251, 237, 218),
                  child: Row(
                    children: [
                      CircleAvatar(
                        foregroundImage: NetworkImage(
                          'http://103.216.159.116:8300/images/${chatRoom['userImage']}'
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chatRoom['userName'],
                        style: TextStyle(color: Color.fromARGB(255, 136, 136, 136)),
                      ),
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
