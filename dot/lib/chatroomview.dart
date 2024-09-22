import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatroomPage extends StatefulWidget {
  final String chatId;
  final String chatusername;
  const ChatroomPage(this.chatId, this.chatusername, {Key? key})
      : super(key: key);

  @override
  ChatroomState createState() => ChatroomState();
}

class ChatroomState extends State<ChatroomPage> {
  late String userId;
  String userimage = 'sdf';
  String username = 'You';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _shouldScrollToBottom = true;
  File? _userimage;

  List<Map<String, dynamic>> _messages = [];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    firstLoad();
    startTimer();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _loadMessages();
    });
  }

  void firstLoad() async {
    await _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = await prefs.getString('userid') ?? '';

      final response = await http.get(Uri.parse(
          'http://103.216.159.116:8700/messages/${widget.chatId}?userid=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _messages =
              List<Map<String, dynamic>>.from(data['messages']).map((message) {
            // Construct the image URL if chatimage is not null
            if (message['chatimage'] != null &&
                message['chatimage'].isNotEmpty) {
              message['imageUrl'] =
                  'http://103.216.159.116:8950/images/${widget.chatId}/${message['chatimage']}';
            }
            return message;
          }).toList();
          userimage = data['currentUser']['userimage'];
          username = data['currentUser']['username'];
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _shouldScrollToBottom = true;
          });
        });
      } else {
        showMessageDialog(context, 'Error',
            'Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    if (_shouldScrollToBottom) {
      final position = _scrollController.position;
      if (position.hasContentDimensions) {
        _scrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    _shouldScrollToBottom = false;
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _userimage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _onMessageSend(String text) async {
    if (text.isNotEmpty || _userimage != null) {
      try {
        final response = await http.post(
          Uri.parse('http://103.216.159.116:8800/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'chatid': widget.chatId,
            'userID': userId,
            'message': text,
          }),
        );

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            String chatdataid =
                data['chatdataid'].toString(); // แปลงเป็น string
            String chatid = data['chatid'].toString(); // แปลงเป็น string

            if (_userimage != null) {
              await _uploadImage(_userimage!, chatdataid, chatid);
              setState(() {
                _userimage = null;
              });
            }

            _loadMessages();
            setState(() {
              _messageController.clear();
              _shouldScrollToBottom = true;
            });
            _scrollToBottom();
          } catch (e) {
            showMessageDialog(
                context, 'Error', 'Error parsing JSON response: $e');
          }
        } else {
          showMessageDialog(context, 'Error', 'Failed to send message');
        }
      } catch (e) {
        showMessageDialog(context, 'Error', 'Error sending message: $e');
      }
    }
  }

  Future<void> _uploadImage(
      File image, String chatdataid, String chatid) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://103.216.159.116:8950/upload_image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
      request.fields['chatdataid'] = chatdataid;
      request.fields['chatid'] = chatid;
      request.fields['userID'] = userId;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        String imageUrl = data['imageUrl'];

        setState(() {
          _messages.add({
            'username': username,
            'chatmessage': '', // ไม่มีข้อความ
            'imageUrl': imageUrl, // ใช้ imageUrl แทน
            'userimage': userimage,
            'chatuserid': userId,
          });
          _shouldScrollToBottom = true;
        });
        _scrollToBottom();
      } else {
        showMessageDialog(
            context, 'Error', 'Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
        title: Text(
          widget.chatusername,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatMessage(
                    message['username'],
                    message['chatmessage'],
                    message['userimage'],
                    message['chatuserid'],
                    message['imageUrl']);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String user, String message, String userImage,
      String userID, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: userID == userId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: userID == userId
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'http://103.216.159.116:8300/images/$userImage'),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Text(
                user,
                style: const TextStyle(
                    color: Color.fromARGB(255, 117, 84, 55),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: userID == userId
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Align(
                  alignment: userID == userId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    color: userID == userId
                        ? const Color.fromARGB(255, 247, 223, 202)
                        : const Color.fromARGB(255, 117, 84, 55),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 250,
                            ) // แสดงรูปภาพ
                          : Text(
                              message,
                              style: userID == userId
                                  ? const TextStyle(
                                      color: Color.fromARGB(255, 117, 84, 55))
                                  : const TextStyle(
                                      color:
                                          Color.fromARGB(255, 247, 223, 202)),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Color.fromARGB(255, 117, 84, 55),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            color: Colors.white,
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Aa',
                hintStyle: TextStyle(color: Color.fromARGB(255, 117, 84, 55)),
                filled: true,
                fillColor: Color.fromARGB(255, 255, 237, 222),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 117, 84, 55)),
              onSubmitted: _onMessageSend,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.white,
            onPressed: () => _onMessageSend(_messageController.text),
          ),
        ],
      ),
    );
  }

  void showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
