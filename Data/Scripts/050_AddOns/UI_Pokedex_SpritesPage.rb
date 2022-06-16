class PokemonPokedexInfo_Scene
  #todo add indicator to show which one is the main sprite
  # also maybe add an indicator in main list for when a sprite has available alts

  X_POSITION_SMALL = 175
  X_POSITION_BIG = 125
  Y_POSITION_PREVIOUS=0
  Y_POSITION_SELECTED=50
  Y_POSITION_NEXT=200


  def drawPageForms
    @selected_index=0

    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)

    #alts_list= pbGetAvailableAlts
    initializeSpritesPage(@available)
  end

  def initializeSpritesPage(altsList)
    @sprites["selectedSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["selectedSprite"].x = X_POSITION_BIG
    @sprites["selectedSprite"].y = Y_POSITION_SELECTED
    @sprites["selectedSprite"].z = 999999
    @sprites["selectedSprite"].visible=true
    @sprites["selectedSprite"].zoom_x = 1
    @sprites["selectedSprite"].zoom_y = 1

    @sprites["previousSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["previousSprite"].x = X_POSITION_SMALL
    @sprites["previousSprite"].y = Y_POSITION_PREVIOUS
    @sprites["previousSprite"].visible=false
    @sprites["previousSprite"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["previousSprite"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["nextSprite"] = IconSprite.new(0,0,@viewport)
    @sprites["nextSprite"].x = X_POSITION_SMALL
    @sprites["nextSprite"].y = Y_POSITION_NEXT
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
  POSSIBLE_ALTS=["a","b","c","d","e","f","g","h","i","j","k", 'l',"m",
                 "n","o","p", "q", "r","s","t","u","v","w","x","y","z"]

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

    @sprites["previousSprite"].setBitmap(@available[previousIndex])
    @sprites["selectedSprite"].setBitmap(@available[@selected_index])
    @sprites["nextSprite"].setBitmap(@available[nextIndex])

  end

  def pbGetAvailableAlts
    ret = []
    return ret if !@species
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
      else
        break #don't want to loop through each letter for nothing
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
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        @selected_index -=1#(index+@available.length-1)%@available.length
        if @selected_index < 0
          @selected_index = @available.size-1
        end
        update_displayed
      elsif Input.trigger?(Input::DOWN)
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
    #todo
    # ajouter une mecanique pour si le user select un generated sprite a la place du custom
    # sinon on rename directement les 2 fichiers
    #
    old_main_sprite = @available[0]
    new_main_sprite = @available[@selected_index]
    # code here
  end



end