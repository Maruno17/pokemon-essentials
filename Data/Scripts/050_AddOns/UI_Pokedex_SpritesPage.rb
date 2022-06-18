class PokemonPokedexInfo_Scene
  #todo add indicator to show which one is the main sprite -
  # also maybe add an indicator in main list for when a sprite has available alts

  Y_POSITION_SMALL = 40
  Y_POSITION_BIG = 50

  X_POSITION_PREVIOUS=-20
  X_POSITION_SELECTED=120
  X_POSITION_NEXT=340



  def drawPageForms
    #@selected_index=0

    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    #alts_list= pbGetAvailableAlts
    @selected_index=0
    update_displayed
  end


  def initializeSpritesPage(altsList)
    @selected_index=0
    @sprites["selectedSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["selectedSprite"].x = X_POSITION_SELECTED
    @sprites["selectedSprite"].y = Y_POSITION_BIG
    @sprites["selectedSprite"].z = 999999
    @sprites["selectedSprite"].visible=false
    @sprites["selectedSprite"].zoom_x = 1
    @sprites["selectedSprite"].zoom_y = 1

    @sprites["previousSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["previousSprite"].x = X_POSITION_PREVIOUS
    @sprites["previousSprite"].y = Y_POSITION_SMALL
    @sprites["previousSprite"].visible=false
    @sprites["previousSprite"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["previousSprite"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["nextSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["nextSprite"].x = X_POSITION_NEXT
    @sprites["nextSprite"].y = Y_POSITION_SMALL
    @sprites["nextSprite"].visible=false
    @sprites["nextSprite"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["nextSprite"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["selectedSprite"].z=9999999
    @sprites["previousSprite"].z=9999999
    @sprites["nextSprite"].z=9999999


    @sprites["selectedSprite"].setBitmap(altsList[@selected_index])

    if altsList.size >=2
      @sprites["nextSprite"].setBitmap(altsList[@selected_index+1])
      @sprites["nextSprite"].visible=true
    end

    if altsList.size >=3
      @sprites["previousSprite"].setBitmap(altsList[-1])
      @sprites["previousSprite"].visible=true
    end

  end
  POSSIBLE_ALTS= %w[a b c d e f g h i j k x]

  def pbGetAvailableForms
    return pbGetAvailableAlts
  end

  def update_displayed
    @sprites["selectedSprite"].setBitmap(@available[@selected_index])
    nextIndex=@selected_index+1
    previousIndex= @selected_index-1
    if nextIndex > @available.size-1
      nextIndex = 0
    end
    if previousIndex <0
      previousIndex = @available.size-1
    end
    @sprites["previousSprite"].visible=false if @available.size<=2
    @sprites["nextSprite"].visible=false if @available.size<=1

    @sprites["previousSprite"].setBitmap(@available[previousIndex]) if previousIndex != nextIndex
    @sprites["selectedSprite"].setBitmap(@available[@selected_index])
    @sprites["nextSprite"].setBitmap(@available[nextIndex])

  end

  def pbGetAvailableAlts
    ret = []
    return ret if !@species
    dexNum =getDexNumberForSpecies(@species)
    isFusion = dexNum > NB_POKEMON
    if !isFusion
      ret << Settings::BATTLERS_FOLDER+ dexNum.to_s + "/" + dexNum.to_s + ".png"
      return ret
    end
    body_id = getBodyID(@species)
    head_id=getHeadID(@species,body_id)

    baseFilename = head_id.to_s + "." + body_id.to_s
    baseFilePath = Settings::CUSTOM_BATTLERS_FOLDER + baseFilename + ".png"
    if pbResolveBitmap(baseFilePath)
      ret << baseFilePath
    end
    POSSIBLE_ALTS.each { |alt_letter|
      altFilePath = Settings::CUSTOM_BATTLERS_FOLDER + baseFilename + alt_letter +".png"
      if pbResolveBitmap(altFilePath)
        ret << altFilePath
      end
    }
    ret << Settings::BATTLERS_FOLDER + head_id.to_s + "/" + baseFilename + ".png"
    return ret
  end



  def pbChooseForm
    loop do
      @sprites["uparrow"].visible   = true
      @sprites["downarrow"].visible = true
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @selected_index -=1#(index+@available.length-1)%@available.length
        if @selected_index < 0
          @selected_index = @available.size-1
        end
        update_displayed
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @selected_index +=1#= (index+1)%@available.length
        if @selected_index > @available.size-1
          @selected_index = 0
        end
        update_displayed
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if select_sprite
          @endscene=true
          break
        end
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end

  def is_main_sprite
    return @selected_index == 0
  end



  def select_sprite
    if is_main_sprite
      pbMessage("This sprite is already the displayed sprite")
    else
      if pbConfirmMessage(_INTL('Would you like to use this sprite instead of the current sprite?'))
        swap_main_sprite()
        return true
      end
    end
    return false
  end

  def swap_main_sprite
    begin
    old_main_sprite = @available[0]
    new_main_sprite = @available[@selected_index]

    if  main_sprite_is_non_custom(old_main_sprite)
      new_name_without_ext = File.basename(old_main_sprite, ".png")
      new_name_without_letter=new_name_without_ext.chop
      File.rename(new_main_sprite, Settings::CUSTOM_BATTLERS_FOLDER+new_name_without_letter + ".png")
    end

    if new_main_sprite.start_with?(Settings::BATTLERS_FOLDER)
      new_name_without_ext = File.basename(old_main_sprite, ".png")
      File.rename(old_main_sprite, Settings::CUSTOM_BATTLERS_FOLDER+new_name_without_ext+"x" + ".png")
      return
    end
    File.rename(new_main_sprite, new_main_sprite+"temp")
    File.rename(old_main_sprite, new_main_sprite)
    File.rename(new_main_sprite+"temp", old_main_sprite)
    rescue
      pbMessage("There was an error while swapping the sprites. Please save and restart the game as soon as possible.")
    end
    # code here
  end

  #dégueu, je sais - si le 1er element de la liste finit par une lettre (le 1er element devrait etre considéré comme le main), ça veut dire que le main est non-custom
  def main_sprite_is_non_custom(old_main_sprite)
    return POSSIBLE_ALTS.include?(File.basename(old_main_sprite, ".png")[-1])
  end

end