import 'package:flutter/material.dart';
import 'main.dart';
import 'main_monster_screen.dart';
import 'utils.dart';
import 'model.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key, required this.gameState});

  final GameState
      gameState; // won't have up to date current monster, is in state

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int selectedMonsterCode = -1;
  late StatefulMonster selectedMonster;
  bool debugMode = false;

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
          padding: EdgeInsets.only(top: 10, bottom: 5),
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
        actions: [
          PopupMenuButton(onSelected: (value) {
            setState(() {
              if (value == 0) {
                // set debug mode
                debugMode = !debugMode;
              }
            });
          }, itemBuilder: (context) {
            return [
              CheckedPopupMenuItem(
                checked: debugMode,
                value: 0,
                child: const Text('Debug'),
              ),
            ];
          })
        ],
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
                            value: m.desc.code, child: Text(m.desc.shortName));
                      }).toList(),
                      onChanged: (int? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          selectedMonsterCode = value!;
                          selectedMonster = widget.gameState.allGameMonsters
                              .firstWhere(
                                  (m) => m.desc.code == selectedMonsterCode);
                        });
                      },
                    )
                  ],
                )
              : Container(),
          MainMonsterScreen(
            gameState:
                GameState(widget.gameState.allGameMonsters, selectedMonster),
            debugMode: debugMode,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 80, top: 10),
            child: Column(children: reminderSection),
          )
        ],
      )),
      floatingActionButton: Wrap(
        spacing: 10,
        children: floatingButtons,
      ),
    );
  }
}
