import 'package:flutter/material.dart';
import 'decisionTree.dart';

class AvenkianSSTDecision extends DecisionAccumulator {
  const AvenkianSSTDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Avenkian SST special attack"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          // use preamble as part of checking range condition, else it's weird
          // situation where we check 12" before moving and making attack
          Text("$preamble Are there 2 or more ennemies within 12\"?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeSpecialAttack(
                                context,
                                EndOfAction(monster: monster),
                                "",
                                1)));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeBasicAttack(
                                context, EndOfAction(monster: monster), "")));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}
