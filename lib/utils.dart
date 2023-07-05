// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

int monsterCodeFromButtonIndex(int index) {
  switch (index) {
    case 0:
      return 11;
    case 1:
      return 12;
    case 2:
      return 13;
    case 3:
      return 14;
    case 4:
      return 15;
    case 5:
      return 16;

    case 6:
      return 21;
    case 7:
      return 22;
    case 8:
      return 23;
    case 9:
      return 24;
    case 10:
      return 25;

    case 11:
      return 31;
    case 12:
      return 32;
    case 13:
      return 33;
    case 14:
      return 34;
    case 15:
      return 35;

    case 16:
      return 41;
    case 17:
      return 42;
    case 18:
      return 43;
    case 19:
      return 44;
    case 20:
      return 45;

    case 21:
      return 51;
    case 22:
      return 52;
    case 23:
      return 53;
    case 24:
      return 54;
    case 25:
      return 55;

    default:
      throw Exception("Unrecognized monster button index");
  }
}

enum AttackType { normal, area, passive }

class Attack {
  final String name;
  final String text;
  final List<(int, int)> varStats;
  final AttackType type;

  Attack(this.name, this.text, this.varStats, this.type);

  String interpolatedText(int phase) {
    //stdout.writeln("start interpolate text with phase $phase");
    String result = text.replaceAllMapped(RegExp(r'{(\d)}'), (match) {
      String parsedInt = match.group(1)!;
      int statIndex = int.parse(parsedInt);
      (int, int) statPair = varStats[statIndex];
      //stdout.writeln(">> ${match.group(0)!} $parsedInt $statIndex $statPair");
      int statToUse;
      phase == 1 ? statToUse = statPair.$1 : statToUse = statPair.$2;
      //stdout.writeln("use $statToUse");
      return statToUse.toString();
    });

    return result;
  }
}

enum AIType { monstrosity, ravager, stalker }

// onQuestion: preamble is put before question deciding attack
// onAllAttacks, onBasicOnly: preamble is put on attack screen, before attack text
enum SpeAttackPreamblePosition { onQuestion, onAllAttacks, onBasicOnly }

class SpecialAttackQuestions {
  /*
    Map looks like:
    attackIndex: string with the question to ask to decide for this attack
  */
  final Map<int, String> questionForAttack;
  final SpeAttackPreamblePosition preamblePosition;

  SpecialAttackQuestions(this.questionForAttack, this.preamblePosition);
}

class MonsterDescription {
  final String fullName;
  final String shortName;
  final MonsterSpecies species;
  final int acuityP1;
  final int acuityP2;
  final AIType aiType;
  //final Attack basicAttack;
  final List<Attack> attacks;
  final int code;
  final int pageReference;
  final List<Attack> passiveAbilities;
  /* 
    for each special attack as index
    tells if attack is forbidden if it was used previously, first List
    tells if attack has to have an attack used previously, 2nd List
  */
  final Map<int, (List<int>, List<int>)> specialAttacksConditions;
  final SpecialAttackQuestions specialAttackQuestions;

  MonsterDescription(
      this.fullName,
      this.shortName,
      this.acuityP1,
      this.acuityP2,
      this.aiType,
      //this.basicAttack,
      //this.specialAttacks,
      this.attacks,
      this.species,
      this.code,
      this.pageReference,
      this.passiveAbilities,
      this.specialAttacksConditions,
      this.specialAttackQuestions);

  int getAcuityFromPhase(int phase) {
    if (phase != 1 && phase != 2) {
      throw Exception("Phase argument must be 1 or 2");
    }
    return phase == 1 ? acuityP1 : acuityP2;
  }

  String getPrintableCode() {
    return code.toString().split('').join("-");
  }

  int getTotalNumberOfAttacks() {
    return attacks.length;
  }
}

