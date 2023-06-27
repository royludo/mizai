import 'package:flutter/material.dart';
import 'utils.dart';
import 'decisionTree.dart';

class PlayMonstrosity extends StatefulWidget {
  const PlayMonstrosity({super.key, required this.monster});

  final StatefulMonster monster;
  //final Set<DecisionKey> previousDecisions;

  @override
  State<PlayMonstrosity> createState() => _PlayMonstrosityState();
}

class _PlayMonstrosityState extends State<PlayMonstrosity> {
  void activateMonster() {
    /*Set<DecisionKey> decisions = {};
    widget.monster.phase == 1
        ? decisions.add(DecisionKey.phase1)
        : decisions.add(DecisionKey.phase2);*/

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (widget.monster.isInExtremis) {
        return CheckInExtremis(monster: widget.monster);
      } else {
        return EnnemyInMelee(monster: widget.monster);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Play"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(children: [
        Text(widget.monster.desc.fullName),
        Text("Phase ${widget.monster.phase}"),
        SwitchListTile(
          title: const Text('In Extremis'),
          value: widget.monster.isInExtremis,
          onChanged: (bool value) {
            setState(() {
              widget.monster.isInExtremis = value;
            });
          },
          secondary: const Icon(Icons.warning_amber_sharp),
        ),
        Column(children: [
          const Text("Monster will activate when"),
          ElevatedButton(
              onPressed: activateMonster,
              child: Text(
                  "Initiative ${widget.monster.desc.getAcuityFromPhase(widget.monster.phase)}")),
          ElevatedButton(
              onPressed: activateMonster,
              child: Text(
                  "Initiative ${widget.monster.desc.getAcuityFromPhase(widget.monster.phase) - 10}")),
          ElevatedButton(
              onPressed: activateMonster,
              child: const Text("Suffered critical hit"))
        ]),
      ]),
    );
  }
}
