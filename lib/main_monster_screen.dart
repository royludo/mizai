import 'package:flutter/material.dart';
import 'utils.dart';
import 'decisionTree.dart';

class MainMonsterScreen extends StatefulWidget {
  const MainMonsterScreen({super.key, required this.gameState});

  final GameState gameState;
  //final Set<DecisionKey> previousDecisions;

  @override
  State<MainMonsterScreen> createState() => _MainMonsterScreenState();
}

class _MainMonsterScreenState extends State<MainMonsterScreen> {
  void activateMonster(ActivationTriggerType triggerType) {
    /*Set<DecisionKey> decisions = {};
    widget.monster.phase == 1
        ? decisions.add(DecisionKey.phase1)
        : decisions.add(DecisionKey.phase2);*/
    StatefulMonster monster = widget.gameState.currentMonster;

    // temporarily add activation trigger to monster decisionsMemory
    // activation will be recorded when it is finished, at the end of action
    switch (triggerType) {
      case ActivationTriggerType.firstInitiative:
        monster.decisionsMemory.add(DecisionKey.activatedWithFirstInitiative);
        break;
      case ActivationTriggerType.secondInitiative:
        monster.decisionsMemory.add(DecisionKey.activatedWithSecondInitiative);
        break;
      case ActivationTriggerType.special:
        monster.decisionsMemory.add(DecisionKey.activatedWithSpecial);
        break;
    }

    switch (monster.desc.aiType) {
      case AIType.monstrosity:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          if (monster.isInExtremis) {
            return CheckInExtremis(gameState: widget.gameState);
          } else {
            return EnnemyInMelee(gameState: widget.gameState);
          }
        }));
        break;
      case AIType.ravager:
        throw Exception("Ravager not implemented yet");
      case AIType.stalker:
        throw Exception("Stalker not implemented yet");
    }
  }

  @override
  Widget build(BuildContext context) {
    StatefulMonster monster = widget.gameState.currentMonster;
    String extraActivationButtonText;
    switch (monster.desc.aiType) {
      case AIType.monstrosity:
        extraActivationButtonText = "Suffered critical hit";
        break;
      case AIType.ravager:
        extraActivationButtonText = "Enemy ranged attack missed";
        break;
      case AIType.stalker:
        extraActivationButtonText = "Revealed from Hidden by enemy";
        break;
    }

    return
        /*appBar: AppBar(
        title: const Text("Play"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/
        Column(children: [
      const Divider(
        thickness: 4,
        indent: 5,
        endIndent: 5,
      ),
      Text(
        monster.desc.fullName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Text("Phase ${monster.phase}"),
      const Divider(
        thickness: 4,
        indent: 5,
        endIndent: 5,
      ),
      SwitchListTile(
        title: const Text('In Extremis'),
        value: monster.isInExtremis,
        onChanged: (bool value) {
          setState(() {
            monster.isInExtremis = value;
          });
        },
        secondary: const Icon(Icons.warning_amber_sharp),
      ),
      Text("${monster.getActivationCountThisTurn()} / 3 activations this turn"),
      Column(children: [
        const Text("Monster will activate when"),
        SizedBox(height: 10),
        Wrap(spacing: 10, direction: Axis.horizontal, children: [
          ElevatedButton(
              onPressed: monster.activationTriggers
                          .contains(ActivationTriggerType.firstInitiative) ||
                      monster.maxActivationReached()
                  ? null
                  : () =>
                      activateMonster(ActivationTriggerType.firstInitiative),
              child: Text(
                  "Initiative ${monster.desc.getAcuityFromPhase(monster.phase)}")),
          ElevatedButton(
              onPressed: monster.activationTriggers
                          .contains(ActivationTriggerType.secondInitiative) ||
                      monster.maxActivationReached()
                  ? null
                  : () =>
                      activateMonster(ActivationTriggerType.secondInitiative),
              child: Text(
                  "Initiative ${monster.desc.getAcuityFromPhase(monster.phase) - 10}")),
          ElevatedButton(
              onPressed: monster.maxActivationReached()
                  ? null
                  : () => activateMonster(ActivationTriggerType.special),
              child: Text(extraActivationButtonText))
        ])
      ]),
    ]);
    /*floatingActionButton: widget.monster.endOfTurnPossible()
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  widget.monster.endTurn();
                });
              },
              label: const Text("End Turn"),
            )
          : null,*/
    //);
  }
}
