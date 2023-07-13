import 'package:flutter/material.dart';
import 'package:mizai/decisionTree.dart';
import 'utils.dart';
import 'stalker_decision_tree.dart' as stalker_tree;

class Preamble {
  final String unspecificPreamble;
  String areaSpecificPreamble = "";

  Preamble(this.unspecificPreamble);
  Preamble.withArea(this.unspecificPreamble, this.areaSpecificPreamble);
  Preamble.empty() : this("");

  String getPreambleString(AttackType attackType) {
    if (areaSpecificPreamble.isEmpty) {
      return unspecificPreamble;
    } else {
      return switch (attackType) {
        AttackType.normal || AttackType.passive => unspecificPreamble,
        AttackType.area => areaSpecificPreamble
      };
    }
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
    String result = text.replaceAllMapped(RegExp(r'{(\d)}'), (match) {
      String parsedInt = match.group(1)!;
      int statIndex = int.parse(parsedInt);
      (int, int) statPair = varStats[statIndex];
      int statToUse;
      phase == 1 ? statToUse = statPair.$1 : statToUse = statPair.$2;
      return statToUse.toString();
    });

    return result;
  }
}

enum AIType { monstrosity, ravager, stalker, renvultia }

// onQuestion: preamble is put before question deciding attack
// onAllAttacks, onBasicOnly: preamble is put on attack screen, before attack text
enum SpeAttackPreamblePosition { onQuestion, onAllAttacks, onBasicOnly }

class SpecialAttackQuestions {
  /*
    Map looks like:
    attackIndex: string with the question to ask to decide for this attack
  */
  final Map<int, String> questionForAttack;
  final bool chainQuestions;
  final SpeAttackPreamblePosition preamblePosition;

  SpecialAttackQuestions(
      this.questionForAttack, this.chainQuestions, this.preamblePosition);
}

class StalkerSpecificAttributes {
  final (int, int) spotCheck;
  // does attack index (key) has some requirement for hidden/visible ?
  // true: attack requires to be hidden or requires to be visible
  // false: attack doesn't care about hidden status
  final Map<int, bool> attackHasVisibilityRequirement;
  // does attack index (key) require monster to be hidden ?
  // true: attack can only happen if hidden
  // false: attack can only happen if visible
  final Map<int, bool> attackRequiresHidden;
  final bool hasActionToHide;

  StalkerSpecificAttributes(this.spotCheck, this.attackHasVisibilityRequirement,
      this.attackRequiresHidden, this.hasActionToHide);
}

class MonsterDescription {
  final String fullName;
  final String shortName;
  final MonsterSpecies species;
  final int acuityP1;
  final int acuityP2;
  final AIType aiType;
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
  final StalkerSpecificAttributes? stalkerAttr;

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
      this.specialAttackQuestions,
      [this.stalkerAttr]);

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

  bool isStalkerLike() {
    return aiType == AIType.stalker || aiType == AIType.renvultia;
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
  noMove,
  activatedWithFirstInitiative,
  activatedWithSecondInitiative,
  activatedWithSpecial,
  // ravagers things
  noAreaAttackPossible,
  willMakeAreaAttack,
  willNOTMakeAreaAttack,
  yesToAreaAttackQuestion,
  noToAreaAttackQuestion,
  // renvultia things
  hasUsedCarefulStalking,
  hasUsedClawedStrike,
  hasUsedFlurry,
  activateStalkingBonus,
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
  crawler,
  zelak,
  helion,
  tarskyth,
  ichor,
  spine,
  navite,
  pulsar,
  yvenian,
  cannonade,
  raker,
  chaos,
  gzurn,
  razorlash,
  renvultia,
  ocular,
  lasher,
}

