def pbGetRandomItem(item)
  #keyItem ou HM -> on randomize pas
  return item if $ItemData[item][ITEMTYPE] == 6 || $ItemData[item][ITEMUSE] == 4
  return item if isConst?(item, PBItems, :CELLBATTERY)
  return item if isConst?(item, PBItems, :MAGNETSTONE)

  #TM
  if ($ItemData[item][ITEMUSE] == 3)
    return $game_switches[959] ? pbGetRandomTM() : item
  end
  #item normal
  return item if !$game_switches[958]
  #berries
  return pbGetRandomBerry() if $ItemData[item][ITEMTYPE] == 5
  newItem = rand(PBItems.maxValue)
  #on veut pas de tm ou keyitem
  while ($ItemData[newItem][ITEMUSE] == 3 || $ItemData[newItem][ITEMUSE] == 4 || $ItemData[newItem][ITEMTYPE] == 6)
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end

def pbGetRandomBerry()
  newItem = rand(PBItems.maxValue)
  while (!($ItemData[newItem][ITEMTYPE] == 5))
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end

def pbGetRandomTM()
  newItem = rand(PBItems.maxValue)
  while (!($ItemData[newItem][ITEMUSE] == 3)) # || $ItemData[newItem][ITEMUSE]==4))
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end

