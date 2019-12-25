import 'dart:math';

import 'package:flutter/material.dart';

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
  int nPlayers = 5;
  List identites = [];
  Map config = Avalon.getDefaultConfig(5);
  final _addPlayerController = TextEditingController();

  bool addAPlayer(String name) {
    bool addSuccess;
    setState(() {
      addSuccess = players.add(name);
      nPlayers = max(players.length, 5);
      config = Avalon.getDefaultConfig(nPlayers);
    });

    return addSuccess;
  }

  bool addCharactor(Charactor c) {
    int nCharactors = 0;
    config['charactors'].forEach((c, n) => nCharactors += n);
    if (nCharactors >= nPlayers) {
      return false;
    }

    setState(() {
       config['charactors'][c] ++;
    });
    return true;
  }

  bool removeCharactor(Charactor c) {
    if (config['charactors'][c] <= 0) {
      return false;
    }

    setState(() {
       config['charactors'][c] --;
    });
    return true;
  }


  Widget buildPlayerChips() {
    List<Widget> playerChips = <Widget>[];
    players.forEach((p) => playerChips.add(
       InputChip(
        label: Text(p),
        onDeleted: () {
          setState(() {
            players.remove(p);
            nPlayers = max(players.length, 5);
            config = Avalon.getDefaultConfig(nPlayers);
          });
        })
    ));
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: playerChips
    );
  }

  Widget buildConfigItem(Charactor c) {
    String configText = Avalon.getName(c) + ": " + config['charactors'][c].toString();
    Text charactor = Text(Avalon.getName(c));
    Text number = Text(config['charactors'][c].toString());

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle), 
          onPressed: () {
            setState(() {
              removeCharactor(c);
            });
          },
        ),
        Text(configText),
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            setState(() {
              addCharactor(c);
            });
          },
        ),
      ]);
  }

  Widget buildConfigPanel() {
    List<Widget> goods = [], evils = [];
    Avalon.allGood.forEach((c) {
      goods.add(buildConfigItem(c));
    });
    Avalon.allEvil.forEach((c) {
      evils.add(buildConfigItem(c));
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
 
  Widget addPlayerBtn() {
    return TextField(
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
    );
  }

  Widget startGameBtn() {
    return FlatButton(
      child: Text('Start Game'),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => IdentityAssignment(Avalon(players.toList(), config)),
        ));
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildPlayerChips(),
            addPlayerBtn(),
            buildConfigPanel(),
            startGameBtn(),
          ],
        ),
    );
  }
}

class IdentityAssignment extends StatelessWidget {
  final Avalon game;
  IdentityAssignment(this.game);

  void revealIdentity(BuildContext context, String player) {
    String identity = Avalon.getName(game.getIdentity(player));

    Map knowledge = game.getKnowledge(player);

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

  Widget taskBtn(BuildContext context) {
    return FlatButton(
      child: Text('Vote for tasks'),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => TaskPage(),
        ));
      }
    );
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
            taskBtn(context),
          ],
        ),
      ),
    );
  }
}


 
class TaskPage extends StatefulWidget {
  TaskPage({Key key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int nVotes = 0;
  int _nApproves = 0;
  int _nRejects = 0;
  int nApproves = 0;
  int nRejects = 0;

  Widget buildVoteOptoins() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.done),
          onPressed: () {
            _nApproves++;
            setState(() {
              nVotes++;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            _nRejects++;
            setState(() {
              nVotes++;
            });
          },
        ),
      ],
    );
  }

  Widget buildResults() {
    return Row(
      children: <Widget>[
        Text("Votes: " + nVotes.toString()),
        Text("Approved: " + nApproves.toString()),
        Text("Rejected: " + nRejects.toString()),
      ],
    );
  }

  Widget buildActions() {
    return Row(
      children: <Widget>[
        FlatButton(
          child: Text("Show results"),
          onPressed: () {
            setState(() {
              nApproves = _nApproves;
              nRejects = _nRejects;
            });
          },
       ),
       FlatButton(
          child: Text("Clear votes"),
          onPressed: () {
            setState(() {
              nVotes = 0;
              _nApproves = 0;
              _nRejects = 0;
              nApproves = 0;
              nRejects = 0;
            });
          },
       )
    ],);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Task"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildVoteOptoins(),
            buildResults(),
            buildActions(),
          ],
        ),
    );
  }
}