enum DecisionKey {
  enemyInMelee,
  noEnemyInMelee,
  allPreviouslyAttacked,
  somePreviouslyNotAttacked,
  lowestHPInMelee,
  lowestHPWithinMovement,
  madeBasicAttack,
  madeSpecialAttack1,
  madeSpecialAttack2,
  inExtremisSecondAction,
  inExtremisThirdAction, // for navite warrior only
  noEnemyInRange,
  enemyInLineOfSight,
  noEnemyInLineOfSight,
  doubleMove,
  normalMove,
  randomMove,
  activatedWithFirstInitiative,
  activatedWithSecondInitiative,
  activatedWithSpecial,
  // ravagers things
  noAreaAttackPossible,
  willMakeAreaAttack,
  willNOTMakeAreaAttack,
  yesToAreaAttackQuestion,
  noToAreaAttackQuestion,
}

enum ActivationTriggerType { firstInitiative, secondInitiative, special }

enum MonsterSpecies {
  avenkian,
  rakire,
  jel,
  aglandian,
  centarian,
  talmak,
  deranger,
  terraformer,

  helion,
  tarskyth,
  ichor,
  spine,
  navite,
  pulsar,
  yvenian,
  cannonade,
}

class StatefulMonster {
  final MonsterDescription desc;
  final int phase; // 1 or 2
  bool veryFirstAttack = true;
  int nextAttackIndex = 0; // 0, 1, 2, 0 is basic attack
  List<int> currentActionAttackIndexes = [];
  List<int> previousActionAttackIndexes = [];
  bool isInExtremis = false;
  bool isHidden = false;
  Set<DecisionKey> decisionsMemory = {};
  List<ActivationTriggerType> activationTriggers = [];
  bool hasMovedBefore = false;

  /// deferred attack occur with ravagers as their AI may make them do stuff
  /// after attacking, and the decision for which attack to make was
  /// done way before
  int deferredAttackIndex = -1;
  List<int> attackIndexesExcludedForAction = [];

  StatefulMonster(this.desc, this.phase);

  bool specialAttacksRequireDecision() {
    return desc.specialAttackQuestions.questionForAttack.isNotEmpty;
  }

  bool specificSpeAttackRequireDecision(int attackIndex) {
    return desc.specialAttackQuestions.questionForAttack.isNotEmpty &&
        desc.specialAttackQuestions.questionForAttack[attackIndex]!.isNotEmpty;
  }

  bool endOfTurnPossible() {
    if (activationTriggers.contains(ActivationTriggerType.firstInitiative) &&
        activationTriggers.contains(ActivationTriggerType.secondInitiative)) {
      return true;
    }
    return maxActivationReached();
  }

  int getActivationCountThisTurn() {
    return activationTriggers.length;
  }

  bool maxActivationReached() {
    return activationTriggers.length >= 3;
  }

  bool isSpecialAttackPossible(bool forceBasicAttack) {
    if (veryFirstAttack || forceBasicAttack) {
      return false;
    }
    return true;
  }

  bool wasSpecialAttackUsedBefore(int specialAttackIndex) {
    return previousActionAttackIndexes.contains(specialAttackIndex);
  }

  bool isSpecificAttackAllowedNow(int specialAttackIndex) {
    if (attackIndexesExcludedForAction.isNotEmpty &&
        attackIndexesExcludedForAction.contains(specialAttackIndex)) {
      return false;
    }

    (List<int>, List<int>) rec =
        desc.specialAttacksConditions[specialAttackIndex]!;
    var forbiddenList = rec.$1;
    var allowedList = rec.$2;

    bool result = true;
    if (forbiddenList.isEmpty) {
      // no restriction on what was used before, so for now attack is ok
      result = true;
    } else {
      for (var i in forbiddenList) {
        for (var previous_i in previousActionAttackIndexes) {
          if (i == previous_i) {
            // attack listed as forbidden was used previously, so forbidden
            return false;
          }
        }
      }
    }

    if (allowedList.isEmpty) {
      // no restriction on what was used before, so for now attack is ok
      result = true;
    } else {
      // if allowedList exist, then its condition must be fullfiled
      result = false;
      for (var i in allowedList) {
        for (var previous_i in previousActionAttackIndexes) {
          if (i == previous_i) {
            // attack listed as mandatory in previous activation was found, so ok
            return true;
          }
        }
      }
    }

    return result;
  }

