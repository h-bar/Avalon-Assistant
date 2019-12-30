import 'dart:math';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'avalon.dart';

void main() => runApp(AvalonAssistant());

Widget makeACard(String imgPath, String caption, {int count = 1, bool showOneCount = false}) {
  return Badge(
      badgeContent: Text(count.toString()),
      showBadge: showOneCount || count != 1,
      animationType: null,
      position: BadgePosition( top: 0, right: 4, ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image(
            fit: BoxFit.fitWidth,
            width: double.infinity,
            image: AssetImage(imgPath),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
              color: Colors.grey[200].withOpacity(0.75),
            ),
            child: Text(
              caption,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ), 
  );
}
Widget makeGrids({List<Widget> children, int count = 4}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List<int>.generate((children.length ~/ count) + 1, (i) => i).map(
      (i) => Row(
        children: List<int>.generate(count, (j) => j).map(
          (j) => Flexible(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: children.length > i * count + j ? children[i * count + j] : SizedBox(),
            )
          )
        ).toList()
      )
    ).toList()
  );
}

class AvalonAssistant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avalon Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddPlayer(title: 'Avalon Assistant'),
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
      color: Theme.of(context).accentColor,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => IdentityAssignment(Avalon(players.toList(), config)),
        ));
      }
    );
  }

  void replaceCardDialog(Charactor c) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: makeGrids(
          children: (Avalon.allGood.contains(c) ? Avalon.allGood : Avalon.allEvil)
          .where(
            (newC) => config['charactors'][newC] == 0 || 
            newC == Charactor.minion || 
            newC == Charactor.servant)
          .map(
            (Charactor newC) => InkResponse(
              onTap: () {
                removeCharactor(c);
                addCharactor(newC);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: makeACard(
                "assets/" + Avalon.getName(newC) + ".png", 
                Avalon.getName(newC),
              )
            )
          ).toList(),
          count: 3
        ),     
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Map config = Avalon.getDefaultConfig(nPlayers);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
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
          makeGrids(
            children: Avalon.allGood.where((c) => config['charactors'][c] != 0).map(
              (Charactor c) => InkResponse(
                onTap: () => replaceCardDialog(c),
                child: makeACard(
                  "assets/" + Avalon.getName(c) + ".png", 
                  Avalon.getName(c),
                  count: config['charactors'][c]
                )
              )
            ).toList(),
          ),
          makeGrids(
            children: Avalon.allEvil.where((c) => config['charactors'][c] != 0).map(
              (Charactor c) => InkResponse(
                onTap: () => replaceCardDialog(c),
                child: makeACard(
                  "assets/" + Avalon.getName(c) + ".png", 
                  Avalon.getName(c),
                  count: config['charactors'][c]
                )
              )
            ).toList(),
          ),

          Expanded(child: SizedBox()),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child:  Wrap(
              spacing: 4,
              children: players.map((String p) => 
                InputChip(
                  label: Text(p),
                  // avatar: CircleAvatar(child: Text(p.substring(0, 1)),),
                  onDeleted: () => removePlayer(p),
                )
              ).toList()
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
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
          ),
          Center( child: startGameBtn() )
      ])
    );
  }
}

class IdentityAssignment extends StatelessWidget {
  final Avalon game;
  IdentityAssignment(this.game);

  void revealIdentity(BuildContext context, String player) {
    Charactor c = game.getIdentity(player);
    Map<Charactor, List<String>> knowledge = game.getKnowledge(player);

    showDialog(
      context: context,
      builder: (_) => Center( 
        child: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          width: 300,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            // margin: EdgeInsets.symmetric(vertical: 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row( 
                  children: [
                    Expanded( 
                      child: Image(
                        fit: BoxFit.fitWidth,
                        image: AssetImage("assets/" + Avalon.getName(c) + ".png"),
                      )
                    ),
                  ]
                ),
                SizedBox.fromSize(size: Size(0, 10),),
                Text(
                  Avalon.getName(c),
                  style: Theme.of(context).textTheme.headline,
                ),
                Text(
                  Avalon.getDescroption(c),
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox.fromSize(size: Size(0, 10),),
                Column(
                  children: knowledge.keys.map(
                    (Charactor c) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/" + Avalon.getName(c) + ".png"),
                          ),
                          Wrap(
                            alignment: WrapAlignment.start,
                            children: knowledge[c].where((name) => name != player).map(
                              (name) => Chip(label: Text(name))
                            ).toList(),
                          )
                        ],
                      );
                    }
                  ).toList(),
                ),
              ],
            )
          )      
        )
      )
    );
  }

  Widget startQuestBtn(BuildContext context) {
    return FlatButton(
      color: Theme.of(context).accentColor,
      child: Text('Start Quests'),
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: makeGrids(
              children: game.getAllPlayers().map(
                (String player) => InkResponse(
                  onTap: () => revealIdentity(context, player),
                  child: makeACard(
                    "assets/Back.png", 
                    player,
                  )
                )
              ).toList(),
            ),
          ),
          startQuestBtn(context),
        ],
      )
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
            
          ],
        ),
    );
  }
}
