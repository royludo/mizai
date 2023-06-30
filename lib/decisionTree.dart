// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:mizai/main.dart';
import 'utils.dart';
import 'monstrositySpecials.dart';

abstract class MonsterDecisionStep extends StatelessWidget {
  const MonsterDecisionStep({super.key, required this.gameState});

  final GameState gameState;
  //final Set<DecisionKey> decisions;

  void initiateAttackProcess(
      BuildContext context, StatefulMonster monster, String commonPreamble) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (monster.isSpecialAttackPossible(false) &&
          monster.isAnySpecialAttackAllowedNow()) {
        // first checks say it is possible to have a special attack
        // loop determines first available spe attack that does not
        // require a decision step = 1st spe attack that auto apply
        for (var i = 1; i < monster.desc.attacks.length; i++) {
          if (monster.isSpecificAttackAllowedNow(i) &&
              !monster.specificSpeAttackRequireDecision(i)) {
            return monster.makeSpecialAttack(
                context, EndOfAction(gameState: gameState), commonPreamble, i);
          }
        }
        // at this point we are sure we need a decision for the special attack
        // else the attack would have been made already
        return MonstrositySpecialDecision(
            gameState: gameState, preamble: commonPreamble);
      } else {
        // spe attack not possible, revert to basic one
        return monster.makeBasicAttack(
            context, EndOfAction(gameState: gameState), commonPreamble);
      }
    }));
  }
}

class CheckInExtremis extends MonsterDecisionStep {
  const CheckInExtremis({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("inextremis with decisions: $decisions");
    return GenericChoiceStep(
        gameState: gameState,
        title: "In Extremis",
        content: Column(children: [
          SimpleQuestionText(
              "The ${monster.desc.fullName} is In Extremis. It suffers 2D6 damage and will take an extra action!"),
          ElevatedButton(
              onPressed: () {
                switch (monster.desc.aiType) {
                  case AIType.monstrosity:
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnemyInMelee(gameState: gameState);
                    }));
                  case AIType.ravager:
                    throw Exception("Ravager tree not implemented yet");
                  case AIType.stalker:
                    throw Exception("Stalker tree not implemented yet");
                }
              },
              child: const ButtonText("Continue"))
        ]));
  }
}

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    initiateAttackProcess(context, monster, commonPreamble);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.lowestHPInMelee);
                    const String commonPreamble =
                        "Target enemy with lowest HP. If tied, determine randomly.";
                    initiateAttackProcess(context, monster, commonPreamble);
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
                    initiateAttackProcess(context, monster, commonPreamble);
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

class GenericChoiceStep extends MonsterDecisionStep {
  const GenericChoiceStep(
      {super.key,
      required super.gameState,
      required this.title,
      required this.content});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    //var monster = gameState.currentMonster;
    //stdout.writeln("AllEnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: EverythingCenteredWidget(child: content),
    );
  }
}

/// Describe a screen giving a message and a button to continue
class GenericSimpleStep extends MonsterDecisionStep {
  const GenericSimpleStep(
      {super.key,
      required super.gameState,
      required this.title,
      required this.bodyMessage,
      required this.decisionForMemory,
      required this.nextStep,
      required this.buttonMessage});

  final Widget title;
  final Widget bodyMessage;
  final DecisionKey decisionForMemory;
  final MonsterDecisionStep nextStep;
  final Widget buttonMessage;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: EverythingCenteredWidget(
          child: Column(children: [
            bodyMessage,
            ElevatedButton(
                onPressed: () {
                  gameState.currentMonster.decisionsMemory
                      .add(decisionForMemory);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => nextStep));
                },
                child: buttonMessage)
          ]),
        ));
  }
}

class EndOfAction extends MonsterDecisionStep {
  const EndOfAction({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("endofaction with decisions: $decisions");

    String text;
    if (monster.isInExtremis &&
        !monster.decisionsMemory.contains(DecisionKey.inExtremisSecondAction)) {
      text =
          "First monster action is finished. It will now take an extra action.";
    } else {
      text = "Monster action is finished.";
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("End of action"),
        ),
        body: EverythingCenteredWidget(
            child: Column(children: [
          SimpleQuestionText(text),
          ElevatedButton(
              onPressed: () {
                // clean decision set, keep important stuff
                //Set<DecisionKey> kept_decisions = {};

                if (monster.isInExtremis &&
                    !monster.decisionsMemory
                        .contains(DecisionKey.inExtremisSecondAction)) {
                  // new extra action
                  monster.decisionsMemory
                      .add(DecisionKey.inExtremisSecondAction);
                  monster.endAction();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EnemyInMelee(gameState: gameState)));
                } else {
                  // END OF ACTIVATION
                  // clean monster memory
                  monster.decisionsMemory
                      .remove(DecisionKey.inExtremisSecondAction);
                  monster.endAction();
                  monster.endActivation();

                  // back to monster page, purge navigation
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GlobalGame(gameState: gameState)),
                      (route) => false);
                }
              },
              child: const ButtonText("Continue"))
        ])));
  }
}
