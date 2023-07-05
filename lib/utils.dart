// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

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
