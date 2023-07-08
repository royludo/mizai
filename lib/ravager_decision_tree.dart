// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

import 'package:flutter/material.dart';
import 'utils.dart';
import 'decisionTree.dart';
import 'model.dart';

/*
  Ravagers need to defer spe attack potentially long after decision
  was made by user, unlike monstrosity where spe attack decision is made right 
  before attacking. Tree has more steps to take after spe attack criteria are met.
*/

class EnemyInMelee extends MonsterDecisionStep {
  const EnemyInMelee({super.key, required super.gameState});

  void meleeFollowUp(BuildContext context) {
    var monster = gameState.currentMonster;
    var (areaAttackMaybePossible, potentialAreaAttackIndex) =
        basicChecksForAreaAttack(gameState);

    if (areaAttackMaybePossible) {
      if (monster
          .specificSpeAttackRequireDecision(potentialAreaAttackIndex.first)) {
        // here area attack might still not be possible if question is negative
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AskAreaSpecialQuestion(
            gameState: gameState,
            attackIndexes: potentialAreaAttackIndex,
          );
        }));
      } else {
        // case should never happen, area attacks should always have a question
        // associated to them
        throw Exception(
            "Case of area attack with no question, should not happen.");
      }
    } else {
      // only case where we are sure area attack will NOT happen
      // another spe attack might happen, though
      monster.decisionsMemory.add(DecisionKey.noAreaAttackPossible);
      monster.decisionsMemory.add(DecisionKey.willNOTMakeAreaAttack);

      if (monster.decisionsMemory.contains(DecisionKey.enemyInMelee)) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MoveAfterNoAreaMelee(gameState: gameState);
        }));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EnemyInLineOfSight(gameState: gameState);
        }));
      }
    }
  }

  void noAreaAttackFollowUp(BuildContext context) {}

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
                    meleeFollowUp(context);
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInMelee);
                    meleeFollowUp(context);
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

/// if area attack not possible, potentialAreaAttackIndexes will be empty
/// else is possible, attackIndex is set to highest index first
(bool, List<int>) basicChecksForAreaAttack(GameState gameState) {
  var monster = gameState.currentMonster;
  //stdout.writeln("enemyInMelee with decisions: $decisions");

  bool isAreaAttackStartingToBePossible = false;
  List<int> potentialAreaAttackIndexes = [];

  // if basic attack is area, then it is always possible so auto add to list
  if (monster.desc.attacks[0].type == AttackType.area) {
    isAreaAttackStartingToBePossible = true;
    potentialAreaAttackIndexes.add(0);
  }

  // check if basic requirements to make any special attack is met
  if (monster.isSpecialAttackPossible() &&
      monster.isAnySpecialAttackAllowedNow()) {
    // loop gathers area attacks that are possible
    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i) &&
          monster.desc.attacks[i].type == AttackType.area) {
        isAreaAttackStartingToBePossible = true;
        potentialAreaAttackIndexes.add(i);
      }
    }
  }

  potentialAreaAttackIndexes.sort();
  potentialAreaAttackIndexes = List.from(potentialAreaAttackIndexes.reversed);

  return (isAreaAttackStartingToBePossible, potentialAreaAttackIndexes);
}

/// takes an ordered list of attack, from more specific to basic
/// chain questions to determine which attack can be done
/// if yes, we make that attack, if no go to next attack until no more
class AskAreaSpecialQuestion extends MonsterDecisionStep {
  const AskAreaSpecialQuestion(
      {super.key, required super.gameState, required this.attackIndexes});

  final List<int> attackIndexes;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    var questionsForAttack =
        monster.desc.specialAttackQuestions.questionForAttack;

    return GenericChoiceStep(
        gameState: gameState,
        title:
            "${monster.desc.shortName} special attack ${attackIndexes.first}",
        content: Column(children: [
          SimpleQuestionText(questionsForAttack[attackIndexes.first]!),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.yesToAreaAttackQuestion);
                    monster.decisionsMemory.add(DecisionKey.willMakeAreaAttack);
                    // case 2
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MakeAreaAttack(
                          gameState: gameState,
                          attackIndex: attackIndexes.first);
                    }));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    // if no and there are more attacks remaining in attackIndexes
                    // need to go to next attack's question
                    // if only 1 attack remaining in list, then proceed as normal
                    if (attackIndexes.length > 1) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AskAreaSpecialQuestion(
                            gameState: gameState,
                            attackIndexes: attackIndexes..removeAt(0));
                      }));
                    } else {
                      // only 1 attack remaining, and it is No for it

                      monster.decisionsMemory
                          .add(DecisionKey.noToAreaAttackQuestion);
                      monster.decisionsMemory
                          .add(DecisionKey.willNOTMakeAreaAttack);
                      // ensure we won't ask the user a question for that same
                      // attack later in the tree
                      monster.attackIndexesExcludedForAction
                          .add(attackIndexes.first);

                      if (monster.decisionsMemory
                          .contains(DecisionKey.enemyInMelee)) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MoveAfterNoAreaMelee(gameState: gameState);
                        }));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EnemyInLineOfSight(gameState: gameState);
                        }));
                      }
                    }
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class MakeAreaAttack extends MonsterDecisionStep {
  const MakeAreaAttack(
      {super.key, required super.gameState, required this.attackIndex});

  final int attackIndex;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    if (attackIndex == 0) {
      return monster.makeBasicAttack(
          context, MoveAfterAreaAttack(gameState: gameState), "");
    } else {
      return monster.makeSpecialAttack(
          context, MoveAfterAreaAttack(gameState: gameState), "", attackIndex);
    }
  }
}

