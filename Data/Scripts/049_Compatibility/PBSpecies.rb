module PBSpecies
  #couldn't figure out how to get the size of GameData::Species so fuck it, here's the hardcoded value
  def PBSpecies.maxValue
    return 176840
  end

  def PBSpecies.getName(species)
    return GameData::Species.get(species).real_name
  end

#In some places, pokemon are instanciated as PBSpecies::NAME in wild battles, trades, etc. which doesn't work anymore.
  # Instead of replacing every instance in every map, this is a workaround to make it work without changing the events.
  CLEFAIRY = :CLEFAIRY
  ONIX =:ONIX
  DUGTRIO = :DUGTRIO
  VOLTORB = :VOLTORB
  ELECTRODE = :ELECTRODE
  B101H135 = :B101H135
  B100H101 = :B100H101
  B101H26 = :B101H26
  ENTEI = :ENTEI
  PIDGEOTTO = :PIDGEOTTO
  FEAROW =:FEAROW
  SPEAROW =:SPEAROW
  B18H18 = :B18H18
  B245H243 = :B245H243
  CHARMANDER = :CHARMANDER

end

