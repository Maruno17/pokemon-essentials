module MultipleForms
  @@formSpecies = SpeciesHandlerHash.new

  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end

  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end

  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end

  def self.hasFunction?(pkmn,func)
    spec = (pkmn.is_a?(Pokemon)) ? pkmn.species : pkmn
    sp = @@formSpecies[spec]
    return sp && sp[func]
  end

  def self.getFunction(pkmn,func)
    spec = (pkmn.is_a?(Pokemon)) ? pkmn.species : pkmn
    sp = @@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end

  def self.call(func,pkmn,*args)
    sp = @@formSpecies[pkmn.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pkmn,*args)
  end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height = spotpattern.length
  width  = spotpattern[0].length
  for yy in 0...height
    spot = spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg = (x+xx)<<1
        yOrg = (y+yy)<<1
        color = bitmap.get_pixel(xOrg,yOrg)
        r = color.red+red
        g = color.green+green
        b = color.blue+blue
        color.red   = [[r,0].max,255].min
        color.green = [[g,0].max,255].min
        color.blue  = [[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end
    end
  end
end

def pbSpindaSpots(pkmn,bitmap)
  spot1 = [
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2 = [
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3 = [
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4 = [
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id = pkmn.personalID
  h = (id>>28)&15
  g = (id>>24)&15
  f = (id>>20)&15
  e = (id>>16)&15
  d = (id>>12)&15
  c = (id>>8)&15
  b = (id>>4)&15
  a = (id)&15
  if pkmn.shiny?
    drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
    drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
    drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
    drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

#===============================================================================
# Regular form differences
#===============================================================================

MultipleForms.register(:UNOWN,{
  "getFormOnCreation" => proc { |pkmn|
    next rand(28)
  }
})

MultipleForms.register(:SPINDA,{
  "alterBitmap" => proc { |pkmn,bitmap|
    pbSpindaSpots(pkmn,bitmap)
  }
})

MultipleForms.register(:CASTFORM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:GROUDON,{
  "getPrimalForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:REDORB)
    next
  }
})

MultipleForms.register(:KYOGRE,{
  "getPrimalForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:BLUEORB)
    next
  }
})

MultipleForms.register(:BURMY,{
  "getFormOnCreation" => proc { |pkmn|
    case pbGetEnvironment
    when :Rock, :Sand, :Cave
      next 1   # Sandy Cloak
    when :None
      next 2   # Trash Cloak
    else
      next 0   # Plant Cloak
    end
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next if !endBattle || !usedInBattle
    case battle.environment
    when :Rock, :Sand, :Cave
      next 1   # Sandy Cloak
    when :None
      next 2   # Trash Cloak
    else
      next 0   # Plant Cloak
    end
  }
})

MultipleForms.register(:WORMADAM,{
  "getFormOnCreation" => proc { |pkmn|
    case pbGetEnvironment
    when :Rock, :Sand, :Cave
      next 1   # Sandy Cloak
    when :None
      next 2   # Trash Cloak
    else
      next 0   # Plant Cloak
    end
  }
})

MultipleForms.register(:CHERRIM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:ROTOM, {
  "onSetForm" => proc { |pkmn, form, oldForm|
    form_moves = [
       :OVERHEAT,    # Heat (microwave oven)
       :HYDROPUMP,   # Wash (washing machine)
       :BLIZZARD,    # Frost (refrigerator)
       :AIRSLASH,    # Fan (electric fan)
       :LEAFSTORM    # Mow (lawn mower)
    ]
    # Find a known move that should be forgotten
    old_move_index = -1
    pkmn.moves.each_with_index do |move, i|
      next if !form_moves.include?(move.id)
      old_move_index = i
      break
    end
    # Determine which new move to learn (if any)
    new_move_id = (form > 0) ? form_moves[form - 1] : nil
    new_move_id = nil if !GameData::Move.exists?(new_move_id)
    if new_move_id.nil? && old_move_index >= 0 && pkmn.numMoves == 1
      new_move_id = :THUNDERSHOCK
      new_move_id = nil if !GameData::Move.exists?(new_move_id)
      raise _INTL("Rotom is trying to forget its last move, but there isn't another move to replace it with.") if new_move_id.nil?
    end
    # Forget a known move (if relevant) and learn a new move (if relevant)
    if old_move_index >= 0
      old_move_name = pkmn.moves[old_move_index].name
      if new_move_id.nil?
        # Just forget the old move
        pkmn.forget_move_at_index(old_move_index)
        pbMessage(_INTL("{1} forgot {2}...\1", pkmn.name, old_move_name))
      else
        # Replace the old move with the new move (keeps the same index)
        pkmn.moves[old_move_index].id = new_move_id
        new_move_name = pkmn.moves[old_move_index].name
        pbMessage(_INTL("{1} forgot {2}...\1", pkmn.name, old_move_name))
        pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]\1", pkmn.name, new_move_name))
      end
    elsif !new_move_id.nil?
      # Just learn the new move
      pbLearnMove(pkmn, new_move_id, true)
    end
  }
})

MultipleForms.register(:GIRATINA,{
  "getForm" => proc { |pkmn|
    maps = [49,50,51,72,73]   # Map IDs for Origin Forme
    if pkmn.hasItem?(:GRISEOUSORB) || ($game_map && maps.include?($game_map.map_id))
      next 1
    end
    next 0
  }
})

MultipleForms.register(:SHAYMIN,{
  "getForm" => proc { |pkmn|
    next 0 if pkmn.fainted? || pkmn.status == :FROZEN || PBDayNight.isNight?
  }
})

MultipleForms.register(:ARCEUS,{
  "getForm" => proc { |pkmn|
    next nil if !pkmn.hasAbility?(:MULTITYPE)
    typeArray = {
       1  => [:FISTPLATE,   :FIGHTINIUMZ],
       2  => [:SKYPLATE,    :FLYINIUMZ],
       3  => [:TOXICPLATE,  :POISONIUMZ],
       4  => [:EARTHPLATE,  :GROUNDIUMZ],
       5  => [:STONEPLATE,  :ROCKIUMZ],
       6  => [:INSECTPLATE, :BUGINIUMZ],
       7  => [:SPOOKYPLATE, :GHOSTIUMZ],
       8  => [:IRONPLATE,   :STEELIUMZ],
       10 => [:FLAMEPLATE,  :FIRIUMZ],
       11 => [:SPLASHPLATE, :WATERIUMZ],
       12 => [:MEADOWPLATE, :GRASSIUMZ],
       13 => [:ZAPPLATE,    :ELECTRIUMZ],
       14 => [:MINDPLATE,   :PSYCHIUMZ],
       15 => [:ICICLEPLATE, :ICIUMZ],
       16 => [:DRACOPLATE,  :DRAGONIUMZ],
       17 => [:DREADPLATE,  :DARKINIUMZ],
       18 => [:PIXIEPLATE,  :FAIRIUMZ]
    }
    ret = 0
    typeArray.each do |f, items|
      for item in items
        next if !pkmn.hasItem?(item)
        ret = f
        break
      end
      break if ret > 0
    end
    next ret
  }
})

MultipleForms.register(:BASCULIN,{
  "getFormOnCreation" => proc { |pkmn|
    next rand(2)
  }
})

MultipleForms.register(:DARMANITAN,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 2 * (pkmn.form / 2)
  }
})

MultipleForms.register(:DEERLING,{
  "getForm" => proc { |pkmn|
    next pbGetSeason
  }
})

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:KYUREM,{
  "getFormOnEnteringBattle" => proc { |pkmn,wild|
    next pkmn.form+2 if pkmn.form==1 || pkmn.form==2
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next pkmn.form-2 if pkmn.form>=3   # Fused forms stop glowing
  },
  "onSetForm" => proc { |pkmn, form, oldForm|
    case form
    when 0   # Normal
      pkmn.moves.each do |move|
        if [:ICEBURN, :FREEZESHOCK].include?(move.id)
          move.id = :GLACIATE if GameData::Move.exists?(:GLACIATE)
        end
        if [:FUSIONFLARE, :FUSIONBOLT].include?(move.id)
          move.id = :SCARYFACE if GameData::Move.exists?(:SCARYFACE)
        end
      end
    when 1   # White
      pkmn.moves.each do |move|
        move.id = :ICEBURN if move.id == :GLACIATE && GameData::Move.exists?(:ICEBURN)
        move.id = :FUSIONFLARE if move.id == :SCARYFACE && GameData::Move.exists?(:FUSIONFLARE)
      end
    when 2   # Black
      pkmn.moves.each do |move|
        move.id = :FREEZESHOCK if move.id == :GLACIATE && GameData::Move.exists?(:FREEZESHOCK)
        move.id = :FUSIONBOLT if move.id == :SCARYFACE && GameData::Move.exists?(:FUSIONBOLT)
      end
    end
  }
})

