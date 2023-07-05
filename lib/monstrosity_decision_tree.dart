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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AllEnemyAttackedPreviously(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInMelee);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnemyInMovementRange(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class AllEnemyAttackedPreviously extends MonsterDecisionStep {
  const AllEnemyAttackedPreviously({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("AllEnemyAttackedPreviously with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation B",
        content: Column(children: [
          const SimpleQuestionText(
              "Have ALL the ennemies in melee range been previously " +
                  "attacked during the last activation?"),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 10,
            spacing: 20,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.allPreviouslyAttacked);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return WhereIsLowestHP(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.somePreviouslyNotAttacked);
                    const String commonPreamble =
                        "Target enemy that was not attacked before and with " +
                            "the lowest HP. If tied, determine randomly.";
                    initiateGeneralAttackProcess(
                        context, monster, commonPreamble);
                  },
                  child: const ButtonText("No, one or more was not attacked"))
            ],
          )
        ]));
  }
}

class WhereIsLowestHP extends MonsterDecisionStep {
  const WhereIsLowestHP({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("WhereIsLowestHP with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation C",
        content: Column(children: [
          const SimpleQuestionText("Where is the enemy with the lowest HP? " +
              "(Ignore ennemies outside movement range)"),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 10,
            spacing: 10,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.lowestHPInMelee);
                    const String commonPreamble =
                        "Target enemy with lowest HP. If tied, determine randomly.";
                    initiateGeneralAttackProcess(
                        context, monster, commonPreamble);
                  },
                  child: const ButtonText("Already in melee")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.lowestHPWithinMovement);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => monster.makeBasicAttack(
                                context,
                                //decisions,
                                EndOfAction(gameState: gameState),
                                "The monster moves up to its full movement distance to attack the " +
                                    "enemy with the lowest HP. If tied, determine randomly.")));
                  },
                  child: const ButtonText("Reachable within movement range"))
            ],
          )
        ]));
  }
}

class EnemyInMovementRange extends MonsterDecisionStep {
  const EnemyInMovementRange({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation D",
        content: Column(children: [
          const SimpleQuestionText(
              "Is any enemy reachable within movement range?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.lowestHPWithinMovement);
                    const String commonPreamble =
                        "The monster moves up to its full movement distance to attack the " +
                            "enemy with the lowest HP. If tied, determine randomly.";
                    initiateGeneralAttackProcess(
                        context, monster, commonPreamble);
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInRange);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnemyInLineOfSight(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class EnemyInLineOfSight extends MonsterDecisionStep {
  const EnemyInLineOfSight({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation E",
        content: Column(children: [
          const SimpleQuestionText(
              "Is any enemy in line of sight and visible?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GenericSimpleStep(
                                gameState: gameState,
                                title: const Text("Maximum move"),
                                bodyMessage: const SimpleQuestionText(
                                    "Move and use an extra move action instead of an attack to be " +
                                        "within melee range or as close as possible of as many enemies " +
                                        "as possible that can be seen."),
                                decisionForMemory: DecisionKey.doubleMove,
                                nextStep: EndOfAction(gameState: gameState),
                                buttonMessage: const ButtonText("Continue"))));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.noEnemyInLineOfSight);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                NoEnemyVisible(gameState: gameState)));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class NoEnemyVisible extends MonsterDecisionStep {
  const NoEnemyVisible({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation F",
        content: Column(children: [
          const SimpleQuestionText(
              "If there are Hidden enemies, use an action to try to reveal them."),
          ElevatedButton(
              onPressed: () {
                monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GenericSimpleStep(
                            gameState: gameState,
                            title: const Text("Normal move"),
                            bodyMessage: const SimpleQuestionText(
                                "Move to be within melee range or as close as " +
                                    "possible of as many enemies " +
                                    "as possible that can be seen."),
                            decisionForMemory: DecisionKey.normalMove,
                            nextStep: EndOfAction(gameState: gameState),
                            buttonMessage: const ButtonText("Continue"))));
              },
              child: const ButtonText("One or more enemy was revealed")),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GenericSimpleStep(
                            gameState: gameState,
                            title: const Text("Random move"),
                            bodyMessage: const SimpleQuestionText(
                                "Move in a random direction up to full movement distance."),
                            decisionForMemory: DecisionKey.randomMove,
                            nextStep: EndOfAction(gameState: gameState),
                            buttonMessage: const ButtonText("Continue"))));
              },
              child: const ButtonText("Spot failed, or no Hidden enemy around"))
        ]));
  }
}
