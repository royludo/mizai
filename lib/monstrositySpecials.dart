import 'package:flutter/material.dart';
import 'package:mizai/utils.dart';
import 'decisionTree.dart';

class MonstrositySpecialDecision extends MonsterDecisionStep {
  const MonstrositySpecialDecision(
      {super.key, required super.gameState, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("AllEnemyAttackedPreviously with decisions: $decisions");
    var preamblePosition = monster.desc.specialAttackQuestions.preamblePosition;
    var questionForAttack =
        monster.desc.specialAttackQuestions.questionForAttack;

    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i)) {
        return Scaffold(
            appBar: AppBar(
              title: Text("${monster.desc.shortName} special attack $i"),
            ),
            body: EverythingCenteredWidget(
                child: Column(children: [
              // use preamble as part of checking range condition, else it's weird
              // situation where we check 12" before moving and making attack
              preamblePosition == SpeAttackPreamblePosition.onQuestion
                  ? SimpleQuestionText("$preamble ${questionForAttack[i]!}")
                  : SimpleQuestionText(questionForAttack[i]!),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeSpecialAttack(
                                    context,
                                    EndOfAction(gameState: gameState),
                                    preamble,
                                    i)));
                      },
                      child: const ButtonText("Yes")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeBasicAttack(
                                    context,
                                    EndOfAction(gameState: gameState),
                                    preamble)));
                      },
                      child: const ButtonText("No"))
                ],
              )
            ])));
      }
    }
    throw Exception("${monster.desc.shortName} special attack not found");
  }
}
