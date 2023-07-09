// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'main_screen_wrapper.dart';
import 'utils.dart';
import 'monstrosity_decision_tree.dart' as monstrosity_tree;
import 'ravager_decision_tree.dart' as ravager_tree;
import 'stalker_decision_tree.dart' as stalker_tree;
import 'model.dart';

/// get the first screen of the decision tree of the specific monster
/// doesn't take in extremis into account
Widget getStartingPoint(
    BuildContext context, StatefulMonster monster, GameState gameState) {
  switch (monster.desc.aiType) {
    case AIType.monstrosity:
      if (monster.desc.species == MonsterSpecies.zelak) {
        return monstrosity_tree.ZelakSpecial1(gameState: gameState);
      } else {
        return monstrosity_tree.EnemyInMelee(gameState: gameState);
      }
    case AIType.ravager:
      if (monster.decisionsMemory.contains(DecisionKey.activatedWithSpecial)) {
        return monster.makeBasicAttack(context,
            EndOfAction(gameState: gameState), "Target enemy who just missed.");
      } else {
        return ravager_tree.EnemyInMelee(gameState: gameState);
      }
    case AIType.stalker:
      return stalker_tree.EnemyInMelee(gameState: gameState);
  }
}

abstract class MonsterDecisionStep extends StatelessWidget {
  const MonsterDecisionStep({super.key, required this.gameState});

  final GameState gameState;
  //final Set<DecisionKey> decisions;

  void initiateGeneralAttackProcess(
      BuildContext context,
      StatefulMonster monster,
      String commonPreamble,
      MonsterDecisionStep nextStep) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (monster.isSpecialAttackPossible() &&
          monster.isAnySpecialAttackAllowedNow()) {
        // first checks say it is possible to have a special attack
        // loop determines first available spe attack that does not
        // require a decision step = 1st spe attack that auto apply
        for (var i = 1; i < monster.desc.attacks.length; i++) {
          if (monster.isSpecificAttackAllowedNow(i) &&
              !monster.specificSpeAttackRequireDecision(i)) {
            return monster.makeSpecialAttack(
                context, nextStep, commonPreamble, i);
          }
        }
        // at this point we are sure we need a decision for the special attack
        // else the attack would have been made already
        return SimpleSpecialDecision(
          gameState: gameState,
          preamble: commonPreamble,
          nextStep: nextStep,
        );
      } else {
        // spe attack not possible, revert to basic one
        return monster.makeBasicAttack(context, nextStep, commonPreamble);
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

    String inExtremisDamage = "2D6";
    if (monster.desc.species == MonsterSpecies.navite) {
      inExtremisDamage = "4D6";
    }
    String extraActionsAmount = "an extra action";
    if (monster.desc.species == MonsterSpecies.navite) {
      extraActionsAmount = "2 extra actions";
    }

    return GenericChoiceStep(
        gameState: gameState,
        title: "In Extremis",
        content: Column(children: [
          SimpleQuestionText(
              "The ${monster.desc.fullName} is In Extremis. It suffers $inExtremisDamage damage and will take $extraActionsAmount!"),
          ElevatedButton(
              onPressed: () {
                // special case for cannonade here, as it self destructs
                if (monster.desc.species == MonsterSpecies.cannonade) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return monster.makeSpecialAttack(
                        context,
                        EndOfAction(gameState: gameState),
                        "",
                        0, // <- attack index is useless here
                        // cannonade final attack is listed in the passives
                        monster.desc.passiveAbilities[1]);
                  }));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return getStartingPoint(context, monster, gameState);
                  }));
                }
              },
              child: const ButtonText("Continue"))
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

class SimpleSpecialDecision extends MonsterDecisionStep {
  const SimpleSpecialDecision(
      {super.key,
      required super.gameState,
      required this.preamble,
      required this.nextStep});

  final String preamble;
  final MonsterDecisionStep nextStep;

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
                                    context, nextStep, preamble, i)));
                      },
                      child: const ButtonText("Yes")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeBasicAttack(
                                    context, nextStep, preamble)));
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

class EndOfAction extends MonsterDecisionStep {
  const EndOfAction({super.key, required super.gameState});

  @override
  Widget build(BuildContext context) {
    var monster = gameState.currentMonster;
    //stdout.writeln("endofaction with decisions: $decisions");

    String text;
    if (monster.isInExtremis &&
        !monster.decisionsMemory.contains(DecisionKey.inExtremisSecondAction) &&
        monster.desc.species != MonsterSpecies.cannonade) {
      text =
          "First monster action is finished. It will now take an extra action.";
    } else if (monster.desc.species == MonsterSpecies.navite &&
        monster.isInExtremis &&
        !monster.decisionsMemory.contains(DecisionKey.inExtremisThirdAction)) {
      text =
          "Second monster action is finished. It will now take another extra action.";
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
                        .contains(DecisionKey.inExtremisSecondAction) &&
                    monster.desc.species != MonsterSpecies.cannonade) {
                  // new extra action
                  monster.decisionsMemory
                      .add(DecisionKey.inExtremisSecondAction);
                  monster.endAction();

                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return getStartingPoint(context, monster, gameState);
                  }));
                } else if (monster.desc.species == MonsterSpecies.navite &&
                    monster.isInExtremis &&
                    !monster.decisionsMemory
                        .contains(DecisionKey.inExtremisThirdAction)) {
                  // another extra action for navite warrior
                  monster.decisionsMemory
                      .add(DecisionKey.inExtremisThirdAction);
                  monster.endAction();

                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return getStartingPoint(context, monster, gameState);
                  }));
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
                          builder: (_) =>
                              MainScreenWrapper(gameState: gameState)),
                      (route) => false);
                }
              },
              child: const ButtonText("Continue"))
        ])));
  }
}
