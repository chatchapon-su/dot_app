import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: must_be_immutable
class NewsPage extends StatefulWidget {
  NewsPage({Key? key}) : super(key: key);

  @override
  NewsState createState() => NewsState();
}

class NewsState extends State<NewsPage> {
  String usercountry = '';
  List<dynamic> newsDatatmp = [];

  var parameters = 'country=';
  var apikey = 'apiKey=f25cfe0fff9d48008de8ccc890369cb0';
  var api = 'https://newsapi.org/v2/top-headlines';

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      usercountry = prefs.getString('usercountry') ?? '';

      if (usercountry.isNotEmpty) {
        await fetchNews(usercountry);
        //showMessageDialog(context, 'country', usercountry);
      } else {
        showMessageDialog(context, 'Error', 'User country is empty');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error reading SharedPreferences: $e');
    }
  }

  Future<void> fetchNews(String usercountry) async {
    try {
      var url = Uri.parse('$api?$parameters$usercountry&$apikey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> newsdata = json.decode(response.body);
        setState(() {
          newsDatatmp = newsdata['articles'];
        });
      } else {
        showMessageDialog(context, 'Error', 'Failed to load news');
      }
    } catch (e) {
      showMessageDialog(context, 'Error', 'Error fetching news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 237, 218),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
        title: const Text(
          'News',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newsDatatmp.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 251, 237, 218),
                  ),
                  onPressed: () async {
                    final url = Uri.parse(newsDatatmp[index]['url']);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      showMessageDialog(context, 'Error', 'Could not launch URL');
                    }
                  },
                  child: Card(
                    elevation: 0,
                    color: const Color.fromARGB(255, 251, 237, 218),
                    child: SizedBox(
                      width: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsDatatmp[index]['title'] ?? 'No title',
                              style: const TextStyle(color: Colors.black),
                            ),
                            Text(
                              newsDatatmp[index]['author'] ?? 'No author',
                              style: const TextStyle(color:  Color.fromARGB(255, 136, 136, 136)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
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