MultipleForms.register(:KELDEO,{
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasMove?(:SECRETSWORD) # Resolute Form
    next 0                                # Ordinary Form
  }
})

MultipleForms.register(:MELOETTA,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:GENESECT,{
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:SHOCKDRIVE)
    next 2 if pkmn.hasItem?(:BURNDRIVE)
    next 3 if pkmn.hasItem?(:CHILLDRIVE)
    next 4 if pkmn.hasItem?(:DOUSEDRIVE)
    next 0
  }
})

MultipleForms.register(:GRENINJA,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 1 if pkmn.form == 2 && (pkmn.fainted? || endBattle)
  }
})

MultipleForms.register(:SCATTERBUG,{
  "getFormOnCreation" => proc { |pkmn|
    next $Trainer.secret_ID % 18
  }
})

MultipleForms.copy(:SCATTERBUG,:SPEWPA,:VIVILLON)

MultipleForms.register(:FLABEBE,{
  "getFormOnCreation" => proc { |pkmn|
    next rand(5)
  }
})

MultipleForms.copy(:FLABEBE,:FLOETTE,:FLORGES)

MultipleForms.register(:FURFROU,{
  "getForm" => proc { |pkmn|
    if !pkmn.time_form_set ||
       pbGetTimeNow.to_i > pkmn.time_form_set.to_i + 60 * 60 * 24 * 5   # 5 days
      next 0
    end
  },
  "onSetForm" => proc { |pkmn,form,oldForm|
    pkmn.time_form_set = (form > 0) ? pbGetTimeNow.to_i : nil
  }
})

