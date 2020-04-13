import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const card_color = Color(0xFF1D1E33);
const bg_color = Color(0xFF0A0E21);
const pinky = Color(0xFFEB1555);
const text_color = Color(0xFF8D8E98);

class stats_screen extends StatefulWidget {
  @override
  _stats_screenState createState() => _stats_screenState();
}

class _stats_screenState extends State<stats_screen> {
  int infected = 0, dead = 0, recovered = 0, sick = 0;
  double fatality_rate = 0, recovery_rate = 0;
  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _statslist = [];

  _getStats() async {
    Query q = _firestore.collection('basic_stats');
    QuerySnapshot qSnap = await q.getDocuments();
    _statslist = qSnap.documents;
    for (var stat in _statslist) {
      infected = stat.data['infected'] as int;
      dead = stat.data['dead'] as int;
      recovered = stat.data['recovered'] as int;
      sick = stat.data['sick'] as int;
      fatality_rate = stat.data['fatality_rate'] as double;
      recovery_rate = stat.data['recovery_rate'] as double;
    }
    setState(() {});
  }

  List<Widget> news_final = [];
  List<DocumentSnapshot> _newsList = [];
  bool _loadingNews = false;
  int _perPage = 10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;

  _getNews() async {
    Query q = _firestore
        .collection('countries')
        .orderBy('cases', descending: true)
        .limit(_perPage);
    setState(() {
      _loadingNews = true;
    });
    QuerySnapshot qSnap = await q.getDocuments();
    _lastDocument = qSnap.documents[qSnap.documents.length - 1];
    _newsList = qSnap.documents;

    for (var news in _newsList) {
      news_final.add(
          country_stats(name: news.data['name'], cases: news.data['cases']));
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
        .collection('countries')
        .orderBy('cases', descending: true)
        .startAfter([_lastDocument.data['cases']]).limit(_perPage);

    QuerySnapshot qSnap = await q.getDocuments();

    if (qSnap.documents.length == 0) {
      _moreProductsAvailable = false;
    }

    _lastDocument = qSnap.documents[qSnap.documents.length - 1];
    _newsList = qSnap.documents;
    for (var news in _newsList) {
      news_final.add(
          country_stats(name: news.data['name'], cases: news.data['cases']));
    }
    setState(() {
      _gettingMoreProducts = false;
    });
  }

  @override
  void initState() {
    _getStats();
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
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$infected',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'INFECTED',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$dead',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'DEAD',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$recovered',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'RECOVERED',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$sick',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'CURRENTLY SICK',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$fatality_rate%',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'FATALITY RATE',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  height: MediaQuery.of(context).size.height / 4.5,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$recovery_rate%',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'RECOVERY RATE',
                        style: TextStyle(fontSize: 18.0, color: text_color),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: card_color,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 20.0, bottom: 20.0),
              child: Text(
                "Cases by Country",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 36),
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

class country_stats extends StatelessWidget {
  country_stats({@required this.name, @required this.cases});
  final String name;
  final int cases;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$cases',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 35),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              name,
              style: TextStyle(
                  color: pinky, fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: card_color,
        ),
      ),
    );
  }
}
