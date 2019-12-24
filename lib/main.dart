import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  List identites = [];
  Map config = Avalon.getDefaultConfig(5);
  final _addPlayerController = TextEditingController();

  bool addAPlayer(String name) {
    bool addSuccess;
    setState(() {
      addSuccess = players.add(name);
      config = Avalon.getDefaultConfig(max(players.length, 5));
    });

    return addSuccess;
  }

  List<Widget> buildPlayerChips() {
    List<Widget> playerChips = <Widget>[];
    players.forEach((p) => playerChips.add(
      InputChip(
        label: Text(p),
        onDeleted: () {
          setState(() {
            players.remove(p);
            config = Avalon.getDefaultConfig(max(players.length, 5));
          });
        })
    ));
    return playerChips;
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
    List<Widget> goods = [], evils = [];
    Avalon.allGood.forEach((c) {
      String configText = Avalon.getName(c) + ": " + config['charactors'][c].toString();
      goods.add(Text(configText));
    });
    Avalon.allEvil.forEach((c) {
      String configText = Avalon.getName(c) + ": " + config['charactors'][c].toString();
      evils.add(Text(configText));
    });
    return Row(
      children: <Widget>[
        Column(
          children: goods,
        ),
        Column(
          children: evils,
        )
      ],
    );
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
            FlatButton(
              child: Text('Start Game'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => IdentityAssignment(Avalon(players.toList(), config)),
                ));
              }
            ), 
          ],
        ),
      ),
    );
  }
}

class IdentityAssignment extends StatelessWidget {
  Avalon game;
  IdentityAssignment(Avalon game) {
    this.game = game;
  }

  void revealIdentity(BuildContext context, String player) {
    String identity = Avalon.getName(game.getIdentity(player));

    Map knowledge = game.getKnowledge(player);

    // for Avalon.charactorInfo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(identity),
          content: Text(knowledge.toString()),
        );
      },
    );
  }

  List<Widget> buildPlayerTiles(BuildContext context) {
    List<Widget> playerTiles = <Widget>[];
    game.getAllPlayers().forEach((p) => playerTiles.add(
      ActionChip(
        label: Text(p),
        onPressed: () => revealIdentity(context, p),
        )
    ));
    return playerTiles;
  }

  @override
  Widget build(BuildContext context ) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Identity Assignment"),
      ),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.start,
          children: [
            ...buildPlayerTiles(context),
          ],
        ),
      ),
    );
  }
}
 
