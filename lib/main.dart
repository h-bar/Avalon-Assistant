import 'dart:math';

import 'package:flutter/material.dart';

import 'avalon.dart';

void main() => runApp(AvalonAssistant());

class AvalonAssistant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddPlayer(title: 'Avalon Asistant'),
    );
  }
}

class AddPlayer extends StatefulWidget {
  AddPlayer({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AddPlayerState createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  Set<String> players = {"A", "B", "C", "D", "E"};
  int nPlayers = 5;
  List identites = [];
  Map config = Avalon.getDefaultConfig(5);
  final _addPlayerController = TextEditingController();

  bool addPlayer(String name) {
    bool addSuccess;
    setState(() {
      addSuccess = players.add(name);
      nPlayers = max(players.length, 5);
      config = Avalon.getDefaultConfig(nPlayers);
    });

    return addSuccess;
  }
  void removePlayer(String name) {
    setState(() {
      players.remove(name);
      nPlayers = max(players.length, 5);
      config = Avalon.getDefaultConfig(nPlayers);
    });
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

  Widget playerPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Players", 
          style: Theme.of(context)
                  .textTheme
                  .headline,
        ),
        Wrap(
          spacing: 8,
          children: players.map((String p) => 
            InputChip(
              label: Text(p),
              // avatar: CircleAvatar(child: Text(p.substring(0, 1)),),
              onDeleted: () => removePlayer(p),
            )
          ).toList()
        ),
        TextField(
            controller: _addPlayerController,
            decoration: InputDecoration.collapsed(hintText: "Add a Player"),
            onSubmitted: (t) {
              if (players.length >= 10) {
                print("Maxium 10 players are allowed for this game");
              } else if (!addPlayer(t)){
                print("Please use different name for each player");
              } 
              _addPlayerController.clear();
            }
          ),
      ],
    );
  }

  Widget charactorItem(Charactor c) {
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

  Widget charactorPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Charactors", 
          style: Theme.of(context)
                  .textTheme
                  .headline,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: Avalon.allGood.map((c) => charactorItem(c)).toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: Avalon.allEvil.map((c) => charactorItem(c)).toList(),
            )
          ]
        ),

      ],
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            playerPanel(),
            charactorPanel(),
            startGameBtn(),
          ],
        ),
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
