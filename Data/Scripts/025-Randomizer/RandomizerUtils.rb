NON_RANDOMIZE_ITEMS = [:CELLBATTERY, :MAGNETSTONE, :TM94, :DYNAMITE]
HELD_ITEMS = [:AIRBALLOON, :BRIGHTPOWDER, :EVIOLITE, :FLOATSTONE, :DESTINYKNOT, :ROCKYHELMET, :EJECTBUTTON, :REDCARD,
              :SHEDSHELL, :SMOKEBALL, :CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :HEATROCK, :DAMPROCK, :SMOOTHROCK, :ICYROCK,
              :LIGHTCLAY, :GRIPCLAW, :BINDINGBAND, :BIGROOT, :BLACKSLUDGE, :LEFTOVERS, :SHELLBELL, :MENTALHERB, :WHITEHERB,
              :POWERHERB, :ABSORBBULB, :CELLBATTERY, :LIFEORB, :EXPERTBELT, :METRONOME, :MUSCLEBAND, :WISEGLASSES,
              :RAZORCLAW, :SCOPELENS, :WIDELENS, :ZOOMLENS, :KINGSROCK, :RAZORFANG, :LAGGINGTAIL, :QUICKCLAW,
              :FOCUSBAND, :FOCUSSASH, :FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL, :RINGTARGET,
              :MACHOBRACE, :POWERWEIGHT, :POWERBRACER, :POWERBELT, :POWERLENS, :POWERBAND, :POWERANKLET,
              :LAXINCENSE, :FULLINCENSE, :LUCKINCENSE, :PUREINCENSE, :SEAINCENSE, :WAVEINCENSE, :ROSEINCENSE,
              :ODDINCENSE, :ROCKINCENSE, :CHARCOAL, :MYSTICWATER, :MAGNET, :HARDSTONE, :SILVERPOWDER,
              :TWISTEDSPOON, :SHARPBEAK, :POISONBARB, :BLACKBELT, :NEVERMELTICE, :MIRACLESEED, :SILKSCARF,
              :METALCOAT, :BLACKGLASSES, :DRAGONFANG, :SPELLTAG, :FIREGEM, :WATERGEM, :ELECTRICGEM,
              :GRASSGEM, :ICEGEM, :FIGHTINGGEM, :POISONGEM, :GROUNDGEM, :FLYINGGEM, :PSYCHICGEM,
              :BUGGEM, :ROCKGEM, :GHOSTGEM, :DRAGONGEM, :DARKGEM, :STEELGEM, :NORMALGEM,
              :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY,
              :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY,
              :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY,
              :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY,
              :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY,
              :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY,
              :JABOCABERRY, :ROWAPBERRY, :FAIRYGEM]

INVALID_ITEMS = [:COVERFOSSIL, :PLUMEFOSSIL, :ACCURACYUP, :DAMAGEUP, :ANCIENTSTONE, :ODDKEYSTONE_FULL,
                 :TM00,:DEVOLUTIONSPRAY, :INVISIBALL]
RANDOM_ITEM_EXCEPTIONS = [:DNASPLICERS, :DYNAMITE]

def getRandomGivenTM(item)
  return item if item == nil
  return item if RANDOM_TM_EXCEPTIONS.include?(item.id)
  if $game_switches[SWITCH_RANDOM_ITEMS_MAPPED]
    newItem = $PokemonGlobal.randomTMsHash[item.id]
    return GameData::Item.get(newItem) if newItem != nil
  end
  if $game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC]
    return pbGetRandomTM
  end
  return item
end

def getMappedRandomItem(item)
  if (item.is_TM?)
    return item if NON_RANDOMIZE_ITEMS.include?(item.id)
    return item if !$game_switches[SWITCH_RANDOM_TMS]
    if $game_switches[SWITCH_RANDOM_TMS]
      newItem = $PokemonGlobal.randomTMsHash[item.id]
      return GameData::Item.get(newItem) if newItem != nil
    end
    return item
  else
    return item if !$game_switches[SWITCH_RANDOM_ITEMS]
    if $game_switches[SWITCH_RANDOM_ITEMS]
      newItem = $PokemonGlobal.randomItemsHash[item.id]
      return GameData::Item.get(newItem) if newItem != nil
      return item
    end
  end
end

def getDynamicRandomItem(item)
  #keyItem ou HM -> on randomize pas
  return item if item.is_key_item?
  return item if item.is_HM?
  return item if NON_RANDOMIZE_ITEMS.include?(item.id)

  #TM
  if (item.is_TM?)
    return $game_switches[SWITCH_RANDOM_TMS] ? pbGetRandomTM() : item
  end
  #item normal
  return item if !$game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC] || !$game_switches[SWITCH_RANDOM_ITEMS]


  #berries
  return pbGetRandomBerry() if item.is_berry?

  items_list = GameData::Item.list_all
  newItem_id = items_list.keys.sample
  newItem = GameData::Item.get(newItem_id)
  while (newItem.is_machine? || newItem.is_key_item? || INVALID_ITEMS.include?(newItem))
    newItem_id = items_list.keys.sample
    newItem = GameData::Item.get(newItem_id)
  end
  return newItem
end

def pbGetRandomItem(item_id)
  return nil if item_id == nil
  item = GameData::Item.get(item_id)
  return item if !($game_switches[SWITCH_RANDOM_ITEMS] || $game_switches[SWITCH_RANDOM_TMS])
  if $game_switches[SWITCH_RANDOM_ITEMS_MAPPED]
    return getMappedRandomItem(item)
  elsif $game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC]
    return getDynamicRandomItem(item)
  end
  return item
end

def pbGetRandomHeldItem()
  newItem_id = HELD_ITEMS.sample
  newItem = GameData::Item.get(newItem_id)
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

