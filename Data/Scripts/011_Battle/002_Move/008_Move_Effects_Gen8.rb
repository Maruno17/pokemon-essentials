=begin
Dynamax Cannon - 000
Behemoth Blade - 000
Behemoth Bash - 000
Branch Poke - 000
Overdrive - 000
Glacial Lance - 000
Astral Barrage - 000
Pyro Ball - 00A
Scorching Sands - 00A
Freezing Glare - 00C
Fiery Wrath - 00F
Strange Steam - 013
Breaking Swipe - 042
Thunderous Kick - 043
Skitter Smack - 045
Spirit Break - 045
Apple Acid - 046
Dragon Energy - 08B
Wicked Blow - 0A0
False Surrender - 0A5
Dual Wingbeat - 0BD
Triple Axel - 0BF
Meteor Assault - 0C2
Eternabeam - 0C2
Snap Trap - 0CF
Thunder Cage - 0CF
Flip Turn - 0EE
=end

#===============================================================================
# Poisons the target. This move becomes physical or special, whichever will deal
# more damage (only considers stats, stat stages and Wonder Room). Makes contact
# if it is a physical move. Has a different animation depending on the move's
# category. (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Burns the target if any of its stats were increased this round.
# (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Increases the user's Speed by 1 stage. This move's type depends on the user's
# form (Electric if Full Belly, Dark if Hangry). Fails if the user is not
# Morpeko (works if transformed into Morpeko). (Aura Wheel)
#===============================================================================
class PokeBattle_Move_178 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Increases the user's Attack, Defense, Speed, Special Attack and Special
# Defense by 1 stage each. The user cannot switch out or flee. Fails if the user
# is already affected by the second effect of this move, but can be used if the
# user is prevented from switching out or fleeing by another effect (in which
# case, the second effect of this move is not applied to the user). The user may
# still switch out if holding Shed Shell or Eject Button, or if affected by a
# Red Card. (No Retreat)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Reduces the user's HP by a third of its total HP, and increases the user's
# Attack, Defense, Speed, Special Attack and Special Defense by 1 stage each.
# Fails if it can't do both effects. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_UnimplementedMove
end

#===============================================================================
# Raises the Attack and Defense of all user's allies by 1 stage each. Bypasses
# protections, including Crafty Shield. Fails if there is no ally. (Coaching)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_UnimplementedMove
end

#===============================================================================
# Increases the target's Attack and Special Attack by 2 stages each. Bypasses
# some protections. (Decorate)
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_UnimplementedMove
end

#===============================================================================
# Decreases the target's Defense by 1 stage. Power is doubled if Gravity is in
# effect. (Grav Apple)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_UnimplementedMove
end

#===============================================================================
# Decreases the target's Speed by 1 stage. (Drum Beating)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_UnimplementedMove
end

#===============================================================================
# Decreases the target's Speed by 1 stage. Doubles the effectiveness of damaging
# Fire moves used against the target (this effect does not stack). Fails if
# neither of these effects can be applied. (Tar Shot)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_UnimplementedMove
end

#===============================================================================
# The target's types become Psychic. Fails if the target has the ability
# Multitype/RKS System or has a substitute. (Magic Powder)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Power is doubled if Electric Terrain applies. (Rising Voltage)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_UnimplementedMove
end

#===============================================================================
# If Psychic Terrain applies and the user is grounded, power is multiplied by
# 1.5 (in addition to Psychic Terrain's multiplier) and it targets all opposing
# Pokémon. (Expanding Force)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Power is doubled if a terrain applies and user is grounded; also, this move's
# type and animation depends on the terrain. (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Power is doubled if the user moves before the target, or if the target
# switched in this round. (Bolt Beak, Fishious Rend)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Power is doubled if any of the user's stats were lowered this round. (Lash Out)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_UnimplementedMove
end

#===============================================================================
# If Grassy Terrain applies, priority is increased by 1. (Grassy Glide)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_UnimplementedMove
end

