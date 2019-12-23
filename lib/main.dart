import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tags/tag.dart';

import 'avalon.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Avalon Asistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> players = {};
  final _addPlayerController = TextEditingController();

  List<Widget> buildPlayerChips() {
    List<Widget> playerChips = <Widget>[];
    players.forEach((p) => playerChips.add(
      InputChip(
        label: Text(p),
        onDeleted: () {
          setState(() {
            players.remove(p);
          });
        })
    ));
    return playerChips;
  }

  bool addAPlayer(String name) {
    bool addSuccess;
    setState(() {
      addSuccess = players.add(name);
    });

    return addSuccess;
  }

  Widget buildPlayerTagPanel() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          ...buildPlayerChips(),
          Container(
            width: 100,
            child: TextField(
              controller: _addPlayerController,
              decoration: InputDecoration(
                labelText: 'Add a Player',
              ),
              onSubmitted: (t) {
                if (players.length >= 10) {
                  print("Maxium 10 players are allowed for this game");
                } else if (!addAPlayer(t)){
                  print("Please use different name for each player");
                } 
                _addPlayerController.clear();

              }
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfigPanel() {
    return Text('Config');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildPlayerTagPanel(),
            buildConfigPanel(),
          ],
        ),
      ),
    );
  }
}
 