/// Main monster object of the game
/// Gets manipulated and modified through added variables to represent
/// its current state in the game
/// Has very limited undo possibilities, so going back in the middle
/// of an action will sometimes make things inconsistent.
/// Inconsistencies will happen after making an attack.
/// The developer deems this acceptable. Better let the user have some undo
/// possibility, and coding a true reversible history for the monster
/// is too much.
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

  bool isSpecialAttackPossible() {
    return !veryFirstAttack;
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
    for (var i = 1; i < desc.attacks.length; i++) {
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
      BuildContext context, Widget endPoint, Preamble preamble) {
    var preamblePosition = desc.specialAttackQuestions.preamblePosition;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Basic monster attacks"),
        ),
        body: EverythingCenteredWidget(
            child: Column(children: [
          preamblePosition == SpeAttackPreamblePosition.onAllAttacks ||
                  preamblePosition == SpeAttackPreamblePosition.onBasicOnly
              ? SimpleQuestionText(
                  preamble.getPreambleString(desc.attacks[0].type))
              : Container(),
          const Divider(
            indent: 5,
            endIndent: 5,
          ),
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
                // update monster state
                // this makes undos inconsistent, as we cannot undo the following changes
                // let's say this is ok
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
      Preamble preamble, int specialAttackIndex,
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
              ? SimpleQuestionText(
                  preamble.getPreambleString(desc.attacks[0].type))
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
          AttackText(attack.interpolatedText(phase)),
          ElevatedButton(
              onPressed: () {
                // update monster state
                // make undos inconsistent and it's ok
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

/// I think the general idea of this monster is that it doesn't attack often,
/// but when it does it hits really hard. Like it waits and super charges its
/// attack.
/// The monster will always use careful stalking twice
/// before moving to an attack. When attacking, it will cycle between
/// the basic and the special.
/// 2 stalk -> attack basic -> 2 stalk -> attack special -> 2 stalk...
/// It may not always cycle the attacks correctly, depending on the situation.
/// So there could be several stalk/flurry cycles, or several stalk/basic
/// one after the other.
/// Will revert to default behavior if:
///  - it cannot make the attack when it should be attacking (which makes it
/// lose the bonus), for example if no one in range or visible.
class RenvultiaStalker extends StatefulMonster {
  int carefulStalkingCounter = 0;
  bool isCarefulStalkingBonusActive = false;

  RenvultiaStalker(super.desc, super.phase) {
    if (super.desc.aiType != AIType.renvultia ||
        super.desc.species != MonsterSpecies.renvultia) {
      throw Exception("Wrong MonsterDescription given.");
    }
  }

  Widget useClawedStrike(
      BuildContext context, Widget endPoint, Preamble preamble) {
    decisionsMemory.add(DecisionKey.hasUsedClawedStrike);
    return super.makeBasicAttack(context, endPoint, preamble);
  }

  Widget useCarefulStalkingWhileHidden(
      BuildContext context, Widget endPoint, Preamble preamble) {
    decisionsMemory.add(DecisionKey.hasUsedCarefulStalking);
    decisionsMemory.add(DecisionKey.activateStalkingBonus);
    return super.makeSpecialAttack(context, endPoint, preamble, 2);
  }

  Widget useCarefulStalkingWhileVisible(
      BuildContext context, Widget endPoint, Preamble preamble) {
    decisionsMemory.add(DecisionKey.hasUsedCarefulStalking);
    return super.makeSpecialAttack(context, endPoint, preamble, 1);
  }

  Widget useFlurry(BuildContext context, Widget endPoint, Preamble preamble) {
    decisionsMemory.add(DecisionKey.hasUsedFlurry);
    return super.makeSpecialAttack(context, endPoint, preamble, 3);
  }

  @override
  void endAction() {
    super.endAction();

    if (decisionsMemory.contains(DecisionKey.hasUsedCarefulStalking)) {
      carefulStalkingCounter += 1;
      decisionsMemory.remove(DecisionKey.hasUsedCarefulStalking);
    }

    // reset stalking counter when using other attacks
    if (decisionsMemory.contains(DecisionKey.hasUsedClawedStrike) ||
        decisionsMemory.contains(DecisionKey.hasUsedFlurry)) {
      carefulStalkingCounter = 0;
      decisionsMemory.remove(DecisionKey.hasUsedClawedStrike);
      decisionsMemory.remove(DecisionKey.hasUsedFlurry);
    }

    if (decisionsMemory.contains(DecisionKey.activateStalkingBonus)) {
      isCarefulStalkingBonusActive = true;
      decisionsMemory.remove(DecisionKey.activateStalkingBonus);
    } else {
      // bonus is active only for 1 action
      // here we are at the end of the next action, so remove it
      isCarefulStalkingBonusActive = false;
    }
  }

  Widget startingPoint(BuildContext context, GameState gameState) {
    if (carefulStalkingCounter >= 2) {
      // time to attack
      if (isHidden) {
        attackIndexesExcludedForAction.add(3);
      } else {
        attackIndexesExcludedForAction.add(0);
      }
      return stalker_tree.EnemyInMelee(gameState: gameState);
    } else {
      // need to stalk a bit more
      if (isHidden) {
        return useCarefulStalkingWhileHidden(
            context,
            EndOfAction(gameState: gameState),
            Preamble(
                "Move away from the nearest enemy, ending in cover if possible."));
      } else {
        return useCarefulStalkingWhileVisible(
            context,
            EndOfAction(gameState: gameState),
            Preamble(
                "Move away from the nearest enemy, ending in cover if possible."));
      }
    }
  }

  @override
  Widget makeBasicAttack(
      BuildContext context, Widget endPoint, Preamble preamble) {
    return useClawedStrike(context, endPoint, preamble);
  }

  @override
  Widget makeSpecialAttack(BuildContext context, Widget endPoint,
      Preamble preamble, int specialAttackIndex,
      [Attack? overrideAttack]) {
    if (specialAttackIndex != 3) {
      throw Exception(
          "Renvultian Stalker can only make FLurry attack (index 3) "
          "through normal AI behavior. Other incompatible index ($specialAttackIndex) "
          "was provided.");
    }
    return useFlurry(context, endPoint, preamble);
  }
}

Widget makeBasicAttackWithCast(StatefulMonster monster, BuildContext context,
    Widget endPoint, Preamble preamble) {
  switch (monster.desc.aiType) {
    case AIType.renvultia:
      return (monster as RenvultiaStalker)
          .makeBasicAttack(context, endPoint, preamble);
    default:
      return monster.makeBasicAttack(context, endPoint, preamble);
  }
}

Widget makeSpecialAttackWithCast(StatefulMonster monster, BuildContext context,
    Widget endPoint, Preamble preamble, int specialAttackIndex,
    [Attack? overrideAttack]) {
  switch (monster.desc.aiType) {
    case AIType.renvultia:
      return (monster as RenvultiaStalker).makeSpecialAttack(
          context, endPoint, preamble, specialAttackIndex, overrideAttack);
    default:
      return monster.makeSpecialAttack(
          context, endPoint, preamble, specialAttackIndex, overrideAttack);
  }
}
