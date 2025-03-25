import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SelectvoomPage extends StatefulWidget {
  final String userselectid;

  const SelectvoomPage({Key? key, required this.userselectid})
      : super(key: key);

  @override
  SelectvoomState createState() => SelectvoomState();
}

class SelectvoomState extends State<SelectvoomPage> {
  late String userId = '';
  late String userimage = '';
  late String username = '';
  String? selectedPrivacy = 'Public';
  List<dynamic> posts = [];
  TextEditingController postController = TextEditingController();

  late String newPrivacy = '';

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userid') ?? '';
      userimage = prefs.getString('userimage') ?? '';
      username = prefs.getString('username') ?? '';

      if (userId.isNotEmpty) {
        await fetchPosts();
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'User ID is empty');
      }
    } catch (e) {
      showMessageDialog(
          // ignore: use_build_context_synchronously
          context,
          'Error',
          'Error reading SharedPreferences: $e');
    }
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://yourdomain:8990/selectvoom_posts/$userId/${widget.userselectid}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['posts'] != null) {
          setState(() {
            posts = List<dynamic>.from(data['posts']);
          });
        } else {
          // ignore: use_build_context_synchronously
          showMessageDialog(context, 'Error', 'No posts found');
        }
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(
            // ignore: use_build_context_synchronously
            context,
            'Error',
            'Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessageDialog(context, 'Error', 'Error fetching posts: $e');
    }
  }

  // Future<void> postMessage() async {
  //   if (postController.text.isEmpty) {
  //     showMessageDialog(
  //         context, 'Empty Post', 'Please enter some text for the post.');
  //     return;
  //   }

  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://yourdomain:8990/create_post'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'userid': userId,
  //         'voomtext': postController.text,
  //         'voomprivacy': selectedPrivacy,
  //       }),
  //     );
  //     //showMessageDialog(context, 'Test', 'response.statusCode : ${response}');
  //     if (response.statusCode == 200) {
  //       //showMessageDialog(context, 'Success', 'Post created successfully');
  //       postController.clear();
  //       fetchPosts(); // Reload posts after creating a new one
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showMessageDialog(context, 'Error', 'Failed to create post');
  //     }
  //   } catch (e) {
  //     // ignore: use_build_context_synchronously
  //     showMessageDialog(context, 'Error', 'Error creating post: $e');
  //   }
  // }

  void deletePost(String postId) async {
    try {
      final response = await http.put(
        Uri.parse('http://yourdomain:8990/mark_post_as_deleted'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'postId': postId}),
      );
      if (response.statusCode == 200) {
        // Handle successful deletion
        fetchPosts(); // Reload posts after marking as deleted
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'Failed to mark post as deleted');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessageDialog(context, 'Error', 'Error marking post as deleted: $e');
    }
  }

  void changePrivacy(String postId) async {
    try {
      //showMessageDialog(context, 'test', 'postId : $postId newPrivacy : $newPrivacy');
      final response = await http.put(
        Uri.parse('http://yourdomain:8990/update_post_privacy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'postId': postId,
          'newPrivacy': newPrivacy,
        }),
      );

      if (response.statusCode == 200) {
        //showMessageDialog(context, 'Success', 'Post privacy updated successfully');
        fetchPosts();
      } else {
        // ignore: use_build_context_synchronously
        showMessageDialog(context, 'Error', 'Failed to update post privacy');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessageDialog(context, 'Error', 'Error updating post privacy: $e');
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
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF754C24),
        title: const Text('Voom', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings, color: Colors.white),
        //     onPressed: () {
        //       // Navigate to settings or other action
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width, // กำหนดความกว้างให้เท่ากับความกว้างของหน้าจอ
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (posts.isNotEmpty) 
                      Column(
                        children: [
                          CircleAvatar(
                            foregroundImage: NetworkImage(
                              'http://yourdomain:8300/images/${posts[0]['userimage']}',
                            ),
                            radius: 50,
                          ),
                          const SizedBox(width: 20),
                          const SizedBox(height: 20),
                          Text(
                            posts[0]['username'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    else
                      const Text('กำลังโหลดข้อมูล...'),
                  ],
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                var post = posts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  foregroundImage: NetworkImage(
                                    'http://yourdomain:8300/images/${post['userimage']}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  post['username'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  post['voomprivacy'] == 'Public'
                                      ? Icons.public
                                      : Icons.people_rounded,
                                  size: 20,
                                  color: post['voomprivacy'] == 'Public'
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post['voomtext'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (post['userid'] ==
                            userId) // Check if the post is by the current user
                          Align(
                            alignment: Alignment.topRight,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'Delete') {
                                  deletePost(post['voomid'].toString());
                                } else if (value == 'Change Privacy') {
                                  setState(() {
                                    if (post['voomprivacy'].toString() ==
                                        'Public') {
                                      newPrivacy = 'Private';
                                    } else {
                                      newPrivacy = 'Public';
                                    }
                                    //print('Current Privacy: ${post['voomprivacy']}');
                                    //print('New Privacy: $newPrivacy');
                                  });

                                  changePrivacy(post['voomid'].toString());
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'Change Privacy',
                                  child: Text('Change Privacy'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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
        ],
      );
    },
  );
}
