import 'package:flutter/material.dart';
import 'decisionTree.dart';

class AvenkianSSTDecision extends DecisionAccumulator {
  const AvenkianSSTDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: Text("${monster.desc.shortName} special attack"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          // use preamble as part of checking range condition, else it's weird
          // situation where we check 12" before moving and making attack
          Text("$preamble Are there 2 or more ennemies within 12\"?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeSpecialAttack(
                                context,
                                EndOfAction(monster: monster),
                                "",
                                1)));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeBasicAttack(
                                context, EndOfAction(monster: monster), "")));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}

class RakireWHDecision extends DecisionAccumulator {
  const RakireWHDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: Text("${monster.desc.shortName} special attack"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          // use preamble as part of checking range condition, else it's weird
          // situation where we check 12" before moving and making attack
          Text(
              "$preamble Did the monster start the activation with an enemy within 6\"?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeSpecialAttack(
                                context,
                                EndOfAction(monster: monster),
                                "",
                                1)));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeBasicAttack(
                                context, EndOfAction(monster: monster), "")));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}

class JelBruteDecision extends DecisionAccumulator {
  const JelBruteDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");

    Map<int, String> questionForAttack = {
      1: "$preamble Are there 2 or more ennemies within 6\"?",
      2: "$preamble Did the monster activate within 6\" of a Stunned enemy?"
    };

    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i)) {
        return Scaffold(
            appBar: AppBar(
              title: Text("${monster.desc.shortName} special attack $i"),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Column(children: [
              // use preamble as part of checking range condition, else it's weird
              // situation where we check 12" before moving and making attack
              Text(questionForAttack[i]!),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeSpecialAttack(
                                    context,
                                    EndOfAction(monster: monster),
                                    "",
                                    i)));
                      },
                      child: const Text("Yes")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeBasicAttack(
                                    context,
                                    EndOfAction(monster: monster),
                                    "")));
                      },
                      child: const Text("No"))
                ],
              )
            ]));
      }
    }
    throw Exception("${monster.desc.shortName} special attack not found");
  }
}

class AglandianHDecision extends DecisionAccumulator {
  const AglandianHDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");

    Map<int, String> questionForAttack = {
      1: "Is there a Restrained enemy within melee range?",
      2: "Is there a Stunned enemy within melee range?"
    };

    for (var i = 1; i < monster.desc.attacks.length; i++) {
      if (monster.isSpecificAttackAllowedNow(i)) {
        return Scaffold(
            appBar: AppBar(
              title: Text("${monster.desc.shortName} special attack $i"),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Column(children: [
              // use preamble as part of checking range condition, else it's weird
              // situation where we check 12" before moving and making attack
              Text(questionForAttack[i]!),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeSpecialAttack(
                                    context,
                                    EndOfAction(monster: monster),
                                    questionForAttack[i]!,
                                    i)));
                      },
                      child: const Text("Yes")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => monster.makeBasicAttack(
                                    context,
                                    EndOfAction(monster: monster),
                                    preamble)));
                      },
                      child: const Text("No"))
                ],
              )
            ]));
      }
    }
    throw Exception("${monster.desc.shortName} special attack not found");
  }
}

class CentarianMDecision extends DecisionAccumulator {
  const CentarianMDecision(
      {super.key, required super.monster, required this.preamble});

  final String preamble;

  @override
  Widget build(BuildContext context) {
    //stdout.writeln("AllEnnemyAttackedPreviously with decisions: $decisions");
    return Scaffold(
        appBar: AppBar(
          title: Text("${monster.desc.shortName} special attack"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Column(children: [
          // use preamble as part of checking range condition, else it's weird
          // situation where we check 12" before moving and making attack
          Text("$preamble Are there 2 or more ennemies within 6\"?"),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeSpecialAttack(
                                context,
                                EndOfAction(monster: monster),
                                "",
                                1)));
                  },
                  child: const Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => monster.makeBasicAttack(
                                context, EndOfAction(monster: monster), "")));
                  },
                  child: const Text("No"))
            ],
          )
        ]));
  }
}
