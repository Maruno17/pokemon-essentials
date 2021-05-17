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

MultipleForms.register(:ROTOM,{
  "onSetForm" => proc { |pkmn, form, oldForm|
    form_moves = [
       :OVERHEAT,    # Heat, Microwave
       :HYDROPUMP,   # Wash, Washing Machine
       :BLIZZARD,    # Frost, Refrigerator
       :AIRSLASH,    # Fan
       :LEAFSTORM    # Mow, Lawnmower
    ]
    move_index = -1
    pkmn.moves.each_with_index do |move, i|
      next if !form_moves.any? { |m| m == move.id }
      move_index = i
      break
    end
    if form == 0
      # Turned back into the base form; forget form-specific moves
      if move_index >= 0
        move_name = pkmn.moves[move_index].name
        pkmn.forget_move_at_index(move_index)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, move_name))
        pbLearnMove(:THUNDERSHOCK) if pkmn.numMoves == 0
      end
    else
      # Turned into an alternate form; try learning that form's unique move
      new_move_id = form_moves[form - 1]
      if move_index >= 0
        # Knows another form's unique move; replace it
        old_move_name = pkmn.moves[move_index].name
        if GameData::Move.exists?(new_move_id)
          pkmn.moves[move_index].id = new_move_id
          new_move_name = pkmn.moves[move_index].name
          pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
          pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1", pkmn.name, old_move_name))
          pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]", pkmn.name, new_move_name))
        else
          pkmn.forget_move_at_index(move_index)
          pbMessage(_INTL("{1} forgot {2}...", pkmn.name, old_move_name))
          pbLearnMove(:THUNDERSHOCK) if pkmn.numMoves == 0
        end
      else
        # Just try to learn this form's unique move
        pbLearnMove(pkmn, new_move_id, true)
      end
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
    next 0
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
    if r<5;     next 3   # Super Size (5%)
    elsif r<20; next 2   # Large (15%)
    elsif r<65; next 1   # Average (45%)
    end
    next 0               # Small (35%)
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
        pbLearnMove(:CONFUSION) if pkmn.numMoves == 0
      end
    else
      # Turned into an alternate form; try learning that form's unique move
      new_move_id = form_moves[form - 1]
      pbLearnMove(pkmn, new_move_id, true)
    end
  }
})

#===============================================================================
# Alolan forms
#===============================================================================

# These species don't have visually different Alolan forms, but they need to
# evolve into different forms depending on the location where they evolved.
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
