// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'utils.dart';

final Map<int, MonsterDescription> monsterDB = {
  11: MonsterDescription(
      'Avenkian Shrieking Shock Trooper',
      'Avenkian S.S.T.',
      21,
      25,
      AIType.monstrosity,
      [
        Attack(
            "Ripping Claws",
            "2x attacks (Melee, Combat, 2D6+3 damage). " +
                "If hit, target must pass a Dex check {0}. " +
                "Failure => Restrained.",
            [(20, 24)]),
        Attack(
            "Keening Shriek",
            "All team members within 12\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(21, 25)])
      ],
      MonsterSpecies.avenkian,
      11,
      111,
      [
        Attack(
            "Sonic Murmurs",
            "Whenever the monster suffers damage from " +
                "a weapon attack, all enemies within 12\" must pass a FOR check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(20, 24)]),
        Attack(
            "Psionic Disruption",
            "Whenever a team member attempts to use a Psionic power of any kind " +
                "they must pass a FOR check {0}." +
                "Failure => the power fails and the action is wasted.",
            [(18, 22)])
      ],
      {
        1: ([1], [])
      }),
  12: MonsterDescription(
      'Rakire Winged Hunter',
      'Rakire W.H.',
      25,
      32,
      AIType.monstrosity,
      [
        Attack(
            "Claw Swipes",
            "2x attacks (Melee, Combat, 2D6+1 damage). " +
                "If hit, target must pass a For check {0}. " +
                "Failure => Poisoned.",
            [(21, 25)]),
        Attack(
            "Grab and Drop",
            "Move to an ennemy within 6\", make 1x attack " +
                "(Melee, Combat, 1D6 damage). Target must pass Dex check {0}. " +
                "Failure => suffer damage of 12\" fall, monster stays in contact. " +
                "Success => monster flies to highest elevation with remaining movement. " +
                "If no higher elevation in range, monster will move away from target and " +
                "all other ennemies.",
            [(24, 28)])
      ],
      MonsterSpecies.rakire,
      12,
      112,
      [
        Attack(
            "Flyby Attack",
            "The Rakire Winged Hunter may take their action in " +
                "the middle of their move and resume that movement afterward " +
                "(splitting their movement distance before and after an attack " +
                "or any other action). The Rakire Winged Hunter will follow the " +
                "Enemy AI for Monstrosities, except it will always attempt to keep " +
                "moving after making an attack, and move to the highest vertical " +
                "point on the game board within its remaining movement distance.",
            []),
        Attack(
            "Hard to Restrain",
            "Whenever a Rakire Winged Hunter is subject to " +
                "a condition as a result of a Dexterity stat check, they may roll that " +
                "stat check twice and select the higher result. In addition, at the " +
                "start of their activation, the Rakire Winged Hunter automatically " +
                "clears one Dexterity condition without any check necessary (they " +
                "may make an additional check to clear a condition as normal).",
            [(18, 22)])
      ],
      {
        1: ([1], [])
      }),
  13: MonsterDescription(
      'Jel Brute',
      'Jel Brute',
      17,
      24,
      AIType.monstrosity,
      [
        Attack(
            "Crushing Fists",
            "2x attacks (Melee, Combat, 3D6 damage). " +
                "If hit, target must pass a For check {0}. " +
                "Failure => Stunned.",
            [(21, 25)]),
        Attack(
            "Shockwave",
            "All team members within 6\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(21, 25)]),
        Attack(
            "Stun Smash",
            "1x attack (Melee, Combat, 5D6 damage). " +
                "If hit, target must roll twice and take the lower result " +
                "on all attempts to clear the Stunned condition for " +
                "the remainder of the mission.",
            [])
      ],
      MonsterSpecies.jel,
      13,
      113,
      [
        Attack(
            "Brute Toughness",
            "Reduce all damage the monster suffers from weapons by 3. " +
                "The monster automatically clears all Fortitude conditions when it activates.",
            []),
        Attack(
            "Weak Mind",
            "Monster gets a -4 penalty to all stat checks made to resist any " +
                "condition with the Psionic keyword. If the monster suffers damage " +
                "from a source with the Psionic keyword, that damage is increased by 3.",
            [])
      ],
      {
        1: ([1], []),
        2: ([2], [1])
      })
};
