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
                    return initiateGeneralAttackProcess(
                        context,
                        monster,
                        Preamble(
                            "Target the enemy in melee with lowest HP. If tied, choose randomly."),
                        MoveAfterMeleeAttack(gameState: gameState));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInMelee);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (monster.isHidden) {
                        return EnemyInRangeWhileHidden(gameState: gameState);
                      } else {
                        if (monster.desc.stalkerAttr!.hasActionToHide) {
                          throw Exception("Not implemented yet"); // TODO
                        } else {
                          return EnemiesInRangeWhileNotHidden(
                              gameState: gameState);
                        }
                      }
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class MoveAfterMeleeAttack extends MonsterDecisionStep {
  const MoveAfterMeleeAttack({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    return GenericSimpleStep(
        gameState: gameState,
        title: const Text("Normal move"),
        bodyMessage: const SimpleQuestionText(
            "Move up to the maximum movement distance away from the enemy in melee, " +
                "ending in cover if possible."),
        decisionForMemory: DecisionKey.normalMove,
        nextStep: EndOfAction(gameState: gameState),
        buttonMessage: const ButtonText("Continue"));
  }
}

class EnemiesInRangeWhileNotHidden extends MonsterDecisionStep {
  const EnemiesInRangeWhileNotHidden({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation B",
        content: Column(children: [
          const SimpleQuestionText(
              "Is any enemy within movement range and visible?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.normalMove);
                    return initiateGeneralAttackProcess(
                      context,
                      monster,
                      Preamble(
                          "Move and attack the enemy with lowest HP. If tied, choose randomly."),
                      EndOfAction(gameState: gameState),
                    );
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInRange);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnemiesVisibleWhileNotHidden(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class EnemiesVisibleWhileNotHidden extends MonsterDecisionStep {
  const EnemiesVisibleWhileNotHidden({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation C",
        content: Column(children: [
          const SimpleQuestionText("Is any enemy in line of sight?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return GenericSimpleStep(
                          gameState: gameState,
                          title: const Text("Maximum move"),
                          bodyMessage: const SimpleQuestionText(
                              "Move as much as possible toward the " +
                                  "enemy with the lowest HP that can be seen. " +
                                  "If tied, choose enemy randomly. End in cover if possible."),
                          decisionForMemory: DecisionKey.doubleMove,
                          nextStep: EndOfAction(gameState: gameState),
                          buttonMessage: const ButtonText("Continue"));
                    }));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.noEnemyInLineOfSight);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return GenericSimpleStep(
                          gameState: gameState,
                          title: const Text("Normal move"),
                          bodyMessage: const SimpleQuestionText(
                              "Move to cover, away and out of line of sight from as many " +
                                  "enemies as possible, or from their last known position."),
                          decisionForMemory: DecisionKey.normalMove,
                          nextStep: EndOfAction(gameState: gameState),
                          buttonMessage: const ButtonText("Continue"));
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class EnemyInRangeWhileHidden extends MonsterDecisionStep {
  const EnemyInRangeWhileHidden({super.key, required super.gameState});

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
                    monster.decisionsMemory.add(DecisionKey.normalMove);
                    return initiateGeneralAttackProcess(
                      context,
                      monster,
                      Preamble(
                          "Move and target the closest enemy with a Surprise attack."),
                      EndOfAction(gameState: gameState),
                    );
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInRange);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AllEnemiesHiddenWhileHidden(gameState: gameState);
                    }));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class AllEnemiesHiddenWhileHidden extends MonsterDecisionStep {
  const AllEnemiesHiddenWhileHidden({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation E",
        content: Column(children: [
          const SimpleQuestionText("Are all enemies Hidden?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NoEnemyVisibleWhileHidden(
                                gameState: gameState)));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GenericSimpleStep(
                                gameState: gameState,
                                title: const Text("Maximum move"),
                                bodyMessage: const SimpleQuestionText(
                                    "Move and use an extra move action toward " +
                                        "the enemy with the lowest HP, even if out of " +
                                        "line of sight. End the move out of melee range " +
                                        "(1\" away or more) and stay Hidden."),
                                decisionForMemory: DecisionKey.doubleMove,
                                nextStep: EndOfAction(gameState: gameState),
                                buttonMessage: const ButtonText("Continue"))));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class NoEnemyVisibleWhileHidden extends MonsterDecisionStep {
  const NoEnemyVisibleWhileHidden({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation F",
        content: Column(children: [
          const SimpleQuestionText("Use an action to try to spot an enemy."),
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
                                "Move and use an extra move action toward " +
                                    "the revealed enemy. End the move out of melee range " +
                                    "(1\" away or more) and stay Hidden."),
                            decisionForMemory: DecisionKey.doubleMove,
                            nextStep: EndOfAction(gameState: gameState),
                            buttonMessage: const ButtonText("Continue"))));
              },
              child: const ButtonText("An enemy was revealed")),
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
                            title: const Text("No move"),
                            bodyMessage: const SimpleQuestionText(
                                "Stay in your current position, Hidden"),
                            decisionForMemory: DecisionKey.noMove,
                            nextStep: EndOfAction(gameState: gameState),
                            buttonMessage: const ButtonText("Continue"))));
              },
              child: const ButtonText("Spot failed"))
        ]));
  }
}

/// The chaos bringer overrides normal AI in the following way:
/// Branch first on the hidden status.
/// If the monster is hidden, it follows the normal ai.
/// If not, it will either use its special attack or hide, without doing
/// anything else.
class ChaosBringerSpecial extends MonsterDecisionStep {
  const ChaosBringerSpecial({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("enemyInMelee with decisions: $decisions");

    int hideActionIndex = 1;
    int maelstromIndex = 2;
    if (monster.isHidden) {
      // disqualify the special attack and hide action from being asked
      monster.attackIndexesExcludedForAction
          .addAll([hideActionIndex, maelstromIndex]);
      // follow normal stalker AI
      return EnemyInMelee(gameState: gameState);
    } else {
      // check if qualifies for maelstrom
      if (monster.isSpecialAttackPossible() &&
          monster.isSpecificAttackAllowedNow(maelstromIndex)) {
        // ask maelstrom question
        return GenericChoiceStep(
          gameState: gameState,
          title: "Situation CB",
          content: Column(children: [
            SimpleQuestionText(monster.desc.specialAttackQuestions
                .questionForAttack[maelstromIndex]!),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      // use maelstrom
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => monster.makeSpecialAttack(
                              context,
                              EndOfAction(gameState: gameState),
                              Preamble.empty(),
                              maelstromIndex),
                        ),
                      );
                    },
                    child: const ButtonText("Yes")),
                ElevatedButton(
                  onPressed: () {
                    // use hide
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => monster.makeSpecialAttack(
                            context,
                            EndOfAction(gameState: gameState),
                            Preamble.empty(),
                            hideActionIndex),
                      ),
                    );
                  },
                  child: const ButtonText("No"),
                )
              ],
            )
          ]),
        );
      } else {
        // maelstrom not possible, use hide
        return monster.makeSpecialAttack(
            context,
            EndOfAction(gameState: gameState),
            Preamble.empty(),
            hideActionIndex);
      }
    }
  }
}