MultipleForms.register(:ESPURR,{
  "getForm" => proc { |pkmn|
    next pkmn.gender
  }
})

MultipleForms.copy(:ESPURR,:MEOWSTIC)

MultipleForms.register(:AEGISLASH,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:PUMPKABOO,{
  "getFormOnCreation" => proc { |pkmn|
    r = rand(100)
    next 3 if r < 5    # Super Size (5%)
    next 2 if r < 20   # Large (15%)
    next 1 if r < 65   # Average (45%)
    next 0             # Small (35%)
  }
})

MultipleForms.copy(:PUMPKABOO,:GOURGEIST)

MultipleForms.register(:XERNEAS,{
  "getFormOnEnteringBattle" => proc { |pkmn,wild|
    next 1
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:ZYGARDE,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next pkmn.form-2 if pkmn.form>=2 && (pkmn.fainted? || endBattle)
  }
})

MultipleForms.register(:HOOPA,{
  "getForm" => proc { |pkmn|
    if !pkmn.time_form_set ||
       pbGetTimeNow.to_i > pkmn.time_form_set.to_i + 60 * 60 * 24 * 3   # 3 days
      next 0
    end
  },
  "onSetForm" => proc { |pkmn,form,oldForm|
    pkmn.time_form_set = (form>0) ? pbGetTimeNow.to_i : nil
  }
})

MultipleForms.register(:ORICORIO,{
  "getFormOnCreation" => proc { |pkmn|
    next rand(4)   # 0=red, 1=yellow, 2=pink, 3=purple
  },
})

MultipleForms.register(:ROCKRUFF,{
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2   # Own Tempo Rockruff cannot become another form
    next 1 if PBDayNight.isNight?
    next 0
  }
})

MultipleForms.register(:LYCANROC,{
  "getFormOnCreation" => proc { |pkmn|
    next 2 if PBDayNight.isEvening?   # Dusk
    next 1 if PBDayNight.isNight?     # Midnight
    next 0                            # Midday
  },
})

