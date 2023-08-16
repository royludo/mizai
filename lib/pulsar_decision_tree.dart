import 'package:flutter/material.dart';

import 'decisionTree.dart';
import 'model.dart';
import 'utils.dart';

/// Router function
/// matches a step id to its corresponding widget
MonsterDecisionStep getStepWidget(GameState gameState, StepId stepId) {
  switch (stepId) {
    case StepId.enemyInMelee:
      return EnemyInMelee(gameState: gameState);
    case StepId.enemyWithin12:
      return EnemyWithin12(gameState: gameState);
    case StepId.ravagerStep2:
      return RavagerStep2(gameState: gameState);
    case StepId.enemyInLOS:
      return EnemyInLOS(gameState: gameState);
    case StepId.ravagerStep4:
      return RavagerStep4(gameState: gameState);
    case StepId.allEnemiesHidden:
      return AllEnemiesHidden(gameState: gameState);
    case StepId.ravagerStep7:
      return RavagerStep7(gameState: gameState);
    case StepId.spotHiddenEnemies:
      return SpotHiddenEnemies(gameState: gameState);
    case StepId.attackClosestRevealed:
      return AttackClosestRevealed(gameState: gameState);
    case StepId.moveToClosestCover:
      return MoveToClosestCover(gameState: gameState);
    case StepId.attackFromCoverPossible:
      return AttackFromCoverPossible(gameState: gameState);
    case StepId.moveToCoverAttack:
      return MoveToCoverAndAttack(gameState: gameState);
    case StepId.moveAwayFromClosest:
      return MoveAwayFromClosest(gameState: gameState);

    case StepId.justBasicAttack:
      return JustBasicAttack(gameState: gameState);

    case StepId.endOfAction:
      return EndOfAction(gameState: gameState);

    /*default:
      throw Exception("Could not find appropriate branch.");*/
  }
}

/// Helper function
/// Given a list of attack indexes, chooses between simple basic attack
/// or starting the special attacks chain questions process
Widget initiateAttack(
  BuildContext context,
  GameState gameState,
  List<int> availableAttacks,
  Preamble preamble,
  MonsterDecisionStep endPoint,
) {
  if (availableAttacks.length == 1 && availableAttacks.first == 0) {
    // only basic attack
    return (gameState.currentMonster as PulsarRavager)
        .makeBasicAttack(context, endPoint, preamble);
  } else {
    return SimpleSpecialDecision(
      gameState: gameState,
      preamble: preamble,
      possibleAttackIndexes: availableAttacks,
      nextStep: endPoint,
    );
  }
}

class EnemyInMelee extends MonsterDecisionStep {
  const EnemyInMelee({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.enemyInMelee;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
        gameState: gameState,
        title: "Situation A",
        question: "Is there any enemy in melee range?",
        yesClosure: () {
          monster.decisionsMemory.add(DecisionKey.enemyInMelee);
          //meleeFollowUp(context);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        },
        noClosure: () {
          monster.decisionsMemory.add(DecisionKey.noEnemyInMelee);
          //meleeFollowUp(context);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        });
  }
}

class RavagerStep2 extends MonsterDecisionStep {
  const RavagerStep2({super.key, required super.gameState});

  final StepId stepId = StepId.ravagerStep2;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    List<int> availableAttacks =
        (gameState.currentMonster as PulsarRavager).getAvailableAttacks();

    MonsterDecisionStep endPoint = GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation B"),
      bodyMessage: const SimpleQuestionText(
          "Move its movement distance away from enemy in melee, "
          "ending the move at least 6\" away from all enemies if possible, and "
          "ending in cover if possible."),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: getStepWidget(gameState, nextStepId),
      buttonMessage: const ButtonText("Continue"),
    );

    Preamble preamble = Preamble.empty();

    return initiateAttack(
        context, gameState, availableAttacks, preamble, endPoint);
  }
}

class EnemyWithin12 extends MonsterDecisionStep {
  const EnemyWithin12({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.enemyWithin12;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
        gameState: gameState,
        title: "Situation C",
        question: "Is there any enemy within 12\"?",
        yesClosure: () {
          monster.decisionsMemory.add(DecisionKey.enemyWithin12);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        },
        noClosure: () {
          monster.decisionsMemory.add(DecisionKey.noEnemyWithin12);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        });
  }
}

class RavagerStep4 extends MonsterDecisionStep {
  const RavagerStep4({super.key, required super.gameState});

  final StepId stepId = StepId.ravagerStep4;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    List<int> availableAttacks =
        (gameState.currentMonster as PulsarRavager).getAvailableAttacks();

    MonsterDecisionStep endPoint = GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation D"),
      bodyMessage: const SimpleQuestionText("Move its movement distance, "
          "ending the move at least 6\" away from all enemies if possible, and "
          "ending in cover if possible."),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: getStepWidget(gameState, nextStepId),
      buttonMessage: const ButtonText("Continue"),
    );

    Preamble preamble = Preamble.empty();

    return initiateAttack(
        context, gameState, availableAttacks, preamble, endPoint);
  }
}

class EnemyInLOS extends MonsterDecisionStep {
  const EnemyInLOS({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.enemyInLOS;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
        gameState: gameState,
        title: "Situation E",
        question: "Is there any enemy in line of sight?",
        yesClosure: () {
          monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        },
        noClosure: () {
          monster.decisionsMemory.add(DecisionKey.noEnemyInLineOfSight);
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        });
  }
}

