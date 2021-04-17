#===============================================================================
#
#===============================================================================
class Window_CharacterEntry < Window_DrawableCommand
  XSIZE=13
  YSIZE=4

  def initialize(charset,viewport=nil)
    @viewport=viewport
    @charset=charset
    @othercharset=""
    super(0,96,480,192)
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    self.columns=XSIZE
    refresh
  end

  def setOtherCharset(value)
    @othercharset=value.clone
    refresh
  end

  def setCharset(value)
    @charset=value.clone
    refresh
  end

  def character
    if self.index<0 || self.index>=@charset.length
      return ""
    else
      return @charset[self.index]
    end
  end

  def command
    return -1 if self.index==@charset.length
    return -2 if self.index==@charset.length+1
    return -3 if self.index==@charset.length+2
    return self.index
  end

  def itemCount
    return @charset.length+3
  end

  def drawItem(index,_count,rect)
    rect=drawCursor(index,rect)
    if index==@charset.length # -1
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,"[ ]",
         self.baseColor,self.shadowColor)
    elsif index==@charset.length+1 # -2
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@othercharset,
         self.baseColor,self.shadowColor)
    elsif index==@charset.length+2 # -3
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,_INTL("OK"),
         self.baseColor,self.shadowColor)
    else
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@charset[index],
         self.baseColor,self.shadowColor)
    end
  end
end



