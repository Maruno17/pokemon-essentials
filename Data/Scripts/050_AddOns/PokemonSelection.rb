#===============================================================================
# * Pokémon Selection - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a pokémon selection system
# similar to Stadium/Battle Tower, where you can choose a certain number and
# order of pokémon.
#
#===============================================================================
#
# To this script works, put it above main and use in script command
# 'PokemonSelection.choose(min, max, canCancel, acceptFainted)' where min and
# max are the minimum and maximum pokémon number selection (default values are
# 1 and 6), canCancel when true the player can cancel the selection (default
# is false) and acceptFainted that when true the player can choose fainted
# pokémon and eggs (default is false). This method return if a party is choosen.
#
# To restore the previous party, use 'PokemonSelection.restore'. This do nothing
# is there's no party to restore. Ths method returns if the party is restored.
#
# Between the two commands, don't allow the player to caught or deposit/withdraw
# any pokémon or the pokémon will be lost! However, you pokémon can gain
# exp/level, evolve, change hold item/moves normally. If you try to choose a
# new party before restore the old one, the game raises an error. This won't
# occurs if the previous selection is only an order change. ONLY in Debug mode
# you get the phrase "Generate Pokemon teams for this challenge?", always
# choose "No".
#
# 'PokemonSelection.hasValidTeam?(min, max, canCancel, acceptFainted)' returns
# if your team is valid. If you try to use a invalid team (like putting the
# minimum pokémon number as 3, but only having 2 pokémon), the selection is
# treats as canceled. If the canCancel=false, the game goes in an infinite loop.
#
# Example: To make a 3vs3 battle, use 'PokemonSelection.choose(3,3)' and, after
# the battle (regardless of result) use 'PokemonSelection.restore'. Only allows
# the player to go in the battle if 'PokemonSelection.hasValidTeam?(3,3)' is
# true, or set the minimum as 1.
#
# To perform only an order change, use
# 'PokemonSelection.choose($Trainer,party.size,$Trainer,party.size,true,true)'.
#
# If you take a look in PokemonChallengeRules applications in scripts you can
# customize some others choice conditions like have a certain level or ban
# certain pokémon.
#
#===============================================================================

module PokemonSelection
  def self.rules(min=1, max=6, canCancel=false, acceptFainted=false)
    ret=PokemonChallengeRules.new
    # ret.setLevelAdjustment(OpenLevelAdjustment.new(PBExperience::MAXLEVEL))
     ret.addPokemonRule(AblePokemonRestriction.new) if !acceptFainted
     ret.ruleset.setNumberRange(min,max)
    return ret
  end

  def self.hasValidTeam?(min=1, max=6, canCancel=false, acceptFainted=false)
    pbBattleChallenge.set("pokemonSelectionRules",7,self.rules(min,max))
    ret=pbHasEligible?
    pbBattleChallenge.pbCancel
    return ret
  end

  def self.choose(min=1, max=6, canCancel=false, acceptFainted=false)
    if $PokemonGlobal.pokemonSelectionOriginalParty
      raise "Can't choose a new party until restore the old one"
    end
    validPartyChosen=false
    pbBattleChallenge.set("pokemonSelectionRules",7,self.rules(min,max))
    loop do
      pbEntryScreen
      validPartyChosen=(pbBattleChallenge.getParty!=nil)
      break if(canCancel || validPartyChosen)
      Kernel.pbMessage(_INTL("Choose a Pokémon."))
    end
    if validPartyChosen
      # If the party size is the same, it is only an order change
      if($Trainer.party.size != pbBattleChallenge.getParty.size)
        $PokemonGlobal.pokemonSelectionOriginalParty=$Trainer.party
      end
      $Trainer.party=pbBattleChallenge.getParty
    end
    pbBattleChallenge.pbCancel
    return validPartyChosen
  end


  def self.restore(*args)
    hasSavedTeam=($PokemonGlobal.pokemonSelectionOriginalParty!=nil)
    if hasSavedTeam
      $Trainer.party=$PokemonGlobal.pokemonSelectionOriginalParty
      $PokemonGlobal.pokemonSelectionOriginalParty=nil
    end
    return hasSavedTeam
  end
end

class PokemonRuleSet # Redefined to fix a bug
  def hasValidTeam?(team)
    if !team || team.length<self.minTeamLength
      return false
    end
    teamNumber=[self.maxLength,team.length].min
    validPokemon=[]
    for pokemon in team
      if isPokemonValid?(pokemon)
        validPokemon.push(pokemon)
      end
    end
    #if validPokemon.length<teamNumber # original
    if validPokemon.length<self.minLength # fixed
      return false
    end
    if @teamRules.length>0
      pbEachCombination(team,teamNumber){|comb|
        if isValid?(comb)
          return true
        end
      }
      return false
    end
    return true
  end
end

class BattleChallenge; def getParty; return @bc.party; end; end

class PokemonGlobalMetadata; attr_accessor :pokemonSelectionOriginalParty; end