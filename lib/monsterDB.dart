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
            [(20, 24)],
            AttackType.normal),
        Attack(
            "Keening Shriek",
            "All team members within 12\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(21, 25)],
            AttackType.area)
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
            [(20, 24)],
            AttackType.passive),
        Attack(
            "Psionic Disruption",
            "Whenever a team member attempts to use a Psionic power of any kind " +
                "they must pass a FOR check {0}. " +
                "Failure => the power fails and the action is wasted.",
            [(18, 22)],
            AttackType.passive)
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
            [(21, 25)],
            AttackType.normal),
        Attack(
            "Grab and Drop",
            "Move to an enemy within 6\", make 1x attack " +
                "(Melee, Combat, 1D6 damage). Target must pass Dex check {0}. " +
                "Failure => suffer damage of 12\" fall, monster stays in contact. " +
                "Success => monster flies to highest elevation with remaining movement. " +
                "If no higher elevation in range, monster will move away from target and " +
                "all other ennemies.",
            [(24, 28)],
            AttackType.normal)
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
            [],
            AttackType.passive),
        Attack(
            "Hard to Restrain",
            "Whenever a Rakire Winged Hunter is subject to " +
                "a condition as a result of a Dexterity stat check, they may roll that " +
                "stat check twice and select the higher result. In addition, at the " +
                "start of their activation, the Rakire Winged Hunter automatically " +
                "clears one Dexterity condition without any check necessary (they " +
                "may make an additional check to clear a condition as normal).",
            [(18, 22)],
            AttackType.passive)
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
            [(21, 25)],
            AttackType.normal),
        Attack(
            "Shockwave",
            "All team members within 6\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage and Stunned.",
            [(21, 25)],
            AttackType.area),
        Attack(
            "Stun Smash",
            "1x attack (Melee, Combat, 5D6 damage) against the Stunned enemy. " +
                "If hit, target must roll twice and take the lower result " +
                "on all attempts to clear the Stunned condition for " +
                "the remainder of the mission.",
            [],
            AttackType.normal)
      ],
      MonsterSpecies.jel,
      13,
      113,
      [
        Attack(
            "Brute Toughness",
            "Reduce all damage the monster suffers from weapons by 3. " +
                "The monster automatically clears all Fortitude conditions when it activates.",
            [],
            AttackType.passive),
        Attack(
            "Weak Mind",
            "Monster gets a -4 penalty to all stat checks made to resist any " +
                "condition with the Psionic keyword. If the monster suffers damage " +
                "from a source with the Psionic keyword, that damage is increased by 3.",
            [],
            AttackType.passive)
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
            [(23, 27)],
            AttackType.normal),
        Attack(
            "Chewing Frenzy",
            "Restrained target must pass a For check {0}. " +
                "Failure => suffer 4D6 damage and Stunned.",
            [(24, 28)],
            AttackType.normal),
        Attack(
            "Consume All",
            "Stunned target must pass a For check {0}. " +
                "Failure => suffer 8D6 damage and the monster heals 4d6 damage.",
            [(25, 29)],
            AttackType.normal)
      ],
      MonsterSpecies.aglandian,
      14,
      114,
      [
        Attack(
            "Wave of Flesh",
            "Immune to Restrained and Blind conditions, and can never " +
                "have its move reduced for any reason or by any means.",
            [],
            AttackType.passive)
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
            [(22, 26)],
            AttackType.normal),
        Attack(
            "Mutilating Wave",
            "All team members within 6\" must pass a For check {0}. " +
                "Failure => suffer 2D6+2 damage and Poisoned.",
            [(22, 26)],
            AttackType.area)
      ],
      MonsterSpecies.centarian,
      15,
      116,
      [
        Attack(
            "Rock-Hard Skin",
            "Reduces all damage dealt by Ballistic weapons by 3.",
            [],
            AttackType.passive),
        Attack(
            "Climbing Limbs",
            "Does not pay additional movement when climbing; " +
                "each 1\" of vertical movement counts as 1\" of movement.",
            [],
            AttackType.passive),
        Attack(
            "Reverberating Destruction",
            "Whenever the monster is damaged by a Weapon attack, " +
                "all team members within 3\" must pass a For check {0}. " +
                "Failure => suffer 2D6 damage.",
            [(19, 23)],
            AttackType.passive)
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
            [(18, 22)],
            AttackType.normal),
        Attack(
            "Psionic Wave (Psionic)",
            "All team members within 12\" must pass a Dex check {0}. " +
                "Failure => suffer 3D6 damage and Blinded.",
            [(18, 22)],
            AttackType.area)
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
            [(18, 22)],
            AttackType.passive),
        Attack(
            "Psionic Hardening",
            "Reduce all damage from any attack with the Psionic keyword by 3. " +
                "The monster may automatically clear one condition at the start " +
                "of its activation if that condition was caused by a Psionic attack.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], [])
      },
      SpecialAttackQuestions({1: "Are there 1 or more enemy within 12\""},
          SpeAttackPreamblePosition.onBasicOnly)),
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
            [(18, 22)],
            AttackType.normal),
        Attack(
            "Nightmare Pulse (Psionic)",
            "All team members within 12\" must pass a For check {0}. " +
                "Failure => suffer 2D6+2 damage and Stunned.",
            [(19, 23)],
            AttackType.area),
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
            [(20, 24)],
            AttackType.normal)
      ],
      MonsterSpecies.deranger,
      21,
      118,
      [
        Attack(
            "Nightmare Visions (Psionic)",
            "Whenever an enemy activates within 12\", if they are making " +
                "a stat check to clear a condition with the Psionic keyword " +
                "they must roll twice and use the lower result.",
            [],
            AttackType.passive),
        Attack(
            "Psionic Healing",
            "Heals 4 damage whenever an enemy fails a stat check to avoid a " +
                "condition with the Psionic keyword resulting from an attack made by the Deranger.",
            [],
            AttackType.passive)
      ],
      {
        // TODO is it right ? rules unclear about cycling here
        1: ([1, 2], []),
        2: ([2], [1])
      },
      SpecialAttackQuestions({
        1: "Are there 1 or more enemy within 12\"",
        2: "Are there 1 or more enemy within 12\" either Stunned or Blinded?"
      }, SpeAttackPreamblePosition.onBasicOnly)),
  22: MonsterDescription(
      "Terraformer",
      "Terraformer",
      18,
      22,
      AIType.monstrosity,
      [
        Attack(
            "Rending Claws",
            "2x attacks (Melee, Combat, 2D6+1 damage). " +
                "If hit, target must pass a For check {0}. " +
                "Failure => 3D6 damage and Stunned.",
            [(17, 21)],
            AttackType.normal),
        Attack(
            "Earth Eruption",
            "All team members within 12\" must pass a Dex check {0}. " +
                "Failure => suffer 1D6 damage and Restrained.",
            [(18, 22)],
            AttackType.area),
      ],
      MonsterSpecies.terraformer,
      22,
      119,
      [
        Attack(
            "Terraform",
            "All terrain within 18\" of the Terraformer is considered Dangerous " +
                "terrain for enemies. The Terraformer ignores all Difficult " +
                "and Dangerous terrain.",
            [],
            AttackType.passive),
        Attack(
            "Deadly Terrain",
            "Whenever a model fails a check for Dangerous terrain while within " +
                "18\" of the Terraformer (see Dangerous Terrain, page 67), the " +
                "damage suffered is increased to 2D6 and the roll fails on a 4+ " +
                "(instead of 5+).",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], [])
      },
      SpecialAttackQuestions({1: "Are there 1 or more enemy within 12\""},
          SpeAttackPreamblePosition.onBasicOnly)),
  25: MonsterDescription(
      "Helion Beam Chaser",
      "Helion B.C.",
      24,
      28,
      AIType.ravager,
      [
        Attack(
            "Helo Blast",
            "2x attacks (Ranged, Combat, Energy, 2D6+4 damage). " +
                "If hit, target must pass a DEX check {0}. " +
                "Failure => Blinded.",
            [(21, 25)],
            AttackType.normal),
        Attack(
            "Wave of Heat",
            "All enemies within 12\" must pass a FOR check {0}. " +
                "Failure => Stunned.",
            [(21, 25)],
            AttackType.area),
        Attack(
            "Reflecting Blast",
            "The closest enemy must pass a DEX check {0}. " +
                "Failure => 4D6+6 damage and Stunned.",
            [(23, 27)],
            AttackType.normal),
      ],
      MonsterSpecies.helion,
      25,
      122,
      [
        Attack(
            "Energy Resistance",
            "Reduces all damage from attacks with the Energy type by half (rounding down).",
            [],
            AttackType.passive),
        Attack(
            "Heat Aura",
            "Any team member that ends their movement within 6\" of the monster " +
                "suffers 3D6 Energy damage.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], []),
        2: ([], [])
      },
      SpecialAttackQuestions({
        1: "Are there 2 or more enemies within 12\"?",
        2: "Did the monster suffer Energy damage since it last activated, " +
            "and is there 0 or 1 enemy within 12\"?"
      }, SpeAttackPreamblePosition.onAllAttacks)),
  31: MonsterDescription(
      "Tarskyth",
      "Tarskyth",
      26,
      30,
      AIType.ravager,
      [
        Attack(
            "Penetrating Pinions",
            "3x attacks (Ranged, Combat, 1D6+3 damage). " +
                "If hit, target must pass a FOR check {0}. " +
                "Failure => Poisoned and Stunned.",
            [(22, 26)],
            AttackType.normal),
        Attack(
            "Explosion of Spines",
            "All enemies within 18\" must pass a FOR check {0}. " +
                "Failure => Poisoned.",
            [(17, 21)],
            AttackType.area),
        Attack(
            "Restraining Spines",
            "The 2 closest enemies must pass a DEX check {0}. " +
                "Failure => Restrained.",
            [(20, 24)],
            AttackType.normal),
      ],
      MonsterSpecies.tarskyth,
      31,
      123,
      [
        Attack(
            "Sharp Vision",
            "Whenever the Tarskyth makes an Acuity check to spot a Hidden " +
                "enemy, it may roll twice and select the best result.",
            [],
            AttackType.passive),
      ],
      {
        1: ([1], []),
        2: ([], [1])
      },
      SpecialAttackQuestions({
        1: "Are there 2 or more enemies within 18\"?",
        2: "Are there 2 or more enemies within 18\"?"
      }, SpeAttackPreamblePosition.onAllAttacks)),
  32: MonsterDescription(
      "Ichor Spitter",
      "I. Spitter",
      20,
      24,
      AIType.ravager,
      [
        Attack(
            "Acidic Spit",
            "1x attacks (Ranged, Combat, 3D6+4 damage). " +
                "If hit, target must pass a DEX check {0}. " +
                "Failure => Blinded.",
            [(21, 25)],
            AttackType.normal),
        Attack(
            "Acid Spray",
            "All enemies within 12\" must pass a DEX check {0}. " +
                "Failure => 2D6+2 damage and Blinded.",
            [(20, 24)],
            AttackType.area),
      ],
      MonsterSpecies.ichor,
      32,
      124,
      [
        Attack("Potent Acid", "Ignore cover when making ranged attacks.", [],
            AttackType.passive),
        Attack(
            "Acidic Defense",
            "Whenever the Ichor Spitter suffers Weapon damage, " +
                "all enemies within 6\" suffer 1D6 damage.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], [])
      },
      SpecialAttackQuestions({
        1: "Are there 2 or more enemies within 12\"?",
      }, SpeAttackPreamblePosition.onAllAttacks)),
  33: MonsterDescription(
      "Spine Flinger",
      "S. Flinger",
      20,
      24,
      AIType.ravager,
      [
        Attack(
            "Spine Fling",
            "2x attacks (Ranged, Combat, 2D6+1 damage). " +
                "If hit, target must pass a DEX check {0}. " +
                "Failure => Restrained.",
            [(21, 25)],
            AttackType.normal),
        Attack(
            "Wrenching Impalement",
            "Move adjacent to the Restrained enemy and that enemy must " +
                "pass a FOR check {0}. " +
                "Failure => 4D6 damage and Stunned.",
            [(22, 26)],
            AttackType.normal),
        Attack(
            "Spine Spray",
            "All enemies within 12\" must pass a DEX check {0}. " +
                "Failure => 2D6 damage and Restrained.",
            [(21, 25)],
            AttackType.area),
      ],
      MonsterSpecies.spine,
      33,
      125,
      [
        Attack(
            "Spine Defenses",
            "Whenever the Spine Flinger suffers damage " +
                "from a Weapon attack, it reduces that damage by 2.",
            [],
            AttackType.passive),
        Attack(
            "Spinal Impalement",
            "When attempting to clear a condition " +
                "caused by a Spine Flinger, team members suffer a -2 penalty to " +
                "the stat check.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], []),
        2: ([2], [])
      },
      SpecialAttackQuestions({
        1: "Is there a Restrained enemy within 12\"?",
        2: "Is there 1 or more enemies within 12\" AND has the Spine Flinger " +
            "been critically hit since its last activation?"
      }, SpeAttackPreamblePosition.onAllAttacks)),
  34: MonsterDescription(
      "Navite Warrior",
      "Navite W.",
      17,
      22,
      AIType.ravager,
      [
        Attack(
            "Focused Shot",
            "1x attack (Ranged, Combat, Energy, 3D6+3 damage).",
            [],
            AttackType.normal),
        Attack(
            "Scatter Shot",
            "1x attack (Ranged, Combat, Energy, 2D6+2 damage) against each " +
                "enemy within 18\" that can be seen." +
                "If hit, target must pass a DEX check {0}. " +
                "Failure => Blinded.",
            [(20, 24)],
            AttackType.area),
        Attack(
            "Restraining Shot",
            "The closest enemy in line of sight must pass a DEX check {0}. " +
                "Failure => 3D6 damage and Restrained. " +
                "In addition, each time the target attempts to clear " +
                "this Restrained condition and fails, it suffers 3D6 damage",
            [(24, 28)],
            AttackType.normal),
      ],
      MonsterSpecies.navite,
      34,
      126,
      [
        Attack(
            "Shock Trooper",
            "At the start of every activation, auto-clear one condition " +
                "(if multiple conditions, choose randomly). " +
                "The Navite Warrior can still attempt to clear another condition as " +
                "normal.",
            [],
            AttackType.passive),
        Attack(
            "True Frenzy",
            "2 additional actions when In Extremis, suffers 4D6 damage instead " +
                "of 2D6.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], []),
        2: ([], [1])
      },
      SpecialAttackQuestions(
          {1: "Are there 2 or more enemies within 18\"?", 2: ""},
          SpeAttackPreamblePosition.onAllAttacks)),
  /*35: MonsterDescription(
      // something wrong, despite area check doing correctly on basic attack
      "Pulsar",
      "Pulsar",
      20,
      23,
      AIType.ravager,
      [
        Attack(
            "Pulse Wave (Psionic)",
            "All enemies within 12\" must pass a FOR check {0}. " +
                "Failure => 1D6 damage and Stunned.",
            [(18, 22)],
            AttackType.area),
        Attack(
            "Focusing Wave",
            "Target the closest Stunned enemy. If tied, choose randomly. " +
                "1x attack (Ranged, Psionic, 4D6+2 damage). " +
                "If attack scores a critical hit, target must pass a FOR check {0}. " +
                "Failure => Out of Action.",
            [(25, 29)],
            AttackType.normal),
        Attack(
            "Chaos Suggestion",
            "All enemies within 12\" that are Stunned must pass a FOR check {0}. " +
                "Failure => next time that enemy activates, " +
                "if they do not clear the Stunned condition, they must use their " +
                "attack action and determine their target randomly from all targets " +
                "they can see, whether friend or foe.",
            [(20, 24)],
            AttackType.area),
      ],
      MonsterSpecies.pulsar,
      35,
      127,
      [
        Attack(
            "Mental Defenses",
            "Whenever an enemy utilizes any ability with the " +
                "Psionic keyword while within 12\" of the Pulsar, they suffer 1D6 damage. " +
                "In addition, whenever the Pulsar makes a stat check to avoid or " +
                "clear a condition caused by an attack with the Psionic keyword, the " +
                "Pulsar rolls the stat check twice and selects the highest result.",
            [],
            AttackType.passive),
        Attack(
            "Derangement",
            "If an enemy activates within 12\" of the Pulsar and is " +
                "under the effect of any condition, they move randomly. Determine a " +
                "random direction and move the enemy their full movement distance " +
                "in a straight line in that direction. If this would carry the model into " +
                "Dangerous terrain, or cause it to fall, roll for those effects as normal.",
            [],
            AttackType.passive)
      ],
      {
        1: ([1], []),
        2: ([], [1])
      },
      SpecialAttackQuestions({
        0: "Is there 1 or more enemy within 12\"?",
        1: "Is there 1 or more Stunned enemy within 12\"?",
        2: "Is there 1 or more Stunned enemy within 12\"?"
      }, SpeAttackPreamblePosition.onAllAttacks)),
      */
  41: MonsterDescription(
      "Yvenian Shocker",
      "Yvenian S.",
      22,
      25,
      AIType.ravager,
      [
        Attack(
            "Shocking Blast",
            "2x attacks (Ranged, Combat, Energy, 2D6+1 damage). " +
                "If hit, target must pass a DEX check {0}. " +
                "Failure => Blinded.",
            [(20, 24)],
            AttackType.normal),
      ],
      MonsterSpecies.yvenian,
      41,
      128,
      [
        Attack(
            "Energy Defenses",
            // let user keep track of this
            "Whenever the Yvenian Shocker is hit by an attack with the Energy " +
                "keyword, it reduces all damage suffered by half (rounding down). " +
                "In addition, increase the number of attacks it makes with its Voltage " +
                "Blast attack (see below) by one during its next activation.",
            [],
            AttackType.passive),
        Attack(
            "Voltage Rejoinder",
            "If the Yvenian Shocker is critically hit by any attack, increase " +
                "the damage during its next activation by 2D6. This is cumulative " +
                "if the Yvenian Shocker suffers multiple critical hits between its " +
                "activations, but the bonus applies only to attacks made during its " +
                "next activation.",
            [],
            AttackType.passive),
        Attack(
            "Shocking Conclusion",
            "Whenever the Yvenian Shocker is In Extremis, all enemies within " +
                "12\" suffer damage equal to the In Extremis damage rolled by " +
                "the Yvenian Shocker.",
            [],
            AttackType.passive)
      ],
      {},
      SpecialAttackQuestions({}, SpeAttackPreamblePosition.onAllAttacks)),
};
