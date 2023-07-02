// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

import 'package:flutter/material.dart';
import 'utils.dart';
import 'decisionTree.dart';

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
      if (monster.specificSpeAttackRequireDecision(potentialAreaAttackIndex)) {
        // here area attack might still not be possible if question is negative
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AskAreaSpecialQuestion(
            gameState: gameState,
            attackIndex: potentialAreaAttackIndex,
          );
        }));
      } else {
        // see Pulsar
        monster.decisionsMemory.add(DecisionKey.willMakeAreaAttack);
        monster.deferredAttackIndex = potentialAreaAttackIndex;
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MakeAreaAttack(
              gameState: gameState, attackIndex: potentialAreaAttackIndex);
        }));
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
        throw Exception("Not implemented yet"); // TODO
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

/// if area attack not possible, attackIndex will be -1
/// else is possible, attackIndex is set to the first area attack
(bool, int) basicChecksForAreaAttack(GameState gameState) {
  var monster = gameState.currentMonster;
  //stdout.writeln("enemyInMelee with decisions: $decisions");

  bool isAreaAttackStartingToBePossible = false;
  int chosenPotentialAreaAttackIndex = -1;
  // first check if basic requirements to make any special attack is met
  // Warning: basic attack may be an area attack!
  if (monster.isSpecialAttackPossible(false) &&
      monster.isAnySpecialAttackAllowedNow()) {
    // loop gathers area attacks that are possible
    List<int> multiplePossibleAreaAttackIndexes = [];
    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i) &&
          monster.desc.attacks[i].type == AttackType.area) {
        multiplePossibleAreaAttackIndexes.add(i);
      }
    }

    if (multiplePossibleAreaAttackIndexes.length == 1) {
      // easy case, only 1 area attack possible to return
      isAreaAttackStartingToBePossible = true;
      chosenPotentialAreaAttackIndex = multiplePossibleAreaAttackIndexes.first;
    } else if (multiplePossibleAreaAttackIndexes.length > 1) {
      // multiple area attacks are allowed here
      // use the nextAttack of the monster to choose

      if (multiplePossibleAreaAttackIndexes.contains(monster.nextAttackIndex)) {
        // because of the contains we are sure the loop will find something
        for (var areaAttackIndex in multiplePossibleAreaAttackIndexes) {
          if (areaAttackIndex == monster.nextAttackIndex) {
            isAreaAttackStartingToBePossible = true;
            chosenPotentialAreaAttackIndex = areaAttackIndex;
            break;
          }
        }
      } else {
        // maybe nextAttack is not in the possible areaAttacks, never knows
        // this is the case where the next attack would have been a basic one
        // then take the first areaAttack that comes
        isAreaAttackStartingToBePossible = true;
        chosenPotentialAreaAttackIndex =
            multiplePossibleAreaAttackIndexes.first;
      }
    }
  } else if (monster.desc.attacks[0].type == AttackType.area) {
    // case where area attack is a Basic attack
    // then area attack is always available basically
    isAreaAttackStartingToBePossible = true;
    chosenPotentialAreaAttackIndex = 0;
  }

  return (isAreaAttackStartingToBePossible, chosenPotentialAreaAttackIndex);
}

class AskAreaSpecialQuestion extends MonsterDecisionStep {
  const AskAreaSpecialQuestion(
      {super.key, required super.gameState, required this.attackIndex});

  final int attackIndex;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("AllEnemyAttackedPreviously with decisions: $decisions");
    //var preamblePosition = monster.desc.specialAttackQuestions.preamblePosition;
    var questionsForAttack =
        monster.desc.specialAttackQuestions.questionForAttack;

    return GenericChoiceStep(
        gameState: gameState,
        title: "${monster.desc.shortName} special attack $attackIndex",
        content: Column(children: [
          SimpleQuestionText(questionsForAttack[attackIndex]!),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.yesToAreaAttackQuestion);
                    monster.decisionsMemory.add(DecisionKey.willMakeAreaAttack);
                    monster.deferredAttackIndex = attackIndex;
                    // case 2
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MakeAreaAttack(
                          gameState: gameState, attackIndex: attackIndex);
                    }));
                  },
                  child: const ButtonText("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.noToAreaAttackQuestion);
                    monster.decisionsMemory
                        .add(DecisionKey.willNOTMakeAreaAttack);

                    if (monster.decisionsMemory
                        .contains(DecisionKey.enemyInMelee)) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MoveAfterNoAreaMelee(gameState: gameState);
                      }));
                    } else {
                      throw Exception("Not implemented yet"); // TODO
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

    if (monster.decisionsMemory.contains(DecisionKey.enemyInMelee)) {
      if (monster.deferredAttackIndex == 0) {
        return monster.makeBasicAttack(
            context, MoveAfterAreaAttack(gameState: gameState), "");
      } else {
        return monster.makeSpecialAttack(context,
            MoveAfterAreaAttack(gameState: gameState), "", attackIndex);
      }
    } else if (monster.decisionsMemory.contains(DecisionKey.noEnemyInMelee)) {
      if (monster.deferredAttackIndex == 0) {
        return monster.makeBasicAttack(
            context, MoveAfterAreaAttack(gameState: gameState), "");
      } else {
        return monster.makeSpecialAttack(context,
            MoveAfterAreaAttack(gameState: gameState), "", attackIndex);
      }
    } else {
      throw Exception("Monster should have melee or noMelee in its memory");
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
          bodyMessage: const SimpleQuestionText("move after area attack melee"),
          decisionForMemory: DecisionKey.normalMove,
          nextStep: EndOfAction(gameState: gameState),
          buttonMessage: const ButtonText("Continue"));
    } else if (monster.decisionsMemory.contains(DecisionKey.noEnemyInMelee)) {
      return GenericSimpleStep(
          gameState: gameState,
          title: const Text("Situation C"),
          bodyMessage:
              const SimpleQuestionText("move after area attack NO melee"),
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
