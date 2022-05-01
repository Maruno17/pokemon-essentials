NON_RANDOMIZE_ITEMS = [:CELLBATTERY, :MAGNETSTONE]
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

def pbGetRandomItem(item_id)
  return nil if item_id == nil
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

