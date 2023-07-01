import 'package:flutter/material.dart';
import 'main_monster_screen.dart';
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
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color.fromARGB(255, 214, 189, 106),
            secondary: const Color.fromARGB(255, 228, 213, 163)),
      ),
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
    if (monstersAlreadyInGame.isNotEmpty) {
      floatingButtons.add(FloatingActionButton(
        onPressed: () {
          List<StatefulMonster> allMonsterList = [];
          for (var monsterFullName in monstersAlreadyInGame) {
            allMonsterList.add(StatefulMonster(
                monsterDBWithNameKeys[monsterFullName]!,
                currentPhaseSelected + 1));
          }
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  /*StatefulMonster m = StatefulMonster(
                  monsterDBWithNameKeys[monstersAlreadyInGame.first]!,
                  currentPhaseSelected + 1);*/
                  /*switch (m.desc.aiType) {
                case AIType.monstrosity:
                  return PlayMonstrosity(
                    monster: m,
                    //previousDecisions: {},
                  );
                default:
                  throw Exception("Other AI not implemented");
              }*/

                  return GlobalGame(
                      gameState: GameState(allMonsterList, allMonsterList.first)
                      /*currentMonster: allMonsterList.first*/
                      );
                },
                settings: const RouteSettings(name: "gameScreen")),
          );
        },
        heroTag: 'buttonProceed',
        child: const Icon(Icons.arrow_forward),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add monster"),
        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: EverythingCenteredWidget(
          child: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FittedBox(
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
                    )))),
        const Divider(
          thickness: 4,
          indent: 5,
          endIndent: 5,
        ),
        const Text(
          "Phase",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ToggleButtons(
              isSelected: phaseSelectStates,
              onPressed: onPhaseButtonPressed,
              children: const <Widget>[Text("One"), Text("Two")],
            )),
        const Divider(
          thickness: 4,
          indent: 5,
          endIndent: 5,
        ),
        const Text(
          "Monster",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Column(
          children: monsterWidgetList,
        )
        /*ToggleButtons(
          isSelected: monsterSelectStates,
          onPressed: onMonsterButtonPressed,
          children: const <Widget>[Text("Monster 1"), Text("Monster 2")],
        ),*/
      ])),
      floatingActionButton: Wrap(
        spacing: 10,
        children: floatingButtons,
      ),
    );
  }
}

class GlobalGame extends StatefulWidget {
  const GlobalGame({super.key, required this.gameState});

  final GameState
      gameState; // won't have up to date current monster, is in state

  @override
  State<GlobalGame> createState() => _GlobalGameState();
}

class _GlobalGameState extends State<GlobalGame> {
  int selectedMonsterCode = -1;
  late StatefulMonster selectedMonster;

  @override
  void initState() {
    super.initState();
    selectedMonster = widget.gameState.currentMonster;
    selectedMonsterCode = selectedMonster.desc.code;
  }

  @override
  Widget build(BuildContext context) {
    // build reminder section
    List<Widget> reminderSection = [];
    reminderSection.add(
      const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 5),
          child: Text("Reminders")),
    );
    for (var monster in widget.gameState.allGameMonsters) {
      reminderSection.add(const Divider(
        indent: 50,
        endIndent: 50,
      ));
      widget.gameState.isMultiplayerGame()
          ? reminderSection.add(Text(
              monster.desc.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ))
          : null;
      List<Widget> passives = [];
      for (var passiveAbility in monster.desc.passiveAbilities) {
        passives.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: "${passiveAbility.name}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: passiveAbility.interpolatedText(monster.phase))
            ]))));
        //reminderSection.add(Text(passiveAbility.text));
      }
      reminderSection.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: passives,
      ));
    }

    // dynamic floatingactionbutton list
    List<FloatingActionButton> floatingButtons = [
      // here we kill the monster
      // TODO ask confirmation
      FloatingActionButton.extended(
        heroTag: 'buttonKillMonster',
        onPressed: () {
          // only 1 monster remaining, game is done, victory
          if (widget.gameState.allGameMonsters.length == 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Victory!'),
                content: const Text(
                    'The monster was defeated. You may still have time to finish your objectives.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => // back to home, purge navigation
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyHomePage()),
                            (route) => false),
                    child: const Text('To Main Menu'),
                  ),
                ],
              ),
            );
          } else {
            // still some monsters remaining
            setState(() {
              widget.gameState.allGameMonsters.remove(selectedMonster);
              selectedMonster = widget.gameState.allGameMonsters.first;
              selectedMonsterCode = selectedMonster.desc.code;
            });
          }
        },
        label: const Text("Monster killed"),
      )
    ];

    if (selectedMonster.endOfTurnPossible()) {
      floatingButtons.add(FloatingActionButton.extended(
        heroTag: 'buttonEndTurn',
        onPressed: () {
          setState(() {
            selectedMonster.endTurn();
          });
        },
        label: const Text("End Turn"),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Play"),
      ),
      body: EverythingCenteredWidget(
          child: Column(
        children: [
              // make drop down available only when more than 1 monster
              widget.gameState.isMultiplayerGame()
                  ? Row(
                      children: [
                        const Text("Controlling"),
                        const SizedBox(width: 10),
                        DropdownButton(
                          value: selectedMonsterCode,
                          items: widget.gameState.allGameMonsters.map((m) {
                            return DropdownMenuItem(
                                value: m.desc.code,
                                child: Text(m.desc.shortName));
                          }).toList(),
                          onChanged: (int? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              selectedMonsterCode = value!;
                              selectedMonster = widget.gameState.allGameMonsters
                                  .firstWhere((m) =>
                                      m.desc.code == selectedMonsterCode);
                            });
                          },
                        )
                      ],
                    )
                  : Container(),
              MainMonsterScreen(
                  gameState: GameState(
                      widget.gameState.allGameMonsters, selectedMonster)),
            ] +
            reminderSection,
      )),
      floatingActionButton: Wrap(
        spacing: 10,
        children: floatingButtons,
      ),
    );
  }
}
