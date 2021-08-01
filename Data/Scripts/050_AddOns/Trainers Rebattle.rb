#
#
#
class RematchTrainer
  attr_reader :id
  attr_reader :nbTimesRematched

  def initialize(id)
    @id = id
    @nbTimesRematched = 0
  end

  def incrementNbTimes()
    @nbTimesRematched += 1
  end

  def removeNbTimes()
    @nbTimesRematched -= 1
  end
end

#Methods called from elsewhere in the code
#
# called from pbEndOfBattle
#
def incrNbRematches(trainerId)
  $PokemonGlobal.rematchedTrainers.each do |key, trainer|
    if(trainer.id == trainerId)
      trainer.incrementNbTimes()
    end
  end
end

# called from Trainer.to_trainer
def getNumberRematch(trainerId)
  if $PokemonGlobal.rematchedTrainers == nil
    $PokemonGlobal.rematchedTrainers = Hash.new
    addNewTrainerRematch(trainerId)
  end
  trainer = $PokemonGlobal.rematchedTrainers[trainerId.to_sym]
  if trainer == nil
    addNewTrainerRematch(trainerId)
    return 0
  end
  return (trainer.nbTimesRematched)
end

#
#
#
# #garder un list de cette classe en mem. globale
#
# #quand lance un combat: check si le switch pour rematch est actif.
# #si oui, check dans l'array globale si on trouve le trainer id.
# #si oui on maj, si non on l'ajoute
#
# #overload la classe qui lance les combats et ajuste les niveaux
# #selon le nb. de fois rematched
#
#
# # levelCap =  originalLevel + (nbBadges*2) +2
#
# # on incremente le level a chaque x (jusqu'au levelcap)
# #   nb = (level/10).ceil
#
#
def addNewTrainerRematch(trainerId)
  #$PokemonGlobal.rematchedTrainers[:trainerId]
  newTrainer = RematchTrainer.new(trainerId)
  $PokemonGlobal.rematchedTrainers[trainerId.to_sym] = newTrainer

end






def getNumberRematchOld(trainerId)
  if $PokemonGlobal.rematchedTrainers == nil
    $PokemonGlobal.rematchedTrainers = Hash.new
    addNewTrainerRematch(trainerId)
  end

  $PokemonGlobal.rematchedTrainers.each do |key, trainer|
    if(trainer.id == trainerId)
      return (trainer.nbTimesRematched)
    end
  end
  addNewTrainerRematch(trainerId)
  return 0
end



def getRematchLevel(originalLevel,nbRematch)
  levelCap = getLevelCap(originalLevel,$Trainer.numbadges)
  expRate = getLevelRate(originalLevel)
  levelIncr =0
  for i in 0..nbRematch
    if i % expRate == 0
      levelIncr += 1
    end
  end
  newLevel = originalLevel + levelIncr
  #printDebugRematchInfo(nbRematch,expRate,newLevel,levelCap,originalLevel)
  return (newLevel < levelCap) ? newLevel : levelCap
end

def getLevelRate(originalLevel)
  return 2 + (originalLevel/20).ceil
end

def getLevelCap(originalLevel,nbBadges)
  return 100 if $game_switches[599] #no cap in battle arena
  cap = originalLevel + nbBadges +2
  return cap < 100 ? cap : 100
end


def decreaseRematchNumber(trainerId)
  $PokemonGlobal.rematchedTrainers.each do |key, trainer|
    if(trainer.id == trainerId)
      trainer.removeNbTimes()
      return
    end
  end
end


def evolveRematchPokemon(nbRematch,species)
  if(nbRematch >= 10 && $Trainer.numbadges >= 3)
    evospecies=getEvolution(species)
    return species if evospecies == -1
    if(nbRematch >= 20 && $Trainer.numbadges >= 8)
      secondEvoSpecies=getEvolution(evospecies)
      return secondEvoSpecies == -1 ? evospecies : secondEvoSpecies
    end
    return evospecies
  end
  return species
end

def getEvolution(species)
  if species >= Settings::NB_POKEMON
    pokemon = PokeBattle_Pokemon.new(species,1)
    body = getBasePokemonID(species)
    head = getBasePokemonID(species,false)
    ret_evoB = pbGetEvolvedFormData(body)
    ret_evoH = pbGetEvolvedFormData(head)

    evoBody = ret_evoB.any? ? ret_evoB[0][2] : -1
    evoHead = ret_evoH.any? ? ret_evoH[0][2] : -1

    return -1 if isNegativeOrNull(evoBody) && isNegativeOrNull(evoHead)
    return body*Settings::NB_POKEMON+evoHead if isNegativeOrNull(evoBody)   #only head evolves
    return evoBody*Settings::NB_POKEMON + head if isNegativeOrNull(evoHead)  #only body evolves
    return evoBody*Settings::NB_POKEMON+evoHead                   #both evolve
  else
    evo = pbGetEvolvedFormData(species)
    return evo.any? ? evo[0][2] : -1
  end
end


def getFusionSpecies(body,head)
  id = body * Settings::NB_POKEMON + head
  return  GameData::Species.get(id).species
end
#
def evolveHead(species)
  if species <= Settings::NB_POKEMON
    evo = getEvolution(species)
    return evo == -1 ? species : evo
  end
  head = getBasePokemonID(species,false)
  body = getBasePokemonID(species)
  headEvo = getEvolution(head)
  return headEvo == -1 ? species : getFusionSpecies(body,headEvo)
end

def evolveBody(species)
  if species <= Settings::NB_POKEMON
    evo = getEvolution(species)
    return evo == -1 ? species : evo
  end
  head = getBasePokemonID(species,false)
  body = getBasePokemonID(species)
  bodyEvo = getEvolution(body)
  return bodyEvo == -1 ? species : getFusionSpecies(bodyEvo,head)
end


def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= Settings::NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species,false)
    ret1=-1;ret2=-1
    for form in pbGetEvolvedFormData(body)
      retB=yield pokemon,form[0],form[1],form[2]
      break if retB>0
    end
    for form in pbGetEvolvedFormData(head)
      retH=yield pokemon,form[0],form[1],form[2]
      break if retH>0
    end
    return ret if ret == retB && ret == retH
    return  fixEvolutionOverflow(retB,retH,pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies=form[2]
    end
    return newspecies;
  end

end


def printDebugRematchInfo(nbRematch,expRate,newLevel,levelCap,originalLevel)
  info = ""
  info << "total rematched trainers: "+   $PokemonGlobal.rematchedTrainers.length.to_s +  "\n"

  info << "nb times: "+  nbRematch.to_s +  "\n"
  info << "lvl up every " +  expRate.to_s +  " times" +  "\n"
  info << "original level: " << originalLevel.to_s +  "\n"
  info << "new level: " +  newLevel.to_s  +  "\n"
  info <<  "level cap: "+  levelCap.to_s
  print info
end
#
#
#
# class PokeBattle_Trainer
#   attr_accessor(:name)
#   def name()
#     return @name
#   end
# end