import 'package:flutter/material.dart';
import 'model.dart';
import 'decisionTree.dart';

class MainMonsterScreen extends StatefulWidget {
  const MainMonsterScreen(
      {super.key, required this.gameState, required this.debugMode});

  final GameState gameState;
  final bool debugMode;
  //final Set<DecisionKey> previousDecisions;

  @override
  State<MainMonsterScreen> createState() => _MainMonsterScreenState();
}

class _MainMonsterScreenState extends State<MainMonsterScreen> {
  void activateMonster(ActivationTriggerType triggerType) {
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
      // TODO refactor that...
      switch (monster.desc.aiType) {
        case AIType.monstrosity:
          if (monster.isInExtremis) {
            return CheckInExtremis(gameState: widget.gameState);
          } else {
            return getStartingPoint(context, monster, widget.gameState);
          }
        case AIType.ravager:
          if (monster.isInExtremis) {
            return CheckInExtremis(gameState: widget.gameState);
          } else {
            return getStartingPoint(context, monster, widget.gameState);
          }
        case AIType.stalker:
          if (monster.isInExtremis) {
            return CheckInExtremis(gameState: widget.gameState);
          } else {
            return getStartingPoint(context, monster, widget.gameState);
          }
        case AIType.renvultia:
          return getStartingPoint(context, monster, widget.gameState);
      }
    })).then((_) =>
        // need to clear memory else there is a bug when going back after
        // starting an activation, where memory will contain decision of activation.
        monster.decisionsMemory.clear());
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
      case AIType.stalker || AIType.renvultia:
        extraActivationButtonText = "Revealed from Hidden by enemy";
        break;
    }

    return Column(children: [
      const Divider(
        thickness: 4,
        indent: 5,
        endIndent: 5,
      ),
      Text(
        monster.desc.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Text("Phase ${monster.phase} - rules p.${monster.desc.pageReference}"),
      const Divider(
        thickness: 4,
        indent: 5,
        endIndent: 5,
      ),
      widget.debugMode
          ? ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                            title: const Text('Info'),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SelectableText("veryFirstAttack: ${monster.veryFirstAttack}\n" +
                                      "nextAttackIndex: ${monster.nextAttackIndex}\n" +
                                      "decisionsMemory: ${monster.decisionsMemory}\n" +
                                      "hasMovedBefore: ${monster.hasMovedBefore}\n" +
                                      "previousActionAttackIndexes: ${monster.previousActionAttackIndexes}"),
                                ]),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Back'),
                              )
                            ]));
              },
              child: const Text("Internal state"))
          : Container(),
      SwitchListTile(
        title: const Text('In Extremis'),
        activeColor: Colors.red,
        value: monster.isInExtremis,
        onChanged: (bool value) {
          setState(() {
            monster.isInExtremis = value;
          });
        },
        secondary: monster.isInExtremis
            ? const Icon(Icons.warning_amber_sharp)
            : const Icon(Icons.health_and_safety_outlined),
      ),
      // hidden switch, only matters for stalkers
      monster.desc.isStalkerLike()
          ? SwitchListTile(
              title: const Text('Hidden'),
              activeColor: Colors.deepPurpleAccent,
              value: monster.isHidden,
              onChanged: (bool value) {
                setState(() {
                  monster.isHidden = value;
                });
              },
              secondary: monster.isHidden
                  ? const Icon(Icons.visibility_off_outlined)
                  : const Icon(Icons.visibility_outlined),
            )
          : Container(),
      Text("${monster.getActivationCountThisTurn()} / 3 activations this turn"),
      Column(children: [
        const Text("Monster will activate when"),
        const SizedBox(height: 10),
        Wrap(
            spacing: 8,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: monster.activationTriggers.contains(
                              ActivationTriggerType.firstInitiative) ||
                          monster.maxActivationReached()
                      ? null
                      : () => activateMonster(
                          ActivationTriggerType.firstInitiative),
                  child: Text(
                      "Initiative ${monster.desc.getAcuityFromPhase(monster.phase)}")),
              ElevatedButton(
                  onPressed: monster.activationTriggers.contains(
                              ActivationTriggerType.secondInitiative) ||
                          monster.maxActivationReached()
                      ? null
                      : () => activateMonster(
                          ActivationTriggerType.secondInitiative),
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
  }
}