#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class PokemonEntryScene
  @@Characters=[
     [("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").scan(/./),"[*]"],
     [("0123456789   !@\#$%^&*()   ~`-_+={}[]   :;'\"<>,.?/   ").scan(/./),"[A]"],
  ]
  USEKEYBOARD=true

  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    if USEKEYBOARD
      @sprites["entry"]=Window_TextEntry_Keyboard.new(initialText,
         0,0,400-112,96,helptext,true)
      Input.text_input = true
    else
      @sprites["entry"]=Window_TextEntry.new(initialText,0,0,400,96,helptext,true)
    end
    @sprites["entry"].x=(Graphics.width/2)-(@sprites["entry"].width/2)+32
    @sprites["entry"].viewport=@viewport
    @sprites["entry"].visible=true
    @minlength=minlength
    @maxlength=maxlength
    @symtype=0
    @sprites["entry"].maxlength=maxlength
    if !USEKEYBOARD
      @sprites["entry2"]=Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport=@viewport
      @sprites["entry2"].visible=true
      @sprites["entry2"].x=(Graphics.width/2)-(@sprites["entry2"].width/2)
    end
    if minlength==0
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
         _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
         32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    else
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
         _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
         32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    end
    @sprites["helpwindow"].letterbyletter=false
    @sprites["helpwindow"].viewport=@viewport
    @sprites["helpwindow"].visible=USEKEYBOARD
    @sprites["helpwindow"].baseColor=Color.new(16,24,32)
    @sprites["helpwindow"].shadowColor=Color.new(168,184,184)
    addBackgroundPlane(@sprites,"background","Naming/bg_2",@viewport)
    case subject
    when 1   # Player
      meta=GameData::Metadata.get_player($Trainer.character_ID)
      if meta
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        filename=pbGetPlayerCharset(meta,1,nil,true)
        @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 38*2 - charheight/4
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        @sprites["subject"]=PokemonIconSprite.new(pokemon,@viewport)
        @sprites["subject"].setOffset(PictureOrigin::Center)
        @sprites["subject"].x=88
        @sprites["subject"].y=54
        @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
        @sprites["gender"].x=430
        @sprites["gender"].y=54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos=[]
        if pokemon.male?
          textpos.push([_INTL("♂"),0,-6,false,Color.new(0,128,248),Color.new(168,184,184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"),0,-6,false,Color.new(248,24,24),Color.new(168,184,184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap,textpos)
      end
    when 3   # NPC
      @sprites["shadow"]=IconSprite.new(0,0,@viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x=33*2
      @sprites["shadow"].y=32*2
      @sprites["subject"]=TrainerWalkingCharSprite.new(pokemon.to_s,@viewport)
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 38*2 - charheight/4
    when 4   # Storage box
      @sprites["subject"]=TrainerWalkingCharSprite.new(nil,@viewport)
      @sprites["subject"].altcharset="Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed=4
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 26*2 - charheight/2
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEntry1
    ret=""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE) && @minlength==0
        ret=""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length>=@minlength
        ret=@sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"].update if @sprites["subject"]
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret=""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"].update if @sprites["subject"]
      if Input.trigger?(Input::USE)
        index=@sprites["entry2"].command
        if index==-3 # Confirm text
          ret=@sprites["entry"].text
          if ret.length<@minlength || ret.length>@maxlength
            pbPlayBuzzerSE()
          else
            pbPlayDecisionSE()
            break
          end
        elsif index==-1 # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        elsif index==-2 # Change character set
          pbPlayDecisionSE()
          @symtype+=1
          @symtype=0 if @symtype>=@@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end



#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class PokemonEntryScene2
  @@Characters = [
     [("ABCDEFGHIJ ,."+"KLMNOPQRST '-"+"UVWXYZ     ♂♀"+"             "+"0123456789   ").scan(/./),_INTL("UPPER")],
     [("abcdefghij ,."+"klmnopqrst '-"+"uvwxyz     ♂♀"+"             "+"0123456789   ").scan(/./),_INTL("lower")],
     [(",.:;!?   ♂♀  "+"\"'()<>[]     "+"~@#%*&$      "+"+-=^_/\\|     "+"             ").scan(/./),_INTL("other")],
  ]
  ROWS    = 13
  COLUMNS = 5
  MODE1   = -5
  MODE2   = -4
  MODE3   = -3
  BACK    = -2
  OK      = -1

  class NameEntryCursor
    def initialize(viewport)
      @sprite = SpriteWrapper.new(viewport)
      @cursortype = 0
      @cursor1 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_1")
      @cursor2 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_2")
      @cursor3 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_3")
      @cursorPos = 0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos = value
    end

    def updateCursorPos
      value=@cursorPos
      if value==PokemonEntryScene2::MODE1   # Upper case
        @sprite.x=48
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::MODE2   # Lower case
        @sprite.x=112
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::MODE3   # Other symbols
        @sprite.x=176
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::BACK   # Back
        @sprite.x=312
        @sprite.y=120
        @cursortype=2
      elsif value==PokemonEntryScene2::OK   # OK
        @sprite.x=392
        @sprite.y=120
        @cursortype=2
      elsif value>=0
        @sprite.x=52+32*(value%PokemonEntryScene2::ROWS)
        @sprite.y=180+38*(value/PokemonEntryScene2::ROWS)
        @cursortype=0
      end
    end

    def visible=(value)
      @sprite.visible=value
    end

    def visible
      @sprite.visible
    end

    def color=(value)
      @sprite.color=value
    end

    def color
      @sprite.color
    end

    def disposed?
      @sprite.disposed?
    end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      updateCursorPos
      case @cursortype
      when 0 then @sprite.bitmap=@cursor1.bitmap
      when 1 then @sprite.bitmap=@cursor2.bitmap
      when 2 then @sprite.bitmap=@cursor3.bitmap
      end
    end

    def update
      updateInternal
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @sprite.dispose
    end
  end



  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @helptext=helptext
    @helper=CharacterEntryHelper.new(initialText)
    @bitmaps=[
       AnimatedBitmap.new("Graphics/Pictures/Naming/overlay_tab_1"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/overlay_tab_2"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/overlay_tab_3")
    ]
    @bitmaps[3]=@bitmaps[0].bitmap.clone
    @bitmaps[4]=@bitmaps[1].bitmap.clone
    @bitmaps[5]=@bitmaps[2].bitmap.clone
    for i in 0...3
      pos=0
      pbSetSystemFont(@bitmaps[i+3])
      textPos=[]
      for y in 0...COLUMNS
        for x in 0...ROWS
          textPos.push([@@Characters[i][0][pos],44+x*32,12+y*38,2,
             Color.new(16,24,32), Color.new(160,160,160)])
          pos+=1
        end
      end
      pbDrawTextPositions(@bitmaps[i+3],textPos)
    end
    @bitmaps[6]=BitmapWrapper.new(24,6)
    @bitmaps[6].fill_rect(2,2,22,4,Color.new(168,184,184))
    @bitmaps[6].fill_rect(0,0,22,4,Color.new(16,24,32))
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Naming/bg")
    case subject
    when 1   # Player
      meta=GameData::Metadata.get_player($Trainer.character_ID)
      if meta
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        filename=pbGetPlayerCharset(meta,1,nil,true)
        @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 38*2 - charheight/4
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        @sprites["subject"]=PokemonIconSprite.new(pokemon,@viewport)
        @sprites["subject"].setOffset(PictureOrigin::Center)
        @sprites["subject"].x=88
        @sprites["subject"].y=54
        @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
        @sprites["gender"].x=430
        @sprites["gender"].y=54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos=[]
        if pokemon.male?
          textpos.push([_INTL("♂"),0,-6,false,Color.new(0,128,248),Color.new(168,184,184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"),0,-6,false,Color.new(248,24,24),Color.new(168,184,184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap,textpos)
      end
    when 3   # NPC
      @sprites["shadow"]=IconSprite.new(0,0,@viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x=33*2
      @sprites["shadow"].y=32*2
      @sprites["subject"]=TrainerWalkingCharSprite.new(pokemon.to_s,@viewport)
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 38*2 - charheight/4
    when 4   # Storage box
      @sprites["subject"]=TrainerWalkingCharSprite.new(nil,@viewport)
      @sprites["subject"].altcharset="Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed=4
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 26*2 - charheight/2
    end
    @sprites["bgoverlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbDoUpdateOverlay
    @blanks=[]
    @mode=0
    @minlength=minlength
    @maxlength=maxlength
    @maxlength.times { |i|
      @sprites["blank#{i}"]=SpriteWrapper.new(@viewport)
      @sprites["blank#{i}"].bitmap=@bitmaps[6]
      @sprites["blank#{i}"].x=160+24*i
      @blanks[i]=0
    }
    @sprites["bottomtab"]=SpriteWrapper.new(@viewport) # Current tab
    @sprites["bottomtab"].x=22
    @sprites["bottomtab"].y=162
    @sprites["bottomtab"].bitmap=@bitmaps[0+3]
    @sprites["toptab"]=SpriteWrapper.new(@viewport) # Next tab
    @sprites["toptab"].x=22-504
    @sprites["toptab"].y=162
    @sprites["toptab"].bitmap=@bitmaps[1+3]
    @sprites["controls"]=IconSprite.new(0,0,@viewport)
    @sprites["controls"].setBitmap(_INTL("Graphics/Pictures/Naming/overlay_controls"))
    @sprites["controls"].x=16
    @sprites["controls"].y=96
    @init=true
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"]=NameEntryCursor.new(@viewport)
    @cursorpos=0
    @refreshOverlay=true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateOverlay
    @refreshOverlay=true
  end

  def pbDoUpdateOverlay2
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    modeIcon=[[_INTL("Graphics/Pictures/Naming/icon_mode"),48+@mode*64,120,@mode*60,0,60,44]]
    pbDrawImagePositions(overlay,modeIcon)
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay=false
    bgoverlay=@sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions=[
       [@helptext,160,6,false,Color.new(16,24,32),Color.new(168,184,184)]
    ]
    chars=@helper.textChars
    x=166
    for ch in chars
      textPositions.push([ch,x,42,false,Color.new(16,24,32),Color.new(168,184,184)])
      x+=24
    end
    pbDrawTextPositions(bgoverlay,textPositions)
  end

  def pbChangeTab(newtab=@mode+1)
    pbSEPlay("GUI naming tab swap start")
    @sprites["cursor"].visible = false
    @sprites["toptab"].bitmap = @bitmaps[(newtab%3)+3]
    # Move bottom (old) tab down off the screen, and move top (new) tab right
    # onto the screen
    deltaX = 48*20/Graphics.frame_rate
    deltaY = 24*20/Graphics.frame_rate
    loop do
      if @sprites["bottomtab"].y<414
        @sprites["bottomtab"].y += deltaY
        @sprites["bottomtab"].y = 414 if @sprites["bottomtab"].y>414
      end
      if @sprites["toptab"].x<22
        @sprites["toptab"].x += deltaX
        @sprites["toptab"].x = 22 if @sprites["toptab"].x>22
      end
      Graphics.update
      Input.update
      pbUpdate
      break if @sprites["toptab"].x>=22 && @sprites["bottomtab"].y>=414
    end
    # Swap top and bottom tab around
    @sprites["toptab"].x, @sprites["bottomtab"].x = @sprites["bottomtab"].x, @sprites["toptab"].x
    @sprites["toptab"].y, @sprites["bottomtab"].y = @sprites["bottomtab"].y, @sprites["toptab"].y
    @sprites["toptab"].bitmap, @sprites["bottomtab"].bitmap = @sprites["bottomtab"].bitmap, @sprites["toptab"].bitmap
    Graphics.update
    Input.update
    pbUpdate
    # Set the current mode
    @mode = (newtab)%3
    # Set the top tab up to be the next tab
    newtab = @bitmaps[((@mode+1)%3)+3]
    @sprites["cursor"].visible = true
    @sprites["toptab"].bitmap = newtab
    @sprites["toptab"].x = 22-504
    @sprites["toptab"].y = 162
    pbSEPlay("GUI naming tab swap end")
    pbDoUpdateOverlay2
  end

  def pbUpdate
    for i in 0...3
      @bitmaps[i].update
    end
    if @init || Graphics.frame_count%5==0
      @init = false
      cursorpos = @helper.cursor
      cursorpos = @maxlength-1 if cursorpos>=@maxlength
      cursorpos = 0 if cursorpos<0
      @maxlength.times { |i|
        @blanks[i] = (i==cursorpos) ? 1 : 0
        @sprites["blank#{i}"].y = [78,82][@blanks[i]]
      }
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m>=ROWS-1
    chset=@@Characters[@mode][0]
    return (
       chset[m]==" " &&
       chset[m+((ROWS-1))]==" " &&
       chset[m+((ROWS-1)*2)]==" " &&
       chset[m+((ROWS-1)*3)]==" "
    )
  end

  def wrapmod(x,y)
    result=x%y
    result+=y if result<0
    return result
  end

  def pbMoveCursor
    oldcursor=@cursorpos
    cursordiv=@cursorpos/ROWS
    cursormod=@cursorpos%ROWS
    cursororigin=@cursorpos-cursormod
    if Input.repeat?(Input::LEFT)
      if @cursorpos<0   # Controls
        @cursorpos-=1
        @cursorpos=OK if @cursorpos<MODE1
      else
        begin
          cursormod=wrapmod((cursormod-1),ROWS)
          @cursorpos=cursororigin+cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos<0   # Controls
        @cursorpos+=1
        @cursorpos=MODE1 if @cursorpos>OK
      else
        begin
          cursormod=wrapmod((cursormod+1),ROWS)
          @cursorpos=cursororigin+cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos<0         # Controls
        case @cursorpos
        when MODE1 then @cursorpos = ROWS*(COLUMNS-1)
        when MODE2 then @cursorpos = ROWS*(COLUMNS-1)+2
        when MODE3 then @cursorpos = ROWS*(COLUMNS-1)+4
        when BACK  then @cursorpos = ROWS*(COLUMNS-1)+8
        when OK    then @cursorpos = ROWS*(COLUMNS-1)+11
        end
      elsif @cursorpos<ROWS   # Top row of letters
        case @cursorpos
        when 0, 1        then @cursorpos = MODE1
        when 2, 3        then @cursorpos = MODE2
        when 4, 5, 6     then @cursorpos = MODE3
        when 7, 8, 9, 10 then @cursorpos = BACK
        when 11, 12      then @cursorpos = OK
        end
      else
        cursordiv=wrapmod((cursordiv-1),COLUMNS)
        @cursorpos=(cursordiv*ROWS)+cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos<0                      # Controls
        case @cursorpos
        when MODE1 then @cursorpos = 0
        when MODE2 then @cursorpos = 2
        when MODE3 then @cursorpos = 4
        when BACK  then @cursorpos = 8
        when OK    then @cursorpos = 11
        end
      elsif @cursorpos>=ROWS*(COLUMNS-1)   # Bottom row of letters
        case @cursorpos
        when ROWS*(COLUMNS-1),ROWS*(COLUMNS-1)+1
          @cursorpos = MODE1
        when ROWS*(COLUMNS-1)+2,ROWS*(COLUMNS-1)+3
          @cursorpos = MODE2
        when ROWS*(COLUMNS-1)+4,ROWS*(COLUMNS-1)+5,ROWS*(COLUMNS-1)+6
          @cursorpos = MODE3
        when ROWS*(COLUMNS-1)+7,ROWS*(COLUMNS-1)+8,ROWS*(COLUMNS-1)+9,ROWS*(COLUMNS-1)+10
          @cursorpos = BACK
        when ROWS*(COLUMNS-1)+11,ROWS*(COLUMNS-1)+12
          @cursorpos = OK
        end
      else
        cursordiv=wrapmod((cursordiv+1),COLUMNS)
        @cursorpos=(cursordiv*ROWS)+cursormod
      end
    end
    if @cursorpos!=oldcursor   # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE()
      return true
    else
      return false
    end
  end

  def pbEntry
    ret=""
    loop do
      Graphics.update
      Input.update
      pbUpdate
      next if pbMoveCursor
      if Input.trigger?(Input::SPECIAL)
        pbChangeTab
      elsif Input.trigger?(Input::ACTION)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::BACK)
        @helper.delete
        pbPlayCancelSE()
        pbUpdateOverlay
      elsif Input.trigger?(Input::USE)
        case @cursorpos
        when BACK   # Backspace
          @helper.delete
          pbPlayCancelSE()
          pbUpdateOverlay
        when OK     # Done
          pbSEPlay("GUI naming confirm")
          if @helper.length>=@minlength
            ret=@helper.text
            break
          end
        when MODE1
          pbChangeTab(0) if @mode!=0
        when MODE2
          pbChangeTab(1) if @mode!=1
        when MODE3
          pbChangeTab(2) if @mode!=2
        else
          cursormod=@cursorpos%ROWS
          cursordiv=@cursorpos/ROWS
          charpos=cursordiv*(ROWS)+cursormod
          chset=@@Characters[@mode][0]
          if @helper.length>=@maxlength
            @helper.delete
          end
          @helper.insert(chset[charpos])
          pbPlayCursorSE()
          if @helper.length>=@maxlength
            @cursorpos=OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          pbUpdateOverlay
        end
      end
    end
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    for bitmap in @bitmaps
      bitmap.dispose if bitmap
    end
    @bitmaps.clear
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



#===============================================================================
#
#===============================================================================
class PokemonEntry
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(helptext,minlength,maxlength,initialText,mode=-1,pokemon=nil)
    @scene.pbStartScene(helptext,minlength,maxlength,initialText,mode,pokemon)
    ret=@scene.pbEntry
    @scene.pbEndScene
    return ret
  end
end



#===============================================================================
#
#===============================================================================
def pbEnterText(helptext,minlength,maxlength,initialText="",mode=0,pokemon=nil,nofadeout=false)
  ret=""
  if ($PokemonSystem.textinput==1 rescue false)   # Keyboard
    pbFadeOutIn(99999,nofadeout) {
       sscene=PokemonEntryScene.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  else   # Cursor
    pbFadeOutIn(99999,nofadeout) {
       sscene=PokemonEntryScene2.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  end
  return ret
end

def pbEnterPlayerName(helptext,minlength,maxlength,initialText="",nofadeout=false)
  return pbEnterText(helptext,minlength,maxlength,initialText,1,nil,nofadeout)
end

def pbEnterPokemonName(helptext,minlength,maxlength,initialText="",pokemon=nil,nofadeout=false)
  return pbEnterText(helptext,minlength,maxlength,initialText,2,pokemon,nofadeout)
end

def pbEnterNPCName(helptext,minlength,maxlength,initialText="",id=0,nofadeout=false)
  return pbEnterText(helptext,minlength,maxlength,initialText,3,id,nofadeout)
end

def pbEnterBoxName(helptext,minlength,maxlength,initialText="",nofadeout=false)
  return pbEnterText(helptext,minlength,maxlength,initialText,4,nil,nofadeout)
end
