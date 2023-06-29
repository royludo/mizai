import 'package:flutter/material.dart';
import 'utils.dart';
import 'decisionTree.dart';

class PlayMonstrosity extends StatefulWidget {
  const PlayMonstrosity({super.key, required this.gameState});

  final GameState gameState;
  //final Set<DecisionKey> previousDecisions;

  @override
  State<PlayMonstrosity> createState() => _PlayMonstrosityState();
}

class _PlayMonstrosityState extends State<PlayMonstrosity> {
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

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (monster.isInExtremis) {
        return CheckInExtremis(gameState: widget.gameState);
      } else {
        return EnnemyInMelee(gameState: widget.gameState);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    StatefulMonster monster = widget.gameState.currentMonster;
    return
        /*appBar: AppBar(
        title: const Text("Play"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/
        Column(children: [
      Text(monster.desc.fullName),
      Text("Phase ${monster.phase}"),
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
        ElevatedButton(
            onPressed: monster.activationTriggers
                        .contains(ActivationTriggerType.firstInitiative) ||
                    monster.maxActivationReached()
                ? null
                : () => activateMonster(ActivationTriggerType.firstInitiative),
            child: Text(
                "Initiative ${monster.desc.getAcuityFromPhase(monster.phase)}")),
        ElevatedButton(
            onPressed: monster.activationTriggers
                        .contains(ActivationTriggerType.secondInitiative) ||
                    monster.maxActivationReached()
                ? null
                : () => activateMonster(ActivationTriggerType.secondInitiative),
            child: Text(
                "Initiative ${monster.desc.getAcuityFromPhase(monster.phase) - 10}")),
        ElevatedButton(
            onPressed: monster.maxActivationReached()
                ? null
                : () => activateMonster(ActivationTriggerType.special),
            child: const Text("Suffered critical hit"))
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
