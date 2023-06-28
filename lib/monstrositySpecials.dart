import 'package:flutter/material.dart';
import 'package:mizai/utils.dart';
import 'decisionTree.dart';

class MonstrositySpecialDecision extends DecisionAccumulator {
  const MonstrositySpecialDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    var preambleOnQuestion =
        monster.desc.specialAttackQuestions.preamblePosition;
    var questionForAttack =
        monster.desc.specialAttackQuestions.questionForAttack;

    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i)) {
        return Scaffold(
            appBar: AppBar(
              title: Text("${monster.desc.shortName} special attack $i"),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Column(children: [
              // use preamble as part of checking range condition, else it's weird
              // situation where we check 12" before moving and making attack
              preambleOnQuestion == SpeAttackPreamblePosition.onQuestion
                  ? Text("$preamble ${questionForAttack[i]!}")
                  : Text(questionForAttack[i]!),
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
                                    preambleOnQuestion ==
                                            SpeAttackPreamblePosition
                                                .onAllAttacks
                                        ? preamble
                                        : "",
                                    i)));
                      },
                      child: const Text("Yes")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeBasicAttack(
                                    context,
                                    EndOfAction(monster: monster),
                                    preambleOnQuestion ==
                                                SpeAttackPreamblePosition
                                                    .onAllAttacks ||
                                            preambleOnQuestion ==
                                                SpeAttackPreamblePosition
                                                    .onBasicOnly
                                        ? preamble
                                        : "")));
                      },
                      child: const Text("No"))
                ],
              )
            ]));
      }
    }
    throw Exception("${monster.desc.shortName} special attack not found");
  }
}
