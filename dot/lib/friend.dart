import 'dart:convert';
import 'package:dot/addfriend.dart';
import 'package:dot/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chatroomview.dart';
import 'dart:async';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  FriendState createState() => FriendState();
}

class FriendState extends State<FriendPage> {
  late String userId = '';
  late String username = '';
  late String userimage = '';
  late String useremail = '';
  late String usercountry = '';

  List<Map<String, dynamic>> userdata = [];
  List<Map<String, dynamic>> frienddata = [];

  late Timer _timer;

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userid') ?? '';

      if (userId.isNotEmpty) {
        fetchUserData();
      } else {
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  Future<void> saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (userdata.isNotEmpty) {
        await prefs.setString('usercountry', userdata[0]['userCountry']);
        await prefs.setString('userimage', userdata[0]['userImage']);
        await prefs.setString('username', userdata[0]['userName']);
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Failed to save data');
    }
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://103.216.159.116:8200/user/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          setState(() {
            userdata = [
              {
                'userID': data['user']['userid'],
                'userName': data['user']['username'],
                'userImage': data['user']['userimage'],
                'userCountry': data['user']['usercountry']
              }
            ];
            frienddata = List<Map<String, dynamic>>.from(data['friends']?.map((friend) => {
              'userID': friend['userid'],
              'userName': friend['username'],
              'userImage': friend['userimage']
            }) ?? []);
          });
          saveData();
        } else {
          showMessageDialog(context, 'Error', 'User data is missing in response');
        }
      } else {
        showMessageDialog(context, 'Error', 'Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error fetching user data: $e');
    }
  }

  Future<void> handleChatRoom(String friendId, String friendname) async {
    final url = Uri.parse('http://103.216.159.116:8500/chatroom');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': userId, 'friendid': friendId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final chatId = data['chatid'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatroomPage(chatId.toString(), friendname),
        ),
      );
    } else {
      showMessageDialog(context, 'Error', 'Failed to create or retrieve chatroom');
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
    _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
      fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
        title: const Text('Friend', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (userdata.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  showUserProfile(context, userId);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 251, 237, 218),
                  onPrimary: Colors.white,
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(
                            'http://103.216.159.116:8300/images/${userdata[0]['userImage']}'),
                      ),
                    ),
                    Text(
                      userdata[0]['userName'],
                      style: TextStyle(color: Color.fromARGB(255, 136, 136, 136)),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(color: Color.fromARGB(255, 226, 184, 148)),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text('Friends',
                    style: TextStyle(
                        color: Color.fromARGB(255, 136, 136, 136),
                        fontSize: 15)),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Addfriend()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 251, 237, 218),
                      onPrimary: Color.fromARGB(255, 117, 84, 55),
                      elevation: 0,
                    ),
                    child: Icon(Icons.person))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: frienddata.length,
              itemBuilder: (context, index) {
                final dataperson = frienddata[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      showFriendProfile(context, dataperson['userID'], dataperson['userName'], dataperson['userImage']);
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
                                'http://103.216.159.116:8300/images/${dataperson['userImage']}'),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            dataperson['userName'],
                            style: TextStyle(
                                color: Color.fromARGB(255, 136, 136, 136)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error fetching user profile: $e');
    }
  }

  Future<dynamic> showUserProfile(BuildContext context, String userId) async {
    await fetchUserProfile(userId);

    // ignore: use_build_context_synchronously
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove default padding
          // title: TextButton(
          //   child: const Text('X'),
          //   onPressed: () {
          //     Navigator.pop(context, true);
          //   },
          // ),
          content: SizedBox(
            height: 400,
            width: double.maxFinite, // Take full width of the AlertDialog
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity, // Ensure the container takes the full width
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/D_t.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      foregroundImage: NetworkImage('http://103.216.159.116:8300/images/${userimage}'),
                      radius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Color.fromARGB(255, 117, 84, 55)),
                            const SizedBox(width: 15),
                            Text(username, style: const TextStyle(color: Color.fromARGB(255, 226, 184, 148) , fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.credit_card_rounded, color: Color.fromARGB(255, 117, 84, 55)),
                            const SizedBox(width: 15),
                            Text(userId, style: const TextStyle(color: Color.fromARGB(255, 226, 184, 148) , fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.email_rounded, color: Color.fromARGB(255, 117, 84, 55)),
                            const SizedBox(width: 15),
                            Text(useremail, style: const TextStyle(color: Color.fromARGB(255, 226, 184, 148), fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Color.fromARGB(255, 117, 84, 55)),
                            const SizedBox(width: 15),
                            Text(usercountry,
                                style: const TextStyle(color: Color.fromARGB(255, 226, 184, 148), fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity, // Make the button take full width
                  height: 50 ,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 59, 59),
                      onPrimary: Colors.white,
                    ),
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<dynamic> showFriendProfile(BuildContext context, String friendId,String friendname,String friendimage){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove default padding
          content: SizedBox(
            height: 400,
            width: double.maxFinite, // Take full width of the AlertDialog
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity, // Ensure the container takes the full width
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/D_t.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      foregroundImage: NetworkImage('http://103.216.159.116:8300/images/${friendimage}'),
                      radius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        friendname,
                        style: TextStyle(color: Color.fromARGB(255, 226, 184, 148), fontSize: 25),
                      ),
                    ),
                  ),
                ),
                const Spacer(), // This will push the button to the bottom
                SizedBox(
                  width: double.infinity, // Make the button take full width
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      handleChatRoom(friendId, friendname);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 117, 84, 55),
                      onPrimary: Color.fromARGB(255, 226, 184, 148),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.chat_rounded),
                        Text('Chat'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
}