MultipleForms.register(:WISHIWASHI,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:SILVALLY,{
  "getForm" => proc { |pkmn|
    next nil if !pkmn.hasAbility?(:RKSSYSTEM)
    typeArray = {
       1  => [:FIGHTINGMEMORY],
       2  => [:FLYINGMEMORY],
       3  => [:POISONMEMORY],
       4  => [:GROUNDMEMORY],
       5  => [:ROCKMEMORY],
       6  => [:BUGMEMORY],
       7  => [:GHOSTMEMORY],
       8  => [:STEELMEMORY],
       10 => [:FIREMEMORY],
       11 => [:WATERMEMORY],
       12 => [:GRASSMEMORY],
       13 => [:ELECTRICMEMORY],
       14 => [:PSYCHICMEMORY],
       15 => [:ICEMEMORY],
       16 => [:DRAGONMEMORY],
       17 => [:DARKMEMORY],
       18 => [:FAIRYMEMORY]
    }
    ret = 0
    typeArray.each do |f, items|
      for item in items
        next if !pkmn.hasItem?(item)
        ret = f
        break
      end
      break if ret>0
    end
    next ret
  }
})

MultipleForms.register(:MINIOR,{
  "getFormOnCreation" => proc { |pkmn|
    next 7+rand(7)   # Meteor forms are 0-6, Core forms are 7-13
  },
  "getFormOnEnteringBattle" => proc { |pkmn,wild|
    next pkmn.form-7 if pkmn.form>=7 && wild   # Wild Minior always appear in Meteor form
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next pkmn.form+7 if pkmn.form<7
  }
})

MultipleForms.register(:MIMIKYU,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0 if pkmn.fainted? || endBattle
  }
})

MultipleForms.register(:NECROZMA,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    # Fused forms are 1 and 2, Ultra form is 3 or 4 depending on which fusion
    next pkmn.form-2 if pkmn.form>=3 && (pkmn.fainted? || endBattle)
  },
  "onSetForm" => proc { |pkmn, form, oldForm|
    next if form > 2 || oldForm > 2   # Ultra form changes don't affect moveset
    form_moves = [
       :SUNSTEELSTRIKE,   # Dusk Mane (with Solgaleo) (form 1)
       :MOONGEISTBEAM     # Dawn Wings (with Lunala) (form 2)
    ]
    if form == 0
      # Turned back into the base form; forget form-specific moves
      move_index = -1
      pkmn.moves.each_with_index do |move, i|
        next if !form_moves.any? { |m| m == move.id }
        move_index = i
        break
      end
      if move_index >= 0
        move_name = pkmn.moves[move_index].name
        pkmn.forget_move_at_index(move_index)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, move_name))
        pbLearnMove(pkmn, :CONFUSION) if pkmn.numMoves == 0
      end
    else
      # Turned into an alternate form; try learning that form's unique move
      new_move_id = form_moves[form - 1]
      pbLearnMove(pkmn, new_move_id, true)
    end
  }
})

MultipleForms.register(:CRAMORANT, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0
  }
})

MultipleForms.register(:TOXEL, {
  "getFormOnCreation" => proc { |pkmn|
    next 1 if [:LONELY, :BOLD, :RELAXED, :TIMID, :SERIOUS, :MODEST, :MILD,
               :QUIET, :BASHFUL, :CALM, :GENTLE, :CAREFUL].include?(pkmn.nature_id)
    next 0
  }
})

MultipleForms.copy(:TOXEL, :TOXTRICITY)

MultipleForms.register(:SINISTEA, {
  "getFormOnCreation" => proc { |pkmn|
    next 1 if rand(100) < 50
    next 0
  }
})

MultipleForms.copy(:SINISTEA, :POLTEAGEIST)

# A Milcery will always have the same flavor, but it is randomly chosen.
MultipleForms.register(:MILCERY, {
  "getForm" => proc { |pkmn|
    num_flavors = 9
    sweets = [:STRAWBERRYSWEET, :BERRYSWEET, :LOVESWEET, :STARSWEET,
              :CLOVERSWEET, :FLOWERSWEET, :RIBBONSWEET]
    if sweets.include?(pkmn.item_id)
      next sweets.index(pkmn.item_id) + (pkmn.personalID % num_flavors) * sweets.length
    end
    next 0
  }
})

