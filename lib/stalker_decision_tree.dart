// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'decisionTree.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'model.dart';

class EnemyInMelee extends MonsterDecisionStep {
  const EnemyInMelee({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation A",
        content: Column(children: [
          const SimpleQuestionText("Is there any enemy in melee range?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.enemyInMelee);
                    /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      //return AllEnemyAttackedPreviously(gameState: gameState);
                    }));*/
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInMelee);
                    /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      //return EnemyInMovementRange(gameState: gameState);
                    }));*/
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}
