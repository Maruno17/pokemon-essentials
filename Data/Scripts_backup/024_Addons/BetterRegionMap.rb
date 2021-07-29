


#==============================================================================#
#                              Better Region Map                               #
#                                   by Marin                                   #
#==============================================================================#
#   This region map is smoother and allows you to use region maps larger than  #
#                                   480x320.                                   #
#                                                                              #
#     This resource also comes with a new townmapgen.html to support for the   #
#                                larger images.                                #
#==============================================================================#
#  This region map does NOT support hidden islands such as Berth or Faraday.   #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

def pbBetterRegionMap(region = nil, show_player = true, can_fly = false)
  
  if region == nil 
      mapData = pbGetMetadata($game_map.map_id,MetadataMapPosition)
      if mapData != nil && mapData.length >= 1
        region = mapData[0]
      else
        region = 0
      end
  end
  scene = BetterRegionMap.new(region, show_player, can_fly)
  return scene.flydata
end

class PokemonGlobalMetadata
  attr_writer :regionMapSel
  attr_writer :region
  
  def regionMapSel
    @regionMapSel ||= [0, 0]
    return @regionMapSel
  end
  
  def region
    @region ||= 0
    return @region
  end
end

class BetterRegionMap
  CursorAnimateDelay = 12.0
  CursorMoveSpeed = 4
  TileWidth = 16.0
  TileHeight = 16.0
  MAP_MARGIN = 10

  FlyPointAnimateDelay = 20.0
  
  attr_reader :flydata
  
  def initialize(region = nil, show_player = true, can_fly = false)
    showBlk()
    @region = 0#region || $PokemonGlobal.region
    @show_player = show_player
    @can_fly = can_fly
    @data = load_data('Data/townmap.dat')[@region]
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @mapvp = Viewport.new(16,32,480,320)

    @mapvp.z = 100000
    @viewport2 = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z = 100001
    @sprites = SpriteHash.new
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bmp("Graphics/Pictures/mapbg")
    @window = SpriteHash.new

    @window["map"] = Sprite.new(@mapvp)
    @window["map"].bmp("Graphics/Pictures/#{@data[1]}")


    @sprites["cursor"] = Sprite.new(@viewport2)
    @sprites["cursor"].bmp("Graphics/Pictures/mapCursor")
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height
    @sprites["cursor"].x = 16 + TileWidth * $PokemonGlobal.regionMapSel[0]
    @sprites["cursor"].y = 32 + TileHeight * $PokemonGlobal.regionMapSel[1]
    
    @sprites["cursor"].z = 11
    @sprites["cursor"].ox = (@sprites["cursor"].bmp.height - TileWidth) / 2.0
    @sprites["cursor"].oy = @sprites["cursor"].ox
    
    
    @window["player"] = Sprite.new(@mapvp)
    
    if @show_player
      player = nil
      player = pbGetMetadata($game_map.map_id, MetadataMapPosition) if $game_map
      if player && player[0] == @region
        gender = $Trainer.gender.to_digits(3)
        @window["player"].bmp("Graphics/Pictures/mapPlayer#{gender}")
        @window["player"].x = TileWidth * player[1] + (TileWidth / 2.0)
        @window["player"].y = TileHeight * player[2] + (TileHeight / 2.0)
        @window["player"].center_origins
      end
    end
    @sprites["txt"] = TextSprite.new(@viewport)
    @sprites["arrowLeft"] = Sprite.new(@viewport2)
    @sprites["arrowLeft"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowLeft"].mirror = true
    @sprites["arrowLeft"].center_origins
    @sprites["arrowLeft"].xyz = 12, Graphics.height / 2
    @sprites["arrowRight"] = Sprite.new(@viewport2)
    @sprites["arrowRight"].bmp("Graphics/Pictures/mapArrowRight")
    @sprites["arrowRight"].center_origins
    @sprites["arrowRight"].xyz = Graphics.width - 12, Graphics.height / 2
    @sprites["arrowUp"] = Sprite.new(@viewport2)
    @sprites["arrowUp"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowUp"].angle = 180
    @sprites["arrowUp"].center_origins
    @sprites["arrowUp"].xyz = Graphics.width / 2, 24
    @sprites["arrowDown"] = Sprite.new(@viewport2)
    @sprites["arrowDown"].bmp("Graphics/Pictures/mapArrowDown")
    @sprites["arrowDown"].center_origins
    @sprites["arrowDown"].xyz = Graphics.width / 2, Graphics.height - 24
    update_text
    @dirs = []
    @mdirs = []
    @i = 0
    
    if can_fly
      @spots = {}
      n = 0
      for x in 0...(@window["map"].bmp.width / TileWidth)
        for y in 0...(@window["map"].bmp.height / TileHeight)
          healspot = pbGetHealingSpot(x,y)
          if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
            @window["point#{n}"] = Sprite.new(@mapvp)
            @window["point#{n}"].bmp("Graphics/Pictures/mapFly")
            @window["point#{n}"].src_rect.width = @window["point#{n}"].bmp.height
            @window["point#{n}"].x = TileWidth * x + (TileWidth / 2)
            @window["point#{n}"].y = TileHeight * y + (TileHeight / 2)
            @window["point#{n}"].oy = @window["point#{n}"].bmp.height / 2.0
            @window["point#{n}"].ox = @window["point#{n}"].oy
            @spots[[x, y]] = healspot
            n += 1
          end
        end
      end
    end
    
    initWindowPosition(region)

    #if region == nil
    #end
      
    hideBlk { update(false) }
    main
  end
  
  def initWindowPosition(region=0)
    x, y = 0
    if region == 2    #sevii islands
      x=-250
      y=-200
    elsif region == 1 #johto
      x=0
      y=0  
    else              #kanto
      x=-250
      y=0    
    end
    updateWindowPosition(x,y)
  end

   
  #@hor_count = position du pointer
  def updateWindowPosition(x,y)
    @window.x = x
    @window.y = y
    
   # @hor_count = 0#x
   # @ver_count = 0#y
    
    @sprites["cursor"].x = 16 + TileWidth * $PokemonGlobal.regionMapSel[0] + @window.x 
    @sprites["cursor"].y = 32 + TileWidth * $PokemonGlobal.regionMapSel[1] + @window.y 

    
  end
  
  def pbGetHealingSpot(x,y)
    return nil if !@data[2]
    for loc in @data[2]
      if loc[0] == x && loc[1] == y
        if !loc[4] || !loc[5] || !loc[6]
          return nil
        else
          return [loc[4],loc[5],loc[6]]
        end
      end
    end
    return nil
  end
  
  def main
    loop do
      update
      if Input.press?(Input::RIGHT) && ![4,6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x < 480
          $PokemonGlobal.regionMapSel[0] += 1
          @sx = @sprites["cursor"].x
          @dirs << 6
        elsif @window.x > -1 * (@window["map"].bmp.width - 480)
          $PokemonGlobal.regionMapSel[0] += 1
          @mx = @window.x
          @mdirs << 6
        end
      end
      if Input.press?(Input::LEFT) && ![4,6].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].x > 16
          $PokemonGlobal.regionMapSel[0] -= 1
          @sx = @sprites["cursor"].x
          @dirs << 4
        elsif @window.x < 0
          $PokemonGlobal.regionMapSel[0] -= 1
          @mx = @window.x
          @mdirs << 4
        end
      end
      if Input.press?(Input::DOWN) && ![2,8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y <= 320
          $PokemonGlobal.regionMapSel[1] += 1
          @sy = @sprites["cursor"].y
          @dirs << 2
          
        elsif @window.y > -1 * (@window["map"].bmp.height - 320)
          $PokemonGlobal.regionMapSel[1] += 1
          @my = @window.y
          @mdirs << 2
        end
      end
      if Input.press?(Input::UP) && ![2,8].any? { |e| @dirs.include?(e) || @mdirs.include?(e) }
        if @sprites["cursor"].y > 32
          $PokemonGlobal.regionMapSel[1] -= 1
          @sy = @sprites["cursor"].y
          @dirs << 8
        elsif @window.y < 0
          $PokemonGlobal.regionMapSel[1] -= 1
          @my = @window.y
          @mdirs << 8
        end
      end
      if Input.trigger?(Input::C)
        x, y = $PokemonGlobal.regionMapSel
        if @spots && @spots[[x, y]]
          @flydata = @spots[[x, y]]
          break
        end
      end
      break if Input.trigger?(Input::B)
    end
    dispose
  end
  
  def update(update_gfx = true)
    @sprites["arrowLeft"].visible = @window.x < 0 -MAP_MARGIN
    @sprites["arrowRight"].visible = @window.x > -1 * (@window["map"].bmp.width - 480) +MAP_MARGIN
    @sprites["arrowUp"].visible = @window.y < 0 - MAP_MARGIN
    @sprites["arrowDown"].visible = @window.y > -1 * (@window["map"].bmp.height - 320) +MAP_MARGIN
    
    if update_gfx
      Graphics.update
      Input.update
    end
    
    @i += 1
    if @i % CursorAnimateDelay == 0
      @sprites["cursor"].src_rect.x += @sprites["cursor"].src_rect.width
      @sprites["cursor"].src_rect.x = 0 if @sprites["cursor"].src_rect.x >= @sprites["cursor"].bmp.width
    end
    if @i % FlyPointAnimateDelay == 0
      @window.keys.each do |e|
        next unless e.to_s.starts_with?("point")
        @window[e].src_rect.x += @window[e].src_rect.width
        @window[e].src_rect.x = 0 if @window[e].src_rect.x >= @window[e].bmp.width
      end
    end
    
    if @i % 2 == 0
      case @i % 32
      when 0...8
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      when 8...24
        @sprites["arrowLeft"].x += 1
        @sprites["arrowRight"].x -= 1
        @sprites["arrowUp"].y += 1
        @sprites["arrowDown"].y -= 1
      when 24...32
        @sprites["arrowLeft"].x -= 1
        @sprites["arrowRight"].x += 1
        @sprites["arrowUp"].y -= 1
        @sprites["arrowDown"].y += 1
      end
    end
    
    # Cursor movement
    if @dirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(6)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].x = @sx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @dirs.delete(4)
        @hor_count = nil
        @sx = nil
      end
    end
    if @dirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(8)
        @ver_count = nil
        @sy = nil
      end
    end
    if @dirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @sprites["cursor"].y = @sy + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @dirs.delete(2)
        @ver_count = nil
        @sy = nil
      end
    end
    
    # Map movement
    if @mdirs.include?(6)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx - (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(6)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(4)
      @hor_count ||= 0
      @hor_count += 1
      update_text if @hor_count == (CursorMoveSpeed / 2.0).round
      @window.x = @mx + (TileWidth / CursorMoveSpeed.to_f) * @hor_count
      if @hor_count == CursorMoveSpeed
        @mdirs.delete(4)
        @hor_count = nil
        @mx = nil
      end
    end
    if @mdirs.include?(8)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my + (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(8)
        @ver_count = nil
        @my = nil
      end
    end
    if @mdirs.include?(2)
      @ver_count ||= 0
      @ver_count += 1
      update_text if @ver_count == (CursorMoveSpeed / 2.0).round
      @window.y = @my - (TileHeight / CursorMoveSpeed.to_f) * @ver_count
      if @ver_count == CursorMoveSpeed
        @mdirs.delete(2)
        @ver_count = nil
        @my = nil
      end
    end
  end
  
  def update_text
    location = @data[2].find do |e|
      e[0] == $PokemonGlobal.regionMapSel[0] &&
      e[1] == $PokemonGlobal.regionMapSel[1]
    end
    text = ""
    text = location[2] if location
    poi = ""
    poi = location[3] if location && location[3]
    @sprites["txt"].draw([
        [pbGetMessage(MessageTypes::RegionNames,@region), 16, 0, 0,
            Color.new(255,255,255), Color.new(0,0,0)],
        [text, 16, 354, 0, Color.new(255,255,255), Color.new(0,0,0)],
        [poi, 496, 354, 1, Color.new(255,255,255), Color.new(0,0,0)]
    ], true)
  end
  
  def dispose
    showBlk { update(false) }
    @sprites.dispose
    @window.dispose
    @viewport.dispose
    @viewport2.dispose
    @mapvp.dispose
    hideBlk
    Input.update
  end
end

#==============================================================================#
# Overwrites some old methods to use the new region map                        #
#==============================================================================#

#ItemHandlers::UseInField.add(:TOWNMAP,proc{|item|
#   pbBetterRegionMap
#   next 1
#})

class PokemonPartyScreen
  def pbPokemonScreen
    @scene.pbStartScene(@party,
       (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false, -1, 1)
      break if (pkmnid.is_a?(Numeric) && pkmnid < 0) || (pkmnid.is_a?(Array) && pkmnid[1] < 0)
      if pkmnid.is_a?(Array) && pkmnid[0] == 1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true, -1, 2)
        if pkmnid >= 0 && pkmnid != oldpkmnid
          pbSwitch(oldpkmnid, pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdMoves   = [-1,-1,-1,-1]
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      for i in 0...pkmn.moves.length
        move = pkmn.moves[i]
        # Check for hidden moves and add any that were found
        if !pkmn.egg? && (isConst?(move.id,PBMoves,:MILKDRINK) ||
                          isConst?(move.id,PBMoves,:SOFTBOILED) ||
                          HiddenMoveHandlers.hasHandler(move.id))
          commands[cmdMoves[i] = commands.length] = [PBMoves.getName(move.id),1]
        end
      end
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
        end
      end
      commands[commands.length]                   = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      for i in 0...4
        if cmdMoves[i] >= 0 && command == cmdMoves[i]
          havecommand = true
          if isConst?(pkmn.moves[i].id,PBMoves,:SOFTBOILED) ||
             isConst?(pkmn.moves[i].id,PBMoves,:MILKDRINK)
            amt = [(pkmn.totalhp/5).floor,1].max
            if pkmn.hp <= amt
              pbDisplay(_INTL("Not enough HP..."))
              break
            end
            @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            oldpkmnid = pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid = @scene.pbChoosePokemon(true, pkmnid)
              break if pkmnid < 0
              newpkmn = @party[pkmnid]
              movename = PBMoves.getName(pkmn.moves[i].id)
              if pkmnid == oldpkmnid
                pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,movename))
              elsif newpkmn.egg?
                pbDisplay(_INTL("{1} can't be used on an Egg!",movename))
              elsif newpkmn.hp == 0 || newpkmn.hp == newpkmn.totalhp
                pbDisplay(_INTL("{1} can't be used on that Pokémon.",movename))
              else
                pkmn.hp -= amt
                hpgain = pbItemRestoreHP(newpkmn,amt)
                @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
                pbRefresh
              end
              break if pkmn.hp <= amt
            end
            @scene.pbSelect(oldpkmnid)
            pbRefresh
            break
          elsif Kernel.pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
            if Kernel.pbConfirmUseHiddenMove(pkmn,pkmn.moves[i].id)
              @scene.pbEndScene
              if isConst?(pkmn.moves[i].id,PBMoves,:FLY)
                ###############################################
                ret = pbBetterRegionMap(nil, true, true)
                if ret
                  $PokemonTemp.flydata = ret
                  return [pkmn,pkmn.moves[i].id]
                end
                @scene.pbStartScene(@party,
                   (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
                break
                ###############################################
              end
              return [pkmn,pkmn.moves[i].id]
            end
          else
            break
          end
        end
      end
      next if havecommand
      if cmdSummary >= 0 && command == cmdSummary
        @scene.pbSummary(pkmnid)
      elsif cmdDebug >= 0 && command == cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch >= 0 && command == cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid >= 0 && pkmnid != oldpkmnid
          pbSwitch(oldpkmnid, pkmnid)
        end
      elsif cmdMail >= 0 && command == cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0 # Read
          pbFadeOutIn(99999){ pbDisplayMail(pkmn.mail,pkmn) }
        when 1 # Take
          if pbTakeItemFromPokemon(pkmn, self)
            pbRefreshSingle(pkmnid)
          end
        end
      elsif cmdItem >= 0 && command == cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? && !pbIsMail?(pkmn.item)
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem >= 0 && command == cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag, pkmn)
          if item>0
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem >= 0 && command == cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag)
          if item > 0
            if pbGiveItemToPokemon(item, pkmn, self, pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem >= 0 && command == cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn, self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem >= 0 && command == cmdMoveItem   # Move
          item = pkmn.item
          itemname = PBItems.getName(item)
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true, pkmnid)
            break if pkmnid < 0
            newpkmn = @party[pkmnid]
            if pkmnid == oldpkmnid
              break
            elsif newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.setItem(item)
              pkmn.setItem(0)
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif pbIsMail?(newpkmn.item)
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = PBItems.getName(newitem)
              if isConst?(newitem,PBItems,:LEFTOVERS)
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif ['a','e','i','o','u'].include?(newitemname[0,1].downcase)
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.setItem(item)
                pkmn.setItem(newitem)
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end  
end


class PokemonReadyMenu
  def pbStartReadyMenu(moves,items)
    commands = [[], []] # Moves, items
    for i in moves
      commands[0].push([i[0], PBMoves.getName(i[0]), true, i[1]])
    end
    commands[0].sort! { |a,b| a[1] <=> b[1] }
    for i in items
      commands[1].push([i, PBItems.getName(i), false])
    end
    commands[1].sort! { |a,b| a[1] <=> b[1] }
    
    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      if command == -1
        break
      else
        if command[0] == 0 # Use a move
          move = commands[0][command[1]][0]
          user = $Trainer.party[commands[0][command[1]][3]]
          if isConst?(move,PBMoves,:FLY)
            ###############################################
            pbHideMenu
            ret = pbBetterRegionMap(nil, true, true)
            pbShowMenu unless ret
            ###############################################
            if ret
              $PokemonTemp.flydata = ret
              $game_temp.in_menu = false
              Kernel.pbUseHiddenMove(user,move)
              break
            end
          else
            pbHideMenu
            if Kernel.pbConfirmUseHiddenMove(user,move)
              $game_temp.in_menu = false
              Kernel.pbUseHiddenMove(user,move)
              break
            else
              pbShowMenu
            end
          end
        else # Use an item
          item = commands[1][command[1]][0]
          pbHideMenu
          if ItemHandlers.triggerConfirmUseInField(item)
            break if Kernel.pbUseKeyItemInField(item)
          end
        end
        pbShowMenu
      end
    end
    @scene.pbEndScene
  end
end
