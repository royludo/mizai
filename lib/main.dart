import 'package:flutter/material.dart';
import 'main_screen_wrapper.dart';
import 'utils.dart';
import 'monsterDB.dart';
import 'model.dart';

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
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color.fromARGB(255, 214, 189, 106),
            secondary: const Color.fromARGB(255, 228, 213, 163)),
      ),
      home: const MyHomePage(alreadyInGameMonsters: []),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.alreadyInGameMonsters});

  final List<StatefulMonster> alreadyInGameMonsters;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> phaseSelectStates = <bool>[true, false];
  //List<bool> monsterSelectStates = List.filled(monsterDB.length, false);
  int currentPhaseSelected = 0;
  int currentMonsterSelected = 0;
  bool canProceed = false;
  Set<String> newlySelectedMonsterSet = {};
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

  @override
  Widget build(BuildContext context) {
    // generate the dynamic list of monsters widgets from monsterDB
    List<CheckboxListTile> monsterWidgetList = [];
    for (var monsterEntry in monsterDB.entries) {
      MonsterDescription monster = monsterEntry.value;

      monsterWidgetList.add(CheckboxListTile(
          // add checkmark if monster already in game
          value: widget.alreadyInGameMonsters
                  .map((e) => e.desc.fullName)
                  .contains(monster.fullName)
              ? true
              : monsterSelectStates[monster.fullName],
          // grey out monsters that are already in the game, so user can't remove
          // them from this screen, they have to be killed
          enabled: !widget.alreadyInGameMonsters
              .map((e) => e.desc.fullName)
              .contains(monster.fullName),
          onChanged: (value) {
            setState(() {
              monsterSelectStates[monster.fullName] = value!;
              for (var monsterEntry in monsterSelectStates.entries) {
                if (monsterEntry.value) {
                  newlySelectedMonsterSet.add(monsterEntry.key);
                } else {
                  newlySelectedMonsterSet.remove(monsterEntry.key);
                }
              }
            });
          },
          title: Text(monster.fullName),
          secondary: Text(monster.getPrintableCode())));
    }

    // dynamic floatingactionbutton list
    List<FloatingActionButton> floatingButtons = [];
    if (newlySelectedMonsterSet.isNotEmpty) {
      floatingButtons.add(FloatingActionButton(
        onPressed: () {
          List<StatefulMonster> allMonsterList =
              List.from(widget.alreadyInGameMonsters);
          for (var monsterFullName in newlySelectedMonsterSet) {
            allMonsterList.add(StatefulMonster(
                monsterDBWithNameKeys[monsterFullName]!,
                currentPhaseSelected + 1));
          }
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => MainScreenWrapper(
                      gameState:
                          GameState(allMonsterList, allMonsterList.first)),
                  settings: const RouteSettings(name: "gameScreen")),
              (route) => false);
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
                          MaterialPageRoute(
                              builder: (_) =>
                                  MyHomePage(alreadyInGameMonsters: [])),
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
        Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(children: monsterWidgetList)),
      ])),
      floatingActionButton: Wrap(
        spacing: 10,
        children: floatingButtons,
      ),
    );
  }
}
