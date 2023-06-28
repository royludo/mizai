// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:mizai/playMonstrosity.dart';
import 'utils.dart';
import 'monstrositySpecials.dart';

abstract class DecisionAccumulator extends StatelessWidget {
  const DecisionAccumulator({super.key, required this.monster});

  final StatefulMonster monster;
  //final Set<DecisionKey> decisions;
}

class CheckInExtremis extends DecisionAccumulator {
  const CheckInExtremis({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("In Extremis"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          Text(
              "The ${monster.desc.fullName} is In Extremis. It suffers 2D6 damage and will take an extra action!"),
          ElevatedButton(
              onPressed: () {
                switch (monster.desc.aiType) {
                  case AIType.monstrosity:
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnnemyInMelee(monster: monster);
                    }));
                  case AIType.ravager:
                    throw Exception("Ravager tree not implemented yet");
                  case AIType.stalker:
                    throw Exception("Stalker tree not implemented yet");
                }
              },
              child: const Text("Continue"))
        ]));
  }
}

class EnnemyInMelee extends DecisionAccumulator {
  const EnnemyInMelee({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("ennemyInMelee with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation A"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text("Is there any ennemy in melee range?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.ennemyInMelee);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AllEnnemyAttackedPreviously(monster: monster);
                    }));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnnemyInMelee);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnnemyInMovementRange(monster: monster);
                    }));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}

class AllEnnemyAttackedPreviously extends DecisionAccumulator {
  const AllEnnemyAttackedPreviously({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation B"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text("Have ALL the ennemies in melee range been previously " +
              "attacked during the last activation?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.allPreviouslyAttacked);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return WhereIsLowestHP(monster: monster);
                    }));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.somePreviouslyNotAttacked);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      const String commonPreamble =
                          "Target ennemy that was not attacked before and with " +
                              "the lowest HP. If tied, determine randomly.";

                      if (monster.isSpecialAttackPossible(false) &&
                          monster.isAnySpecialAttackAllowedNow()) {
                        switch (monster.desc.species) {
                          case MonsterSpecies.avenkian:
                            return AvenkianSSTDecision(
                              monster: monster,
                              preamble: commonPreamble,
                            );
                          case MonsterSpecies.rakire:
                            return RakireWHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.jel:
                            return JelBruteDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.aglandian:
                            return AglandianHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.centarian:
                            return CentarianMDecision(
                                monster: monster, preamble: commonPreamble);
                          default:
                            throw Exception("Monster not implemented yet");
                        }
                      } else {
                        return monster.makeBasicAttack(
                            context,
                            //decisions,
                            EndOfAction(monster: monster),
                            commonPreamble);
                      }
                    }));
                  },
                  child: const Text("No, one or more was not attacked"))
            ],
          )
        ]));
  }
}

class WhereIsLowestHP extends DecisionAccumulator {
  const WhereIsLowestHP({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("WhereIsLowestHP with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation C"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text("Where is the ennemy with the lowest HP? " +
              "(Ignore ennemies outside movement range)"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.lowestHPInMelee);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      const String commonPreamble =
                          "Target ennemy with lowest HP. If tied, determine randomly.";
                      if (monster.isSpecialAttackPossible(false) &&
                          monster.isAnySpecialAttackAllowedNow()) {
                        switch (monster.desc.species) {
                          case MonsterSpecies.avenkian:
                            return AvenkianSSTDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.rakire:
                            return RakireWHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.jel:
                            return JelBruteDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.aglandian:
                            return AglandianHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.centarian:
                            return CentarianMDecision(
                                monster: monster, preamble: commonPreamble);
                          default:
                            throw Exception("Monster not implemented yet");
                        }
                      } else {
                        return monster.makeBasicAttack(
                            context,
                            //decisions,
                            EndOfAction(monster: monster),
                            commonPreamble);
                      }
                    }));
                  },
                  child: const Text("Already in melee")),
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
                                EndOfAction(monster: monster),
                                "The monster moves up to its full movement distance to attack the " +
                                    "enemy with the lowest HP. If tied, determine randomly.")));
                  },
                  child: const Text("Reachable within movement range"))
            ],
          )
        ]));
  }
}

