import 'dart:math';

import 'package:coronavirus/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';

class news_page extends StatefulWidget {
  @override
  _news_pageState createState() => _news_pageState();
}

class _news_pageState extends State<news_page> {
  List<Widget> news_final = [];
  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _newsList = [];
  bool _loadingNews = false;
  int _perPage = 10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;

  _getNews() async {
    Query q = _firestore
        .collection('corona_news')
        .orderBy('timestamp', descending: true)
        .limit(_perPage);
    setState(() {
      _loadingNews = true;
    });

    QuerySnapshot qSnap = await q.getDocuments();
    _lastDocument = qSnap.documents[qSnap.documents.length - 1];
    _newsList = qSnap.documents;

    for (var news in _newsList) {
      if (news.data['type'] == 'text') {
        news_final.add(text_news(
            borderColor: Colors.pink,
            text: news.data['text'],
            timestamp: news.data['timestamp'],
            source_url: news.data['source']));
      } else if (news.data['type'] == 'image') {
        news_final.add(image_news(
            borderColor: Colors.pink,
            text: news.data['text'],
            timestamp: news.data['timestamp'],
            source_url: news.data['source'],
            image: news.data['image']));
      }
    }
    setState(() {
      _loadingNews = false;
    });
  }

  _getMoreNews() async {
    print('get more news called');

    if (_moreProductsAvailable == false) {
      return;
    }

    if (_gettingMoreProducts == true) {
      return;
    }

    _gettingMoreProducts = true;

    Query q = _firestore
        .collection('corona_news')
        .orderBy('timestamp', descending: true)
        .startAfter([_lastDocument.data['timestamp']]).limit(_perPage);

    QuerySnapshot qSnap = await q.getDocuments();

    if (qSnap.documents.length == 0) {
      _moreProductsAvailable = false;
    }

    _lastDocument = qSnap.documents[qSnap.documents.length - 1];
    _newsList = qSnap.documents;
    for (var news in _newsList) {
      if (news.data['type'] == 'text') {
        news_final.add(text_news(
            borderColor: pinky,
            text: news.data['text'],
            timestamp: news.data['timestamp'],
            source_url: news.data['source']));
      } else if (news.data['type'] == 'image') {
        news_final.add(image_news(
            borderColor: pinky,
            text: news.data['text'],
            timestamp: news.data['timestamp'],
            source_url: news.data['source'],
            image: news.data['image']));
      }
    }
    setState(() {
      _gettingMoreProducts = false;
    });
  }

  @override
  void initState() {
    _getNews();
    _scrollController.addListener(() {
      double _maxScroll = _scrollController.position.maxScrollExtent;
      double _currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (_maxScroll - _currentScroll <= delta) {
        _getMoreNews();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20.0, bottom: 20.0),
              child: Text(
                "Latest News",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30),
              ),
            ),
            _loadingNews == true
                ? Container()
                : Container(
                    child: _newsList.length == 0
                        ? Container()
                        : Column(
                            children: news_final,
                          ))
          ],
        ),
      ),
    );
  }
}

class text_news extends StatelessWidget {
  ScreenshotController screenshotController = ScreenshotController();
  File _imageFile;
  final MaterialColor borderColor;
  final String text;
  final String timestamp;
  final String source_url;

  text_news(
      {Key key,
      @required this.borderColor,
      @required this.text,
      @required this.timestamp,
      @required this.source_url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: InkWell(
        onLongPress: () {
          screenshotController
              .capture(pixelRatio: 1.5)
              .then((File image) async {
            //Capture Done
            _imageFile = image;
            var path = _imageFile.path;
            final ByteData bytes = await rootBundle.load(path);
            await Share.file(
              '${DateTime.now()} News',
              '${DateTime.now()}.png',
              bytes.buffer.asUint8List(),
              'image/png',
            );
          });
        },
        onTap: () {
          if (Platform.isIOS) {
            launch(source_url, forceSafariVC: false);
          } else {
            FlutterWebBrowser.openWebPage(
                url: source_url, androidToolbarColor: Colors.black);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 12.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: Colors.white),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Text(
                        timeago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(timestamp) * 1000),
                            locale: 'en_short'),
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        screenshotController
                            .capture(pixelRatio: 1.5)
                            .then((File image) async {
                          //Capture Done
                          _imageFile = image;
                          var path = _imageFile.path;
                          final ByteData bytes = await rootBundle.load(path);
                          if (Platform.isAndroid) {
                            await Share.file(
                                '${DateTime.now()} News',
                                '${DateTime.now()}.png',
                                bytes.buffer.asUint8List(),
                                'image/png',
                                text:
                                    'Get the latest news and statistics about Covid-19, only on the Coronavirus Tracker app');
                          } else {
                            await Share.text(
                                '',
                                '${text} \n. Get the latest news and statistics about Covid-19, only on the Coronavirus Tracker app',
                                'text/plain');
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: borderColor,
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 4.0, left: 10.0),
                                child: Text(
                                  'share',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                    right: 10.0,
                                    left: 2.0),
                                child: Icon(
                                  Icons.share,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 2.0),
                      child: Text(
                        'src',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      child: Icon(
                        Icons.launch,
                        size: 14.0,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: card_color,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
      ),
    );
  }
}

class image_news extends StatelessWidget {
  ScreenshotController screenshotController = ScreenshotController();
  File _imageFile;
  final MaterialColor borderColor;
  final String text;
  final String timestamp;
  final String source_url;
  final String image;

  image_news(
      {Key key,
      @required this.borderColor,
      @required this.text,
      @required this.timestamp,
      @required this.source_url,
      @required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: InkWell(
        onLongPress: () {
          screenshotController
              .capture(pixelRatio: 1.5)
              .then((File image) async {
            //Capture Done
            _imageFile = image;
            var path = _imageFile.path;
            final ByteData bytes = await rootBundle.load(path);
            await Share.file(
              '${DateTime.now()} News',
              '${DateTime.now()}.png',
              bytes.buffer.asUint8List(),
              'image/png',
            );
          });
        },
        onTap: () {
          if (Platform.isIOS) {
            launch(source_url, forceSafariVC: false);
          } else {
            FlutterWebBrowser.openWebPage(
                url: source_url, androidToolbarColor: Colors.black);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: card_color,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15.0, left: 12.0, right: 12.0, top: 1.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: Colors.white),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Text(
                        timeago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(timestamp) * 1000),
                            locale: 'en_short'),
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        screenshotController
                            .capture(pixelRatio: 1.5)
                            .then((File image) async {
                          //Capture Done
                          _imageFile = image;
                          var path = _imageFile.path;
                          final ByteData bytes = await rootBundle.load(path);
                          if (Platform.isAndroid) {
                            await Share.file(
                                '${DateTime.now()} News',
                                '${DateTime.now()}.png',
                                bytes.buffer.asUint8List(),
                                'image/png',
                                text:
                                    'Get the latest news and statistics about Covid-19, only on the Coronavirus Tracker app');
                          } else {
                            await Share.text(
                                '',
                                '${text} \nGet the latest news and statistics about Covid-19, only on the Coronavirus Tracker app',
                                'text/plain');
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: borderColor,
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 4.0, left: 10.0),
                                child: Text(
                                  'share',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                    right: 10.0,
                                    left: 2.0),
                                child: Icon(
                                  Icons.share,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 2.0),
                      child: Text(
                        'src',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      child: Icon(
                        Icons.launch,
                        size: 14.0,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
