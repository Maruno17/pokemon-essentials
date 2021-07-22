def get_opponent_level
  return $Trainer.highest_level_pokemon_in_party
end

def get_egg_group_from_id(id)
  case id
  when 0 ;return nil
  when 1;return :Monster
  when 2;return :Water1
  when 3;return :Bug
  when 4;return :Flying
  when 5;return :Field
  when 6;return :Fairy
  when 7;return :Grass
  when 8;return :Humanlike
  when 9;return :Water3
  when 10;return :Mineral
  when 11;return :Amorphous
  when 12;return :Water2
  when 13;return :Ditto
  when 14;return :Dragon
  when 15;return :Undiscovered
  end
end

def get_egg_group_name(id)
  case id
  when 0 ;return nil
  when 1;return "Monster Pokémon"
  when 2;return :"Water Pokémon"
  when 3;return :"Bug Pokémon"
  when 4;return :"Bird Pokémon"
  when 5;return :"Land Pokémon"
  when 6;return :"Cute Pokémon"
  when 7;return :"Plant Pokémon"
  when 8;return :"Human-like Pokémon"
  when 9;return :"Water Pokémon"
  when 10;return :"Mineral Pokémon"
  when 11;return :"Blob Pokémon"
  when 12;return :"Water Pokémon"
  when 13;return :"Ditto"
  when 14;return :"Dragon Pokémon"
  when 15;return :"Legendary Pokémon"
  end
end

def get_random_trainer_name(trainer_class) #0: male, 1: female
gender = GameData::TrainerType.get(trainer_class).gender
  if(gender == 0)
    return RandTrainerNames_male[rand(RandTrainerNames_male.length)]
  else
    return RandTrainerNames_female[rand(RandTrainerNames_female.length)]
  end
end

def get_random_battle_lounge_egg_group
  _DISABLED_EGG_GROUPS = [0,13,15]
  group=0
  while _DISABLED_EGG_GROUPS.include?(group)
    group = rand(0,15)
  end
  return group
end

GENERIC_PRIZES_MULTI = [:HEARTSCALE,:LEMONADE]
GENERIC_PRIZES_SINGLE = [:RARECANDY,:RARECANDY,:PPUP,:EJECTBUTTON,:FOCUSBAND,:FOCUSSASH,:RESETURGE,:ABILITYURGE,:ITEMURGE,:ITEMDROP,:HPUP]
MONSTER_PRIZES = [:RAREBONE,:LAGGINGTAIL,:RAZORFANG,:RAZORCLAW,:GRIPCLAW]
WATER_PRIZES = [:MYSTICWATER,:BIGPEARL]
BUG_PRIZES = [:SILVERPOWDER,:SHEDSHELL]
FLYING_PRIZES = [:AIRBALLOON,:FLOATSTONE]
FIELD_PRIZES = [:MOOMOOMILK,:IRONBALL,:RAREBONE]
FAIRY_PRIZES = [:STARPIECE,:DESTINYKNOT,:MAXELIXIR]
HUMAN_PRIZES = [:BLACKBELT,:RINGTARGET,:EXPERTBELT]
GRASS_PRIZES = [:REVIVALHERB,:POWERHERB,:HEALPOWDER,:ABSORBBULB,:BIGMUSHROOM]
MINERAL_PRIZES = [:CELLBATTERY,:SHINYSTONE,:BIGNUGGET,:RELICCOPPER,:RELICGOLD,:RELICSILVER]
AMORPHOUS_PRIZES = [:SPELLTAG,:WIDELENS,:ZOOMLENS,:SCOPELENS]
DRAGON_PRIZES = [:DRAGONSCALE,:DRAGONFANG,:RARECANDY]
UNDISCOVERED_PRIZES = [:MASTERBALL,:SACREDASH]
#todo: prizes related to the group (ex: dragon fang for dragon types, TMs, etc. )
# todo: if heartscale, give a random amount from 10-20
def get_random_battle_lounge_prize(group_type)
  generic_prizes = [GENERIC_PRIZES_MULTI, GENERIC_PRIZES_SINGLE]
  is_generic_prize = rand(3)==1
  if is_generic_prize
    type = generic_prizes.sample
    return type.sample
  else
    case get_egg_group_from_id(group_type)
    when :Monster ; return MONSTER_PRIZES.sample
    when :Water1,:Water2,:Water3 ; return WATER_PRIZES.sample
    when :Bug ; return BUG_PRIZES.sample
    when :Flying ; return FLYING_PRIZES.sample
    when :Field ; return FIELD_PRIZES.sample
    when :Fairy ; return FAIRY_PRIZES.sample
    when :Grass ; return GRASS_PRIZES.sample
    when :Mineral ; return MINERAL_PRIZES.sample
    when :Humanlike ; return HUMAN_PRIZES.sample
    when :Amorphous ; return AMORPHOUS_PRIZES.sample
    when :Dragon ; return DRAGON_PRIZES.sample
    when :Undiscovered ; return UNDISCOVERED_PRIZES.sample
    end
  end

end



def generateSameEggGroupFusionsTeam(eggGroup_id)
  eggGroup = get_egg_group_from_id(eggGroup_id)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    foundFusionPartner = false
    species1 = rand(Settings::NB_POKEMON)+1
    if getPokemonEggGroups(species1).include?(eggGroup)
      foundFusionPartner = false
      while !foundFusionPartner
        species2 = rand(Settings::NB_POKEMON)+1
        if getPokemonEggGroups(species2).include?(eggGroup)
          generatedTeam << getFusionSpecies(species1, species2)
          foundFusionPartner = true
        end
      end
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end