import 'dart:math';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

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

  void replaceCard(Charactor c) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: FittedBox(
          child: Column(
            children: [
              Image(
                image: AssetImage("assets/" + Avalon.getName(c) + ".png"),
              ),
            ]
          )
        )
      )
    );
  }

  Card makeCard(Charactor c) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      // color: Colors.black45,
      margin: new EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
      child: Badge(
        badgeContent: Text(Avalon.getDefaultConfig(nPlayers)['charactors'][c].toString()),
        position: BadgePosition(
          top: 0,
          right: 4,
        ),
        child: InkResponse(
          onTap: () => replaceCard(c),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              Image(
                image: AssetImage("assets/" + Avalon.getName(c) + ".png"),
              ),
              SizedBox(
                width: double.infinity,
                child: Opacity(
                  opacity: 0.75,
                  child: Container(
                    // alignment: Alignment.bottomCenter,
                    color: Colors.grey[200],
                    child: Text(
                      Avalon.getName(c),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ), 
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    Map config = Avalon.getDefaultConfig(nPlayers);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {},
          )
        ],
      ),
      body: Column (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    childAspectRatio: 0.71,
                    physics: NeverScrollableScrollPhysics(),
                    children: Avalon.allGood.where((c) => config['charactors'][c] != 0).map(
                                (Charactor c) => makeCard(c)
                              ).toList(),
                  ),
                ),
                Flexible(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    childAspectRatio: 0.71,
                    physics: NeverScrollableScrollPhysics(),
                    children: Avalon.allEvil.where((c) => config['charactors'][c] != 0).map(
                                (Charactor c) => makeCard(c)
                              ).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 4,
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
            ),
          )

      ])
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
