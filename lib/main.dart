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
  int nItems = children != null ? children.length : 0;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List<int>.generate((nItems ~/ count) + 1, (i) => i).map(
      (i) => Row(
        children: List<int>.generate(count, (j) => j).map(
          (j) => Flexible(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: nItems > i * count + j ? children[i * count + j] : SizedBox(),
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
      home: SetupPage(title: 'Avalon Assistant'),
    );
  }
}

class SetupPage extends StatefulWidget {
  SetupPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Set<String> players = {};
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
          builder: (context) => RevealPage(Avalon(players.toList(), config)),
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
            padding: EdgeInsets.symmetric(horizontal: 4),
            child:  Wrap(
              spacing: 4,
              children: players.map((String p) => 
                InputChip(
                  label: Text(p),
                  onDeleted: () => removePlayer(p),
                )
              ).toList()
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
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

class RevealPage extends StatelessWidget {
  final Avalon game;
  RevealPage(this.game);

  void revealIdentity(BuildContext context, String player) {
    Map<Charactor, List<String>> knowledge = game.getKnowledge(player);
    String identity = Avalon.getName(game.getIdentity(player));
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox.fromSize(
          size: Size.fromWidth(200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              makeACard("assets/" + identity + ".png", identity),
              SizedBox.fromSize(size: Size.fromHeight(5),),
              ...knowledge.keys.map(
                (Charactor c) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: makeACard("assets/" + Avalon.getName(c) + ".png", Avalon.getName(c)),
                    ),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child:  Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 4,
                          children: knowledge[c].where((name) => name != player).map(
                            (name) => Chip(label: Text(name))
                          ).toList(),
                        )
                      )
                    ),
                  ],
                )
              ).toList(),
              FlatButton(
                child: Text('Ok'),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        )
      ),     
    );
  }

  Widget startQuestBtn(BuildContext context) {
    return FlatButton(
      color: Theme.of(context).accentColor,
      child: Text('Start Quests'),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => QuestPage(),
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

class QuestPage extends StatefulWidget {
  QuestPage({Key key}) : super(key: key);

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  Widget finishedQuests;
  int nVotes = 0;
  int nSuccesses = 0;
  int nFails = 0;

  bool success() {
    if (nVotes >= 5) {
      return false;
    }
    setState(() {
      nVotes++;
      nSuccesses++;
      vote();
    });

    return true;
  }

  bool fail() {
    if (nVotes >= 5) {
      return false;
    }
    setState(() {
      nVotes++;
      nFails++;
      vote();
    });
    return true;
  }

  void vote() {
    finishedQuests = makeGrids(
        count: 3,
        children: List<int>.generate(nVotes, (i) => i).map((_) =>
          makeACard("assets/QuestBack.png", "Vote")
      ).toList());
  }

  Widget revealQuestBtn() {
    return FlatButton(
      child: Text('Reveal Quest Results'),
      color: Theme.of(context).accentColor,
      onPressed: () {
        setState(() {
          finishedQuests = makeGrids(
            count: 3,
            children: List<int>.generate(nSuccesses, (i) => i).map((_) =>
              makeACard("assets/Success.png", "Success")
          ).toList()
          ..addAll(
            List<int>.generate(nFails, (i) => i).map((_) =>
              makeACard("assets/Fail.png", "Fail")
            ).toList()
          ));
        });
      }
    );
  }

  Widget resetBtn() {
    return FlatButton(
      child: Text("Reset Quests"),
      color: Theme.of(context).accentColor,
      onPressed: () {
        setState(() {
          nVotes = 0;
          nSuccesses = 0;
          nFails = 0;
          vote();
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    finishedQuests = makeGrids(
      count: 5,
      children: List<int>.generate(nVotes, (i) => i).map((_) =>
        makeACard("assets/QuestBack.png", "Completed")
    ).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Task"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            finishedQuests,
            Expanded(child: SizedBox(),),
            makeGrids(
              count: 2,
              children: [
                InkResponse(
                  onTap: success,
                  child: makeACard("assets/Success.png", "Success"),
                ),
                InkResponse(
                  onTap: fail,
                  child: makeACard("assets/Fail.png", "Fail"),
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                revealQuestBtn(),
                resetBtn()
              ],
            )
          ],
        ),
    );
  }
}