#===============================================================================
# For the rest of this round, the user avoids all damaging moves that would hit
# it. If a move that makes contact is stopped by this effect, decreases the
# Defense of the Pokémon using that move by 2 stages. Contributes to Protect's
# counter. (Very similar to King's Shield.) (Obstruct)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Unaffected by moves and abilities that would redirect this move. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Hits 2 times in a row. The second hit targets the original target's ally if it
# had one (that can be targeted), or the original target if not. If the original
# target cannot be targeted, both hits target its ally. In a triple battle, the
# second hit will (try to) target one adjacent ally (how does it decide which
# one?).
#
# A Pokémon cannot be targeted if:
# * It is the user.
# * It would be immune due to its type or ability.
# * It is protected by a protection move (which ones?).
# * It is semi-invulnerable, or the move fails an accuracy check against it.
# * An ally is the centre of attention (e.g. because of Follow Me).
#
# All Pokémon hit by this move will apply their Pressure ability to it.
# (Dragon Darts)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Hits 3 times in a row. If each hit could be a critical hit, it will definitely
# be a critical hit. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_UnimplementedMove
end

#===============================================================================
# Hits 2-5 times in a row. If the move does not fail, increases the user's Speed
# by 1 stage and decreases the user's Defense by 1 stage. (Scale Shot)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_UnimplementedMove
end

#===============================================================================
# Two-turn attack. On the first turn, increases the user's Special Attack by 1
# stage. On the second turn, does damage. This attack is only considered to have
# been used after the second turn. (Meteor Beam)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user and its allies gain 25% of their total HP. (Works the same as
# Aromatherapy.) (Life Dew)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user and its allies gain 25% of their total HP and are cured of their
# permanent status problems. (Works the same as Aromatherapy.) (Jungle Healing)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_UnimplementedMove
end

#===============================================================================
# User faints. If Misty Terrain applies, base power is multiplied by 1.5.
# (Misty Explosion)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_UnimplementedMove
end

#===============================================================================
# The target can no longer switch out or flee. At the end of each round, the
# target's Defense and Special Defense are lowered by 1 stage each. (Does this
# only apply while the user remains in battle?) (Octolock)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Prevents the user and the target from switching out or fleeing. This effect
# isn't applied if either Pokémon is already prevented from switching out or
# fleeing. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user consumes its held berry and gains its effect. Also, increases the
# user's Defense by 2 stages. The berry can be consumed even if Unnerve/Magic
# Room apply. Fails if the user is not holding a berry. This move cannot be
# chosen to be used if the user is not holding a berry. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_UnimplementedMove
end

#===============================================================================
# All Pokémon (except semi-invulnerable ones) consume their held berries and
# gain their effects. Berries can be consumed even if Unnerve/Magic Room apply.
# Fails if no Pokémon have a held berry. If this move would trigger an ability
# that negates the move, e.g. Lightning Rod, the bearer of that ability will
# have their ability triggered regardless of whether they are holding a berry,
# and they will not consume their berry (how does this interact with the move
# failing?). (Teatime)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Negates the effect and usability of the target's held item for the rest of the
# battle (even if it is switched out). Fails if the target doesn't have a held
# item, the item is unlosable, the target has Sticky Hold, or the target is
# behind a substitute. (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user takes recoil damage equal to 1/2 of its total HP (rounded up, min. 1
# damage). (Steel Beam)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Decreases the PP of the last attack used by the target by 3 (or as much as
# possible). (Eerie Spell)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Fails if the target is not holding an item, or if the target is affected by
# Magic Room/Klutz. (Poltergeist)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_UnimplementedMove
end

#===============================================================================
# The user's Defense (and its Defense stat stages) are used instead of the
# user's Attack (and Attack stat stages) to calculate damage. All other effects
# are applied normally, applying the user's Attack modofiers and not the user's
# Defence modifiers. (Body Press)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_UnimplementedMove
end

#===============================================================================
# All effects that apply to one side of the field are swapped to the opposite
# side. (Court Change)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_UnimplementedMove
end

#===============================================================================
# Removes the current terrain. Fails if there is no terrain in effect.
# (Steel Roller)
#===============================================================================
class PokeBattle_Move_19A < PokeBattle_UnimplementedMove
end
