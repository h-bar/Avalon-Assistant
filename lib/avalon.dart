import 'package:flutter/rendering.dart';

enum Charactor { assassin, mordred, morgana, minion, oberon, percival, merlin, servant }

class Avalon { 
  static const Map charactorInfo = {
    Charactor.assassin: {
      'name': 'Assassin',
      'description': '',
      'knowledge': {
        Charactor.assassin: Charactor.minion,
        Charactor.mordred: Charactor.minion,
        Charactor.morgana: Charactor.minion,
        Charactor.minion: Charactor.minion,
      },
    },
    Charactor.mordred: {
      'name': 'Mordred',
      'description': '',
      'knowledge': {
        Charactor.assassin: Charactor.minion,
        Charactor.mordred: Charactor.minion,
        Charactor.morgana: Charactor.minion,
        Charactor.minion: Charactor.minion,
      },
    },
    Charactor.morgana: {
      'name': 'Morgana',
      'description': '',
      'knowledge': {
        Charactor.assassin: Charactor.minion,
        Charactor.mordred: Charactor.minion,
        Charactor.morgana: Charactor.minion,
        Charactor.minion: Charactor.minion,
      },
    },
    Charactor.minion: {
      'name': 'Minion',
      'description': '',
      'knowledge': {
        Charactor.assassin: Charactor.minion,
        Charactor.mordred: Charactor.minion,
        Charactor.morgana: Charactor.minion,
        Charactor.minion: Charactor.minion,
      },
    },
    Charactor.oberon: {
      'name': 'Oberon',
      'description': '',
      'knowledge': {},
    },
    Charactor.percival: {
      'name': 'Percival',
      'description': '',
      'knowledge': {
        Charactor.merlin: Charactor.merlin,
        Charactor.morgana: Charactor.merlin,
      },
    },
    Charactor.merlin: {
      'name': 'Merlin',
      'description': '',
      'knowledge': {
        Charactor.assassin: Charactor.minion,
        Charactor.morgana: Charactor.minion,
        Charactor.minion: Charactor.minion,
      },
    },
    Charactor.servant: {
      'name': 'Servant',
      'description': '',
      'knowledge': {},
    },
  };

  static const Map configDefault = {
    '5': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 0,
        Charactor.morgana: 1,
        Charactor.minion: 0,
        Charactor.oberon: 0,
        Charactor.percival: 1,
        Charactor.merlin: 1,
        Charactor.servant: 1,
      }
    },
    '6': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 0,
        Charactor.morgana: 1,
        Charactor.minion: 0,
        Charactor.oberon: 0,
        Charactor.percival: 1,
        Charactor.merlin: 1,
        Charactor.servant: 2,
      }
    },
    '7': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 0,
        Charactor.morgana: 1,
        Charactor.minion: 0,
        Charactor.oberon: 1,
        Charactor.percival: 1,
        Charactor.merlin: 1,
        Charactor.servant: 2,
      }
    },
    '8': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 0,
        Charactor.morgana: 1,
        Charactor.minion: 1,
        Charactor.oberon: 0,
        Charactor.percival: 1,
        Charactor.merlin: 1,
        Charactor.servant: 3,
      }
    },
    '9': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 1,
        Charactor.morgana: 1,
        Charactor.minion: 0,
        Charactor.oberon: 0,
        Charactor.servant: 4,
        Charactor.merlin: 1,
        Charactor.percival: 1,
      }
    },
    '10': {
      'charactors': {
        Charactor.assassin: 1,
        Charactor.mordred: 1,
        Charactor.morgana: 1,
        Charactor.oberon: 1,
        Charactor.minion: 0,
        Charactor.percival: 1,
        Charactor.merlin: 1,
        Charactor.servant: 4,
      }
    },
  };

  static const List allCharactor = [Charactor.assassin, Charactor.mordred, Charactor.minion, Charactor.oberon, Charactor.percival, Charactor.merlin, Charactor.servant];
  static const List allGood = [Charactor.percival, Charactor.merlin, Charactor.servant];
  static const List allEvil = [Charactor.assassin, Charactor.mordred, Charactor.morgana, Charactor.minion, Charactor.oberon];

  static Map getDefaultConfig(int nPlayers) {
    return configDefault[nPlayers.toString()];
  }

  static String getName(Charactor c) {
    return charactorInfo[c]['name'];
  }
  static String getDescroption(Charactor c) {
    return charactorInfo[c]['description'];
  }

  List<Charactor> identites;
  List<String> players;
  Avalon(List<String> players, Map config) {
    this.players = players;
    this.identites = assignIdentities(this.players.length, config);
  } 

  List<Charactor> assignIdentities(int nPlayers, Map config) {
    List<Charactor> identities = [];
    Charactor.values.forEach((c) {
      for (int i = 0; i < config['charactors'][c]; i++) {
        identities.add(c);
      }
    });
    identities.shuffle();
    return identities;
  }

  Charactor getIdentity(String player) {
    int idx = this.players.indexOf(player);
    return this.identites[idx];
  }

  List<String> getPlayer(Charactor c) {
    List<String> players = [];
    for (int i = 0; i < this.identites.length; i++) {
      if (c == this.identites[i] ) {
        players.add(this.players[i]);
      }
    }
    return players;
  }

  List<String> getAllPlayers() {
    return this.players;
  }

  
  Map getKnowledge(String player) {
    Map knowledge = {};
    Charactor c = getIdentity(player);
    charactorInfo[c]['knowledge'].forEach((c, i) {
      if (!knowledge.containsKey(getName(i))) {
        knowledge[getName(i)] = [];
      }
      knowledge[getName(i)].addAll(getPlayer(c));
    });

    return knowledge;
  }
}

void main() {
  // int nPlayers = 7;
  // Map config = Avalon.getDefaultConfig(nPlayers);

  // List identities = Avalon.assignCharactors(nPlayers, config);
  // print(identities);
  // print(Avalon.getName(identities[3]));
  // print(Avalon.getDescroption(identities[3]));
  // print(Avalon.getKnowledge(identities[3]));
  
}