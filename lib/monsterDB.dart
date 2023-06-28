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
      },
      SpecialAttackQuestions({1: "Are there 2 or more ennemies within 12\"?"},
          SpeAttackPreamblePosition.onBasicOnly)),
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
        1: ([], [0])
      },
      SpecialAttackQuestions(
          {1: "Did the monster start the activation with an enemy within 6\"?"},
          SpeAttackPreamblePosition.onAllAttacks)),
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
            "1x attack (Melee, Combat, 5D6 damage) against the Stunned enemy. " +
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
        1: ([1, 2], []),
        2: ([2], [1])
      },
      SpecialAttackQuestions({
        1: "Are there 2 or more ennemies within 6\"?",
        2: "Did the monster activate within 6\" of a Stunned enemy?"
      }, SpeAttackPreamblePosition.onBasicOnly)),
  14: MonsterDescription(
      "Aglandian Horror",
      "Aglandian H.",
      28,
      35,
      AIType.monstrosity,
      [
        Attack(
            "Grabbing Limbs",
            "2x attacks (Melee, Combat, 1D6+4 damage). " +
                "Each attack targets a different team member if possible. " +
                "If hit, targets must pass a Dex check {0}. " +
                "Failure => Restrained.",
            [(23, 27)]),
        Attack(
            "Chewing Frenzy",
            "Restrained target must pass a For check {0}. " +
                "Failure => suffer 4D6 damage and Stunned.",
            [(24, 28)]),
        Attack(
            "Consume All",
            "Stunned target must pass a For check {0}. " +
                "Failure => suffer 8D6 damage and the monster heals 4d6 damage.",
            [(25, 29)])
      ],
      MonsterSpecies.aglandian,
      14,
      114,
      [
        Attack(
            "Wave of Flesh",
            "Immune to Restrained and Blind conditions, and can never " +
                "have its move reduced for any reason or by any means.",
            [])
      ],
      {
        1: ([1], []),
        2: ([], [1])
      },
      SpecialAttackQuestions({
        1: "Is there a Restrained enemy within melee range?",
        2: "Is there a Stunned enemy within melee range?"
      }, SpeAttackPreamblePosition.onBasicOnly)),
  15: MonsterDescription(
      "Centarian Mauler",
      "Centarian M.",
      20,
      25,
      AIType.monstrosity,
      [
        Attack(
            "Destructive Limbs",
            "3x attacks (Melee, Combat, 1D6+6 damage). " +
                "If hit, target must pass a For check {0}. " +
                "Failure => Stunned.",
            [(22, 26)]),
        Attack(
            "Mutilating Wave",
            "All team members within 6\" must pass a For check {0}. " +
                "Failure => suffer 2D6+2 damage and Poisoned.",
            [(22, 26)])
      ],
      MonsterSpecies.centarian,
      15,
      116,
      [
        Attack("Rock-Hard Skin",
            "Reduces all damage dealt by Ballistic weapons by 3.", []),
        Attack(
            "Climbing Limbs",
            "Does not pay additional movement when climbing; " +
                "each 1\" of vertical movement counts as 1\" of movement.",
            []),
        Attack(
            "Reverberating Destruction",
            "Whenever the monster is damaged by a Weapon attack, " +
                "all team members within 3\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage.",
            [(19, 23)])
      ],
      {
        1: ([1], [])
      },
      SpecialAttackQuestions({1: "Are there 2 or more ennemies within 6\"?"},
          SpeAttackPreamblePosition.onBasicOnly)),
  16: MonsterDescription(
      "Talmak Spawn",
      "Talmak Spawn",
      19,
      23,
      AIType.monstrosity,
      [
        Attack(
            "Psionic Claws (Psionic)",
            "1x attack (Melee, Combat, Psionic, 4D6+2 damage). " +
                "If hit, target must pass a For check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(18, 22)]),
        Attack(
            "Psionic Wave (Psionic)",
            "All team members within 12\" must pass a Dex check {0}. " +
                "Failure => suffer 3D6 damage and Blinded.",
            [(18, 22)])
      ],
      MonsterSpecies.talmak,
      16,
      117,
      [
        Attack(
            "Twisted Creature (Psionic)",
            "Whenever the monster suffers damage from a Weapon attack, it " +
                "suffers 1D6 additional damage and " +
                "all team members within 18\" must pass a For check {0}." +
                "Failure => suffer 2D6 damage.",
            [(18, 22)]),
        Attack(
            "Psionic Hardening",
            "Reduce all damage from any attack with the Psionic keyword by 3. " +
                "The monster may automatically clear one condition at the start " +
                "of its activation if that condition was caused by a Psionic attack.",
            [])
      ],
      {
        1: ([1], [])
      },
      SpecialAttackQuestions({}, SpeAttackPreamblePosition.onBasicOnly)),
  21: MonsterDescription(
      "Deranger",
      "Deranger",
      22,
      24,
      AIType.monstrosity,
      [
        Attack(
            "Psionic Lash (Psionic)",
            "3x attacks (Melee, Combat, Psionic, 1D6+2 damage). " +
                "If hit, target must pass a Dex check {0}. " +
                "Failure => Blinded.",
            [(18, 22)]),
        Attack(
            "Nightmare Pulse (Psionic)",
            "All team members within 12\" must pass a For check {0}. " +
                "Failure => suffer 2D6+2 damage and Stunned.",
            [(19, 23)]),
        Attack(
            "Deepened Nightmares (Psionic)",
            "Target enemy within 12\" who is either Stunned or Blinded must pass a For check {0}. " +
                "Failure => suffer 5D6 damage and immediately move 12\" " +
                "directly away from the Deranger. If this movement would carry " +
                "the enemy into Difficult terrain (or up a vertical surface), " +
                "they must pay for that additional movement as normal. If this " +
                "movement would carry the enemy into Dangerous terrain, they will " +
                "suffer any consequences of that as normal. If this movement would " +
                "move them off of a horizontal surface that is elevated, they will " +
                "fall and suffer damage as normal, with no chance to reduce it.",
            [(20, 24)])
      ],
      MonsterSpecies.deranger,
      21,
      118,
      [
        Attack(
            "Nightmare Visions (Psionic)",
            "Whenever an enemy activates within 12\", if they are making" +
                "a stat check to clear a condition with the Psionic keyword " +
                "they must roll twice and use the lower result.",
            []),
        Attack(
            "Psionic Healing",
            "Heals 4 damage whenever an enemy fails a stat check to avoid a " +
                "condition with the Psionic keyword resulting from an attack made by the Deranger.",
            [])
      ],
      {
        // TODO is it right ? rules unclear about cycling here
        1: ([1, 2], []),
        2: ([2], [1])
      },
      SpecialAttackQuestions({
        1: "",
        2: "Are there 1 or more enemy within 12\" either Stunned or Blinded?"
      }, SpeAttackPreamblePosition.onBasicOnly))
};