class AllEnemiesHidden extends MonsterDecisionStep {
  const AllEnemiesHidden({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.allEnemiesHidden;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
        gameState: gameState,
        title: "Situation F",
        question: "Are all enemies hidden?",
        yesClosure: () {
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        },
        noClosure: () {
          StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => getStepWidget(gameState, nextStepId)),
          );
        });
  }
}

class RavagerStep7 extends MonsterDecisionStep {
  const RavagerStep7({super.key, required super.gameState});

  final StepId stepId = StepId.ravagerStep7;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    List<int> availableAttacks =
        (gameState.currentMonster as PulsarRavager).getAvailableAttacks();

    Preamble preamble = Preamble.empty();

    return GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation G"),
      bodyMessage: const SimpleQuestionText(
          "Move the minimum distance to bring an "
          "enemy within line of sight and in range, staying in cover if possible."),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: initiateAttack(context, gameState, availableAttacks, preamble,
          getStepWidget(gameState, nextStepId)),
      buttonMessage: const ButtonText("Continue"),
    );
  }
}

class SpotHiddenEnemies extends MonsterDecisionStep {
  const SpotHiddenEnemies({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.spotHiddenEnemies;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
      gameState: gameState,
      title: "Situation H",
      question: "Try to spot Hidden enemies if you can.",
      yesClosure: () {
        StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => getStepWidget(gameState, nextStepId)),
        );
      },
      noClosure: () {
        StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => getStepWidget(gameState, nextStepId)),
        );
      },
      yesLabel: "One or more enemy was revealed",
      noLabel: "Spot failed, or no Hidden enemy around",
    );
  }
}

class AttackClosestRevealed extends MonsterDecisionStep {
  const AttackClosestRevealed({super.key, required super.gameState});

  final StepId stepId = StepId.attackClosestRevealed;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    List<int> availableAttacks =
        (gameState.currentMonster as PulsarRavager).getAvailableAttacks();

    Preamble preamble = Preamble("Target the closest revealed enemy.");

    return initiateAttack(context, gameState, availableAttacks, preamble,
        getStepWidget(gameState, nextStepId));
  }
}

class MoveToClosestCover extends MonsterDecisionStep {
  const MoveToClosestCover({super.key, required super.gameState});

  final StepId stepId = StepId.moveToClosestCover;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    return GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation J"),
      bodyMessage: const SimpleQuestionText(
          "Move to the closest terrain that could provide "
          "cover and/or block line of sight to the last "
          "known enemy location."),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: getStepWidget(gameState, nextStepId),
      buttonMessage: const ButtonText("Continue"),
    );
  }
}

class AttackFromCoverPossible extends MonsterDecisionStep {
  const AttackFromCoverPossible({super.key, required super.gameState});
  /*const EnemyInMelee({super.key, required super.gameState})
      : super(stepId: StepId.enemyInMelee);*/

  final StepId stepId = StepId.attackFromCoverPossible;

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;

    return UltraSimplifiedBinaryChoiceStep(
      gameState: gameState,
      title: "Situation K",
      question:
          "Is it possible to get in range and attack while being in cover?",
      yesClosure: () {
        StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 1);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => getStepWidget(gameState, nextStepId)),
        );
      },
      noClosure: () {
        StepId nextStepId = (monster as PulsarRavager).getNextStep(stepId, 0);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => getStepWidget(gameState, nextStepId)),
        );
      },
    );
  }
}

class MoveToCoverAndAttack extends MonsterDecisionStep {
  const MoveToCoverAndAttack({super.key, required super.gameState});

  final StepId stepId = StepId.moveToCoverAttack;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    List<int> availableAttacks =
        (gameState.currentMonster as PulsarRavager).getAvailableAttacks();

    Preamble preamble = Preamble.empty();

    return GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation L"),
      bodyMessage: const SimpleQuestionText(
          "Move to cover and then attack the closest enemy within line of sight"),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: initiateAttack(context, gameState, availableAttacks, preamble,
          getStepWidget(gameState, nextStepId)),
      buttonMessage: const ButtonText("Continue"),
    );
  }
}

class MoveAwayFromClosest extends MonsterDecisionStep {
  const MoveAwayFromClosest({super.key, required super.gameState});

  final StepId stepId = StepId.moveAwayFromClosest;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    return GenericSimpleStep(
      gameState: gameState,
      title: const Text("Situation M"),
      bodyMessage:
          const SimpleQuestionText("Move to cover. If no cover is available, "
              "move the full movement distance away from the closest enemy."),
      decisionForMemory: DecisionKey.normalMove,
      nextStep: getStepWidget(gameState, nextStepId),
      buttonMessage: const ButtonText("Continue"),
    );
  }
}

class JustBasicAttack extends MonsterDecisionStep {
  const JustBasicAttack({super.key, required super.gameState});

  final StepId stepId = StepId.justBasicAttack;

  @override
  Widget build(BuildContext context) {
    StepId nextStepId =
        (gameState.currentMonster as PulsarRavager).getNextStep(stepId, 0);

    return initiateAttack(context, gameState, [0], Preamble.empty(),
        getStepWidget(gameState, nextStepId));
  }
}