class MoveAfterAreaAttack extends MonsterDecisionStep {
  const MoveAfterAreaAttack({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    if (monster.decisionsMemory.contains(DecisionKey.enemyInMelee)) {
      return GenericSimpleStep(
          gameState: gameState,
          title: const Text("Situation B"),
          bodyMessage: const SimpleQuestionText(
              "Move its movement distance away from enemy in melee, ending " +
                  "movement at least 6\" away from all enemies if possible, and ending " +
                  "in cover if possible."),
          decisionForMemory: DecisionKey.normalMove,
          nextStep: EndOfAction(gameState: gameState),
          buttonMessage: const ButtonText("Continue"));
    } else if (monster.decisionsMemory.contains(DecisionKey.noEnemyInMelee)) {
      return GenericSimpleStep(
          gameState: gameState,
          title: const Text("Situation C"),
          bodyMessage: const SimpleQuestionText(
              "Move its movement distance, ending the move at least " +
                  "6\" away from all enemies if possible, and ending in cover " +
                  "if possible."),
          decisionForMemory: DecisionKey.normalMove,
          nextStep: EndOfAction(gameState: gameState),
          buttonMessage: const ButtonText("Continue"));
    } else {
      throw Exception("Monster should have melee or noMelee in its memory");
    }
  }
}

class MoveAfterNoAreaMelee extends MonsterDecisionStep {
  const MoveAfterNoAreaMelee({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation D"),
        ),
        body: EverythingCenteredWidget(
          child: Column(children: [
            const SimpleQuestionText(
                "Move its movement distance away from enemy in melee, " +
                    "ending the move at least 6\" away from all enemies if possible, and " +
                    "ending in cover if possible."),
            ElevatedButton(
                onPressed: () {
                  gameState.currentMonster.decisionsMemory
                      .add(DecisionKey.normalMove);
                  //Navigator.push(context, MaterialPageRoute(builder: (_) {
                  initiateGeneralAttackProcess(context,
                      gameState.currentMonster, "Target nearest enemy.");
                  //}));
                },
                child: const ButtonText("Continue"))
          ]),
        ));
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

                    if (monster.hasMovedBefore) {
                      initiateGeneralAttackProcess(
                          context, monster, "Target the closest enemy.");
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MoveAndAttack(gameState: gameState)));
                    }
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
                                AreAllEnemiesHidden(gameState: gameState)));
                  },
                  child: const ButtonText("No"))
            ],
          )
        ]));
  }
}

class AreAllEnemiesHidden extends MonsterDecisionStep {
  const AreAllEnemiesHidden({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation F",
        content: Column(children: [
          const SimpleQuestionText("Are all enemies hidden?"),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RevealHiddenEnemies(
                                gameState: gameState,
                              )));
                },
                child: const ButtonText("Yes")),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MinMoveAndAttack(
                                gameState: gameState,
                              )));
                },
                child: const ButtonText("No"))
          ])
        ]));
  }
}

class MinMoveAndAttack extends MonsterDecisionStep {
  const MinMoveAndAttack({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation H"),
        ),
        body: EverythingCenteredWidget(
          child: Column(children: [
            const SimpleQuestionText(
                "Move the minimum distance to bring an enemy within line of sight."),
            ElevatedButton(
                onPressed: () {
                  gameState.currentMonster.decisionsMemory
                      .add(DecisionKey.normalMove);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => monster.makeBasicAttack(
                              context, EndOfAction(gameState: gameState), "")));
                },
                child: const ButtonText("Continue"))
          ]),
        ));
  }
}

class RevealHiddenEnemies extends MonsterDecisionStep {
  const RevealHiddenEnemies({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "Situation G",
        content: Column(children: [
          const SimpleQuestionText("Try to spot Hidden enemies if you can."),
          ElevatedButton(
              onPressed: () {
                monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => monster.makeBasicAttack(
                            context,
                            EndOfAction(gameState: gameState),
                            "Target the closest revealed enemy.")));
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
                            title: const Text("Normal move"),
                            bodyMessage: const SimpleQuestionText(
                                "Move to the closest terrain that could provide " +
                                    "cover and/or block line of sight to the last " +
                                    "known enemy location."),
                            decisionForMemory: DecisionKey.normalMove,
                            nextStep: EndOfAction(gameState: gameState),
                            buttonMessage: const ButtonText("Continue"))));
              },
              child: const ButtonText("Spot failed, or no Hidden enemy around"))
        ]));
  }
}

class MoveAndAttack extends MonsterDecisionStep {
  const MoveAndAttack({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation I"),
        ),
        body: EverythingCenteredWidget(
          child: Column(children: [
            const SimpleQuestionText(
                "Move up to its full movement distance to cover, if possible. " +
                    "If no such cover is available, move its full movement " +
                    "distance away from the closest enemy."),
            ElevatedButton(
                onPressed: () {
                  gameState.currentMonster.decisionsMemory
                      .add(DecisionKey.normalMove);
                  initiateGeneralAttackProcess(
                      context, monster, "Target closest enemy.");
                },
                child: const ButtonText("Continue"))
          ]),
        ));
  }
}