MultipleForms.register(:ALCREMIE, {
  "getFormOnCreation" => proc { |pkmn|
    num_flavors = 9
    num_sweets = 7
    next rand(num_flavors * num_sweets)
  }
})

MultipleForms.register(:EISCUE, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0 if pkmn.fainted? || endBattle
  }
})

MultipleForms.register(:INDEEDEE, {
  "getForm" => proc { |pkmn|
    next pkmn.gender
  }
})

MultipleForms.register(:MORPEKO, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0 if pkmn.fainted? || endBattle
  }
})

MultipleForms.register(:ZACIAN, {
  "getFormOnEnteringBattle" => proc { |pkmn, wild|
    next 1 if pkmn.hasItem?(:RUSTEDSWORD)
    next 0
  },
  "changePokemonOnEnteringBattle" => proc { |battler, pkmn, battle|
    if GameData::Move.exists?(:BEHEMOTHBLADE) && pkmn.hasItem?(:RUSTEDSWORD)
      pkmn.moves.each do |move|
        next if move.id != :IRONHEAD
        move.id = :BEHEMOTHBLADE
        battler.moves.each_with_index do |b_move, i|
          next if b_move.id != :IRONHEAD
          battler.moves[i] = PokeBattle_Move.from_pokemon_move(battle, move)
        end
      end
    end
  },
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0
  },
  "changePokemonOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    pkmn.moves.each { |move| move.id = :IRONHEAD if move.id == :BEHEMOTHBLADE }
  }
})

MultipleForms.register(:ZAMAZENTA, {
  "getFormOnEnteringBattle" => proc { |pkmn, wild|
    next 1 if pkmn.hasItem?(:RUSTEDSHIELD)
    next 0
  },
  "changePokemonOnEnteringBattle" => proc { |battler, pkmn, battle|
    if GameData::Move.exists?(:BEHEMOTHBASH) && pkmn.hasItem?(:RUSTEDSHIELD)
      pkmn.moves.each do |move|
        next if move.id != :IRONHEAD
        move.id = :BEHEMOTHBASH
        battler.moves.each_with_index do |b_move, i|
          next if b_move.id != :IRONHEAD
          battler.moves[i] = PokeBattle_Move.from_pokemon_move(battle, move)
        end
      end
    end
  },
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0
  },
  "changePokemonOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    pkmn.moves.each { |move| move.id = :IRONHEAD if move.id == :BEHEMOTHBASH }
  }
})

MultipleForms.register(:URSHIFU, {
  "getForm" => proc { |pkmn|
    next rand(2)
  }
})

MultipleForms.register(:CALYREX, {
  "onSetForm" => proc { |pkmn, form, oldForm|
    case form
    when 0   # Normal
      if pkmn.hasMove?(:GLACIALLANCE)
        pkmn.forget_move(:GLACIALLANCE)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, GameData::Move.get(:GLACIALLANCE).name))
      end
      if pkmn.hasMove?(:ASTRALBARRAGE)
        pkmn.forget_move(:ASTRALBARRAGE)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, GameData::Move.get(:ASTRALBARRAGE).name))
      end
      pbLearnMove(pkmn, :CONFUSION) if pkmn.numMoves == 0
    when 1   # Ice Rider
      pbLearnMove(pkmn, :GLACIALLANCE, true)
    when 2   # Shadow Rider
      pbLearnMove(pkmn, :ASTRALBARRAGE, true)
    end
  }
})


#===============================================================================
# Regional forms
# These species don't have visually different regional forms, but they need to
# evolve into different forms depending on the location where they evolved.
#===============================================================================

# Alolan forms
MultipleForms.register(:PIKACHU, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      next 1 if map_metadata && map_metadata.town_map_position &&
                map_metadata.town_map_position[0] == 1   # Tiall region
    end
    next 0
  }
})

MultipleForms.copy(:PIKACHU, :EXEGGCUTE, :CUBONE)

# Galarian forms
MultipleForms.register(:KOFFING, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      next 1 if map_metadata && map_metadata.town_map_position &&
                map_metadata.town_map_position[0] == 2   # Galar region
    end
    next 0
  }
})

MultipleForms.copy(:KOFFING, :MIMEJR)
