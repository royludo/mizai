import 'dart:io';

import 'package:flutter/material.dart';
import 'playMonstrosity.dart';
import 'utils.dart';
import 'monsterDB.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MI3AI',
      /*theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true),*/
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> phaseSelectStates = <bool>[true, false];
  //List<bool> monsterSelectStates = List.filled(monsterDB.length, false);
  int currentPhaseSelected = 0;
  int currentMonsterSelected = 0;
  bool canProceed = false;
  Set<String> monstersAlreadyInGame = {};
  Map<String, bool> monsterSelectStates = Map.fromEntries(monsterDB.entries.map(
    (e) {
      return MapEntry(e.value.fullName, false);
    },
  ));
  Map<String, MonsterDescription> monsterDBWithNameKeys =
      Map.fromEntries(monsterDB.entries.map(
    (e) {
      return MapEntry(e.value.fullName, e.value);
    },
  ));

  void onPhaseButtonPressed(int index) {
    setState(() {
      for (int buttonIndex = 0;
          buttonIndex < phaseSelectStates.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          phaseSelectStates[buttonIndex] = true;
          currentPhaseSelected = index;
        } else {
          phaseSelectStates[buttonIndex] = false;
        }
      }
    });
  }

  /*void onMonsterButtonPressed(int index) {
    setState(() {
      for (int buttonIndex = 0;
          buttonIndex < monsterSelectStates.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          monsterSelectStates[buttonIndex] = true;
          currentMonsterSelected = index;
        } else {
          monsterSelectStates[buttonIndex] = false;
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    //stdout.writeln(monsterSelectStates);

    // generate the dynamic list of monsters widgets from monsterDB
    List<CheckboxListTile> monsterWidgetList = [];
    for (var monsterEntry in monsterDB.entries) {
      MonsterDescription monster = monsterEntry.value;

      // enable or disable a monster widget depending if it is already in game
      void Function(bool?)? f;
      if (monstersAlreadyInGame.contains(monster.fullName)) {
        f = null;
      } else {
        f = (bool? value) {
          setState(() {
            monsterSelectStates[monster.fullName] = value!;
          });
        };
      }
      monsterWidgetList.add(CheckboxListTile(
          value: monsterSelectStates[monster.fullName],
          onChanged: f,
          title: Text(monster.fullName),
          secondary: Text(monster.getPrintableCode())));
    }

    // dynamic floatingactionbutton list
    List<FloatingActionButton> floatingButtons = [
      FloatingActionButton(
        onPressed: () {
          setState(() {
            for (var monsterEntry in monsterSelectStates.entries) {
              if (monsterEntry.value) {
                monstersAlreadyInGame.add(monsterEntry.key);
              }
            }
          });
        },
        heroTag: 'buttonAdd',
        child: const Icon(Icons.add),
      )
    ];
    if (!monstersAlreadyInGame.isEmpty) {
      floatingButtons.add(FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              StatefulMonster m = StatefulMonster(
                  monsterDBWithNameKeys[monstersAlreadyInGame.first]!,
                  currentPhaseSelected + 1);
              switch (m.desc.aiType) {
                case AIType.monstrosity:
                  return PlayMonstrosity(
                    monster: m,
                    //previousDecisions: {},
                  );
                default:
                  throw Exception("Other AI not implemented");
              }
            }),
          );
        },
        heroTag: 'buttonProceed',
        child: const Icon(Icons.arrow_forward),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add monster"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(children: <Widget>[
        FittedBox(
            child: ElevatedButton(
                onPressed: () {
                  // simply reload homepage and purge navigation
                  // TODO ask confirmation
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyHomePage()),
                      (route) => false);
                },
                child: const Row(
                  children: [Text("Reset game"), Icon(Icons.restart_alt)],
                ))),
        const Text("Phase"),
        ToggleButtons(
          isSelected: phaseSelectStates,
          onPressed: onPhaseButtonPressed,
          children: const <Widget>[Text("One"), Text("Two")],
        ),
        const Text("Monster"),
        Column(
          children: monsterWidgetList,
        )
        /*ToggleButtons(
          isSelected: monsterSelectStates,
          onPressed: onMonsterButtonPressed,
          children: const <Widget>[Text("Monster 1"), Text("Monster 2")],
        ),*/
      ]),
      floatingActionButton: Wrap(
        spacing: 10,
        children: floatingButtons,
      ),
    );
  }
}
