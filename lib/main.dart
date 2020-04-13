import 'package:coronavirus/icon_badge.dart';
import 'package:coronavirus/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coronavirus/news_page.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coronavirus Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coronavirus Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  PageController _pageController;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  int _page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Color(0xfffcfcff),
          statusBarIconBrightness: Brightness.light));
    }
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    Widget barIcon(
        {IconData icon = Icons.home, int page = 0, bool badge = false}) {
      return IconButton(
        icon: badge ? IconBadge(icon: icon, size: 30) : Icon(icon, size: 30),
        color: _page == page ? Colors.white : Colors.white70,
        onPressed: () => _pageController.jumpToPage(page),
      );
    }

    return Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        appBar: AppBar(
          leading: Text(''),
          title: Center(
            child: Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await Share.text(
                      '',
                      'Get the latest news and statistics about Covid-19, only on the Coronavirus Tracker app',
                      'text/plain');
                },
              ),
            )
          ],
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 2,
              ),
              barIcon(icon: Icons.class_, page: 0),
              barIcon(icon: Icons.map, page: 1),
              SizedBox(
                width: 5,
              ),
            ],
          ),
          color: Color(0xFFEB1555),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            stats_screen(),
            news_page(),
          ],
          controller: _pageController,
          onPageChanged: onPageChanged,
        ));
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