  bool isAnySpecialAttackAllowedNow() {
    /*stdout.writeln(
        "check any spec attack with previousIndexes: $previousActivationAttackIndexes");*/
    for (var i = 1; i < desc.attacks.length; i++) {
      //stdout.writeln("Checking ${desc.attacks[i].name}");
      if (isSpecificAttackAllowedNow(i)) {
        return true;
      }
    }
    return false;
  }

  void endAction() {
    previousActionAttackIndexes = List.from(currentActionAttackIndexes);
    currentActionAttackIndexes.clear();
    if (decisionsMemory.contains(DecisionKey.normalMove) ||
        decisionsMemory.contains(DecisionKey.doubleMove) ||
        decisionsMemory.contains(DecisionKey.randomMove)) {
      hasMovedBefore = true;
    } else {
      hasMovedBefore = false;
    }
    // in any case, remove the move memories
    decisionsMemory.remove(DecisionKey.normalMove);
    decisionsMemory.remove(DecisionKey.doubleMove);
    decisionsMemory.remove(DecisionKey.randomMove);

    attackIndexesExcludedForAction.clear();
  }

  void endActivation() {
    // pull activation triggers from monster memory and record them in dedicated array
    if (decisionsMemory.contains(DecisionKey.activatedWithFirstInitiative)) {
      activationTriggers.add(ActivationTriggerType.firstInitiative);
    }
    if (decisionsMemory.contains(DecisionKey.activatedWithSecondInitiative)) {
      activationTriggers.add(ActivationTriggerType.secondInitiative);
    }
    if (decisionsMemory.contains(DecisionKey.activatedWithSpecial)) {
      activationTriggers.add(ActivationTriggerType.special);
    }
    decisionsMemory.clear();
  }

  void endTurn() {
    activationTriggers.clear();
  }

  Widget makeBasicAttack(
      BuildContext context, Widget endPoint, String preamble) {
    var preamblePosition = desc.specialAttackQuestions.preamblePosition;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Basic monster attacks"),
        ),
        body: EverythingCenteredWidget(
            child: Column(children: [
          preamblePosition == SpeAttackPreamblePosition.onAllAttacks ||
                  preamblePosition == SpeAttackPreamblePosition.onBasicOnly
              ? SimpleQuestionText(preamble)
              : Container(),
          const Divider(
            indent: 5,
            endIndent: 5,
          ),
          /*const Text("<< ATTACK >>",
              style: TextStyle(fontWeight: FontWeight.bold)),*/
          const SizedBox(
            height: 10,
          ),
          Text(
            "ATTACK: ${desc.attacks[0].name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          AttackText(desc.attacks[0].interpolatedText(phase)),
          ElevatedButton(
              onPressed: () {
                //decisions.add(DecisionKey.madeBasicAttack);

                // update monster state
                veryFirstAttack = false;
                nextAttackIndex = 1 % desc.getTotalNumberOfAttacks();
                currentActionAttackIndexes.add(0);

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return endPoint;
                }));
              },
              child: const ButtonText("Continue"))
        ])));
  }

  Widget makeSpecialAttack(BuildContext context, Widget endPoint,
      String preamble, int specialAttackIndex,
      [Attack? overrideAttack]) {
    if (specialAttackIndex < 0 || specialAttackIndex >= desc.attacks.length) {
      // index out of range
      throw Exception(
          "Special attack index out of range. Index: $specialAttackIndex while array has length ${desc.attacks.length}");
    }

    Attack attack;
    if (overrideAttack != null) {
      // special case for cannonade
      attack = overrideAttack;
    } else {
      attack = desc.attacks[specialAttackIndex];
    }

    var preamblePosition = desc.specialAttackQuestions.preamblePosition;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Special monster attacks"),
        ),
        body: EverythingCenteredWidget(
            child: Column(children: [
          preamblePosition == SpeAttackPreamblePosition.onAllAttacks
              ? SimpleQuestionText(preamble)
              : Container(),
          // also remove cosmetic divider if no preamble is there
          preamblePosition == SpeAttackPreamblePosition.onAllAttacks
              ? const Divider(
                  indent: 5,
                  endIndent: 5,
                )
              : Container(),
          const SizedBox(
            height: 10,
          ),
          Text(
            "ATTACK: ${attack.name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          //SimpleQuestionText(attack.name),
          AttackText(attack.interpolatedText(phase)),
          ElevatedButton(
              onPressed: () {
                //decisions.add(attackNumber);

                // update monster state
                nextAttackIndex =
                    (specialAttackIndex + 1) % desc.getTotalNumberOfAttacks();
                currentActionAttackIndexes.add(specialAttackIndex);

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return endPoint;
                }));
              },
              child: const ButtonText("Continue"))
        ])));
  }
}