class EnnemyInMovementRange extends DecisionAccumulator {
  const EnnemyInMovementRange({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("ennemyInMelee with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation D"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text("Is any ennemy reachable within movement range?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.lowestHPWithinMovement);
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      const String commonPreamble =
                          "The monster moves up to its full movement distance to attack the " +
                              "enemy with the lowest HP. If tied, determine randomly.";
                      if (monster.isSpecialAttackPossible(false) &&
                          monster.isAnySpecialAttackAllowedNow()) {
                        switch (monster.desc.species) {
                          case MonsterSpecies.avenkian:
                            return AvenkianSSTDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.rakire:
                            return RakireWHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.jel:
                            return JelBruteDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.aglandian:
                            return AglandianHDecision(
                                monster: monster, preamble: commonPreamble);
                          case MonsterSpecies.centarian:
                            return CentarianMDecision(
                                monster: monster, preamble: commonPreamble);
                          default:
                            throw Exception("Monster not implemented yet");
                        }
                      } else {
                        return monster.makeBasicAttack(
                            context,
                            //decisions,
                            EndOfAction(monster: monster),
                            commonPreamble);
                      }
                    }));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.noEnemyInRange);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EnemyInLineOfSight(monster: monster);
                    }));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}

class EnemyInLineOfSight extends DecisionAccumulator {
  const EnemyInLineOfSight({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("ennemyInMelee with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation E"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text("Is any ennemy in line of sight and visible?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MaxMove(monster: monster)));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    monster.decisionsMemory
                        .add(DecisionKey.noEnemyInLineOfSight);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NoEnemyVisible(monster: monster)));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}

class MaxMove extends DecisionAccumulator {
  const MaxMove({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Maximum move"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text(
              "Move and use an extra move action instead of an attack to be " +
                  "within melee range or as close as possible of as many enemies " +
                  "as possible that can be seen."),
          ElevatedButton(
              onPressed: () {
                monster.decisionsMemory.add(DecisionKey.doubleMove);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EndOfAction(monster: monster)));
              },
              child: const Text("Continue"))
        ]));
  }
}

class NoEnemyVisible extends DecisionAccumulator {
  const NoEnemyVisible({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Situation F"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text(
              "If there are Hidden enemies, use an action to try to reveal them."),
          ElevatedButton(
              onPressed: () {
                monster.decisionsMemory.add(DecisionKey.enemyInLineOfSight);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NormalMove(monster: monster)));
              },
              child: const Text("One or more enemy was revealed")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RandomMove(monster: monster)));
              },
              child: const Text("Spot failed, or no Hidden enemy around"))
        ]));
  }
}

class NormalMove extends DecisionAccumulator {
  const NormalMove({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Normal move"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text(
              "Move to be within melee range or as close as possible of as many enemies " +
                  "as possible that can be seen."),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EndOfAction(monster: monster)));
              },
              child: const Text("Continue"))
        ]));
  }
}

class RandomMove extends DecisionAccumulator {
  const RandomMove({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("inextremis with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Random move"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          const Text(
              "Move in a random direction up to full movement distance."),
          ElevatedButton(
              onPressed: () {
                monster.decisionsMemory.add(DecisionKey.randomMove);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EndOfAction(monster: monster)));
              },
              child: const Text("Continue"))
        ]));
  }
}

class EndOfAction extends DecisionAccumulator {
  const EndOfAction({super.key, required super.monster});

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          Text(text),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EnnemyInMelee(monster: monster)));
                } else {
                  // END OF ACTIVATION
                  // clean monster memory
                  monster.decisionsMemory
                      .remove(DecisionKey.inExtremisSecondAction);
                  monster.endActivation();

                  // back to monster page, purge navigation
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlayMonstrosity(monster: monster)),
                      (route) => false);
                }
              },
              child: const Text("Continue"))
        ]));
  }
}
