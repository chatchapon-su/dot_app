import 'package:dot/chat.dart';
import 'package:dot/friend.dart';
import 'package:dot/selectvoom.dart';
import 'package:dot/voom.dart';
import 'package:flutter/material.dart';
import 'news.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dot Menu',
      home: MenuPage(),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;
  String _userselectid = '';

  void changemenuIndex(int index, String userselectid) {
    setState(() {
      _currentIndex = 4;
      _userselectid = userselectid;
    });
  }

  Widget tab1() {
    return const FriendPage();
  }

  Widget tab2() {
    return const ChatPage();
  }

  Widget tab3() {
    return VoomPage(changemenuIndex: changemenuIndex);
  }

  Widget tab4() {
    return const NewsPage();
  }

  Widget tab5() {
    return SelectvoomPage(userselectid: _userselectid);
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
      case 4:
        return tab5();
      default:
        return defaultContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 84, 55),
      body: getContent(_currentIndex),
      bottomNavigationBar: Container(
        height: 55, // ปรับความสูงที่นี่
        color: const Color.fromARGB(255, 117, 84, 55),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                _currentIndex = 0;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // ลบพื้นหลัง
                shadowColor: Colors.transparent, // ลบเงา
                padding: EdgeInsets.zero, // ลบ padding
                // ปรับค่าต่างๆ ตามที่คุณต้องการ
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ใช้ขนาดที่น้อยที่สุด
                children: [
                  Icon(Icons.person_2_rounded,
                      color: _currentIndex == 0
                          ? const Color.fromARGB(255, 226, 184, 148)
                          : Colors.white),
                  Text('Friend',
                      style: TextStyle(
                          color: _currentIndex == 0
                              ? const Color.fromARGB(255, 226, 184, 148)
                              : Colors.white)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _currentIndex = 1;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // ลบพื้นหลัง
                shadowColor: Colors.transparent, // ลบเงา
                padding: EdgeInsets.zero, // ลบ padding
                // ปรับค่าต่างๆ ตามที่คุณต้องการ
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ใช้ขนาดที่น้อยที่สุด
                children: [
                  Icon(Icons.chat_rounded,
                      color: _currentIndex == 1
                          ? const Color.fromARGB(255, 226, 184, 148)
                          : Colors.white),
                  Text('Chat',
                      style: TextStyle(
                          color: _currentIndex == 1
                              ? const Color.fromARGB(255, 226, 184, 148)
                              : Colors.white)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _currentIndex = 2;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // ลบพื้นหลัง
                shadowColor: Colors.transparent, // ลบเงา
                padding: EdgeInsets.zero, // ลบ padding
                // ปรับค่าต่างๆ ตามที่คุณต้องการ
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ใช้ขนาดที่น้อยที่สุด
                children: [
                  Icon(Icons.play_arrow_rounded,
                      color: _currentIndex == 2
                          ? const Color.fromARGB(255, 226, 184, 148)
                          : Colors.white),
                  Text('Voom',
                      style: TextStyle(
                          color: _currentIndex == 2
                              ? const Color.fromARGB(255, 226, 184, 148)
                              : Colors.white)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _currentIndex = 3;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // ลบพื้นหลัง
                shadowColor: Colors.transparent, // ลบเงา
                padding: EdgeInsets.zero, // ลบ padding
                // ปรับค่าต่างๆ ตามที่คุณต้องการ
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ใช้ขนาดที่น้อยที่สุด
                children: [
                  Icon(Icons.newspaper_rounded,
                      color: _currentIndex == 3
                          ? const Color.fromARGB(255, 226, 184, 148)
                          : Colors.white),
                  Text('Today',
                      style: TextStyle(
                          color: _currentIndex == 3
                              ? const Color.fromARGB(255, 226, 184, 148)
                              : Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
