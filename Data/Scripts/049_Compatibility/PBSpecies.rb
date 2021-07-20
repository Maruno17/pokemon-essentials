module PBSpecies
  #couldn't figure out how to get the size of GameData::Species so fuck it, here's the hardcoded value
  def PBSpecies.maxValue
    return 176832
  end

  def PBSpecies.getName(species)
    return GameData::Species.get(species).real_name
  end
end

