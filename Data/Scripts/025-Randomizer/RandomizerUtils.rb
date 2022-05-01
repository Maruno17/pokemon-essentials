NON_RANDOMIZE_ITEMS = [:CELLBATTERY,:MAGNETSTONE]


def pbGetRandomItem(item_id)
  item = GameData::Item.get(item_id)

  #keyItem ou HM -> on randomize pas
  return item if item.is_key_item?
  return item if item.is_HM?
  return item if NON_RANDOMIZE_ITEMS.include?(item.id)

  #TM
  if (item.is_TM?)
    return $game_switches[SWITCH_RANDOM_TMS] ? pbGetRandomTM() : item
  end
  #item normal
  return item if !$game_switches[SWITCH_RANDOM_ITEMS]

  #berries
  return pbGetRandomBerry() if item.is_berry?

  items_list = GameData::Item.list_all
  newItem_id = items_list.keys.sample
  newItem = GameData::Item.get(newItem_id)
  while (newItem.is_machine? || newItem.is_key_item?)
    newItem_id = items_list.keys.sample
    newItem = GameData::Item.get(newItem_id)
  end
  return newItem
end



def pbGetRandomBerry()
  items_list = GameData::Item.list_all
  newItem_id = items_list.keys.sample
  newItem = GameData::Item.get(newItem_id)
  while (!newItem.is_berry?)
    newItem_id = items_list.keys.sample
    newItem = GameData::Item.get(newItem_id)
  end
  return newItem
end

def pbGetRandomTM()
  items_list = GameData::Item.list_all
  newItem_id = items_list.keys.sample
  newItem = GameData::Item.get(newItem_id)
  while (!newItem.is_TM?)
    newItem_id = items_list.keys.sample
    newItem = GameData::Item.get(newItem_id)
  end
  return newItem
end