class GameState {
  final List<StatefulMonster> allGameMonsters;
  final StatefulMonster currentMonster;

  GameState(this.allGameMonsters, this.currentMonster);

  bool isSoloGame() {
    return allGameMonsters.length == 1;
  }

  bool isMultiplayerGame() {
    return allGameMonsters.length > 1;
  }
}

/// very outer widget used across the app
class EverythingCenteredWidget extends StatelessWidget {
  const EverythingCenteredWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    //var monster = gameState.currentMonster;
    //stdout.writeln("AllEnemyAttackedPreviously with decisions: $decisions");
    return Center(
        child: Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: child,
    ));
  }
}

class SimpleQuestionText extends StatelessWidget {
  const SimpleQuestionText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Text(
        data,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class ButtonText extends StatelessWidget {
  const ButtonText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: const TextStyle(fontSize: 18),
    );
  }
}

class AttackText extends StatelessWidget {
  const AttackText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    RegExp reBaseText = RegExp(r'(.+)Failure|Success');
    RegExp reFail = RegExp(r'Failure\s?=>\s?{(.+?)}');
    RegExp reSuccess = RegExp(r'Success\s?=>\s?{(.+?)}');
    RegExp reTrailingText = RegExp(r'(Failure|Success).+}(.*)');
    RegExpMatch? matchBaseText = reBaseText.firstMatch(data);
    RegExpMatch? matchFailure = reFail.firstMatch(data);
    RegExpMatch? matchSuccess = reSuccess.firstMatch(data);
    RegExpMatch? matchTrailingText = reTrailingText.firstMatch(data);

    List<InlineSpan> resultContent = [];

    if (matchBaseText != null) {
      String baseText = matchBaseText.group(1)!;
      resultContent.add(TextSpan(
        text: baseText + "\n",
      ));
    } else {
      resultContent.add(TextSpan(
        text: data,
      ));
    }

    if (matchFailure != null) {
      String failureConsequence = matchFailure.group(1)!;
      resultContent
          .addAll(prettyConsequenceSection("Failure", failureConsequence));
    }

    if (matchSuccess != null) {
      String successConsequence = matchSuccess.group(1)!;
      resultContent
          .addAll(prettyConsequenceSection("Success", successConsequence));
    }

    if (matchTrailingText != null) {
      String trailingText = matchTrailingText.group(2)!;
      if (trailingText.isNotEmpty) {
        resultContent.add(TextSpan(text: trailingText));
      }
    }

    Text resultWidget = Text.rich(TextSpan(
        children: resultContent, style: const TextStyle(fontSize: 16)));

    return Container(
      margin: const EdgeInsets.all(10),
      child: resultWidget,
    );
  }
}

List<InlineSpan> prettyConsequenceSection(String title, String body) {
  return [
    TextSpan(
      text: "$title\n",
      style: const TextStyle(fontSize: 16),
    ),
    WidgetSpan(
      //child: SizedBox(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.subdirectory_arrow_right),
        const SizedBox(
          width: 5,
        ),
        Flexible(
            child: Text(
          body,
          style: const TextStyle(fontSize: 16),
        )),
      ]),
    )
  ];
}
