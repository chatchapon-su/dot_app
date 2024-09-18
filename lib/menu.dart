import 'package:dot/chat.dart';
import 'package:dot/friend.dart';
import 'package:dot/voom.dart';
import 'package:flutter/material.dart';
import 'news.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Menu',
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;

  Widget tab1() {
    return const FriendPage();
  }

  Widget tab2() {
    return const ChatPage();
  }

  Widget tab3() {
    return VoomPage();
  }

  Widget tab4() {
    return NewsPage();
  }

  Widget defaultContent() {
    return const Center(
        child: Icon(
      Icons.error_outline,
      size: 150,
      color: Colors.red,
    ));
  }

  Widget getContent(int index) {
    switch (index) {
      case 0:
        return tab1();
      case 1:
        return tab2();
      case 2:
        return tab3();
      case 3:
        return tab4();
      default:
        return defaultContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 117, 84, 55),
      body: getContent(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 117, 84, 55),
        selectedItemColor: Color.fromARGB(255, 226, 184, 148),
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded),
            label: 'Friend',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow_rounded), label: 'Voom'),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_rounded), label: 'Today'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
