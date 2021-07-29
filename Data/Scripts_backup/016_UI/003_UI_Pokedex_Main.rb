#===============================================================================
#
#===============================================================================
class Window_Pokedex < Window_DrawableCommand
  def initialize(x,y,width,height,viewport)
    @commands = []
    super(x,y,width,height,viewport)
    @selarrow     = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_list")
    @pokeballOwn  = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_own")
    @pokeballSeen = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_seen")
    self.baseColor   = Color.new(88,88,80)
    self.shadowColor = Color.new(168,184,184)
    self.windowskin  = nil
  end

  def commands=(value)
    @commands = value
    refresh
  end

  def dispose
    @pokeballOwn.dispose
    @pokeballSeen.dispose
    super
  end

  def species
    return (@commands.length==0) ? 0 : @commands[self.index][0]
  end

  def itemCount
    return @commands.length
  end

  def drawItem(index,_count,rect)
    return if index>=self.top_row+self.page_item_max
    rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
    species     = @commands[index][0]
    indexNumber = @commands[index][4]
    indexNumber -= 1 if @commands[index][5]
    if $Trainer.seen?(species)
      if $Trainer.owned?(species)
        pbCopyBitmap(self.contents,@pokeballOwn.bitmap,rect.x-6,rect.y+8)
      else
        pbCopyBitmap(self.contents,@pokeballSeen.bitmap,rect.x-6,rect.y+8)
      end
      text = sprintf("%03d%s %s",indexNumber," ",@commands[index][1])
    else
      text = sprintf("%03d  ----------",indexNumber)
    end
    pbDrawShadowText(self.contents,rect.x+36,rect.y+6,rect.width,rect.height,
       text,self.baseColor,self.shadowColor)
  end

  def refresh
    @item_max = itemCount
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i<self.top_item || i>self.top_item+self.page_item_max
      drawItem(i,@item_max,itemRect(i))
    end
    drawCursor(self.index,itemRect(self.index))
  end

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
#
#===============================================================================
class PokedexSearchSelectionSprite < SpriteWrapper
  attr_reader :index
  attr_accessor :cmds
  attr_accessor :minmax

  def initialize(viewport=nil)
    super(viewport)
    @selbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_search")
    self.bitmap = @selbitmap.bitmap
    self.mode = -1
    @index = 0
    refresh
  end

  def dispose
    @selbitmap.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def mode=(value)
    @mode = value
    case @mode
    when 0     # Order
      @xstart = 46; @ystart = 128
      @xgap = 236; @ygap = 64
      @cols = 2
    when 1     # Name
      @xstart = 78; @ystart = 114
      @xgap = 52; @ygap = 52
      @cols = 7
    when 2     # Type
      @xstart = 8; @ystart = 104
      @xgap = 124; @ygap = 44
      @cols = 4
    when 3,4   # Height, weight
      @xstart = 44; @ystart = 110
      @xgap = 8; @ygap = 112
    when 5     # Color
      @xstart = 62; @ystart = 114
      @xgap = 132; @ygap = 52
      @cols = 3
    when 6     # Shape
      @xstart = 82; @ystart = 116
      @xgap = 70; @ygap = 70
      @cols = 5
    end
  end

  def refresh
    # Size and position cursor
    if @mode==-1   # Main search screen
      case @index
      when 0     # Order
        self.src_rect.y = 0; self.src_rect.height = 44
      when 1,5   # Name, color
        self.src_rect.y = 44; self.src_rect.height = 44
      when 2     # Type
        self.src_rect.y = 88; self.src_rect.height = 44
      when 3,4   # Height, weight
        self.src_rect.y = 132; self.src_rect.height = 44
      when 6     # Form
        self.src_rect.y = 176; self.src_rect.height = 68
      else       # Reset/start/cancel
        self.src_rect.y = 244; self.src_rect.height = 40
      end
      case @index
      when 0         # Order
        self.x = 252; self.y = 52
      when 1,2,3,4   # Name, type, height, weight
        self.x = 114; self.y = 110+(@index-1)*52
      when 5         # Color
        self.x = 382; self.y = 110
      when 6         # Shape
        self.x = 420; self.y = 214
      when 7,8,9     # Reset, start, cancel
        self.x = 4+(@index-7)*176; self.y = 334
      end
    else   # Parameter screen
      case @index
      when -2,-3   # OK, Cancel
        self.src_rect.y = 244; self.src_rect.height = 40
      else
        case @mode
        when 0     # Order
          self.src_rect.y = 0; self.src_rect.height = 44
        when 1     # Name
          self.src_rect.y = 284; self.src_rect.height = 44
        when 2,5   # Type, color
          self.src_rect.y = 44; self.src_rect.height = 44
        when 3,4   # Height, weight
          self.src_rect.y = (@minmax==1) ? 328 : 424; self.src_rect.height = 96
        when 6     # Shape
          self.src_rect.y = 176; self.src_rect.height = 68
        end
      end
      case @index
      when -1   # Blank option
        if @mode==3 || @mode==4   # Height/weight range
          self.x = @xstart+(@cmds+1)*@xgap*(@minmax%2)
          self.y = @ystart+@ygap*((@minmax+1)%2)
        else
          self.x = @xstart+(@cols-1)*@xgap
          self.y = @ystart+(@cmds/@cols).floor*@ygap
        end
      when -2   # OK
        self.x = 4; self.y = 334
      when -3   # Cancel
        self.x = 356; self.y = 334
      else
        case @mode
        when 0,1,2,5,6   # Order, name, type, color, shape
          if @index>=@cmds
            self.x = @xstart+(@cols-1)*@xgap
            self.y = @ystart+(@cmds/@cols).floor*@ygap
          else
            self.x = @xstart+(@index%@cols)*@xgap
            self.y = @ystart+(@index/@cols).floor*@ygap
          end
        when 3,4         # Height, weight
          if @index>=@cmds
            self.x = @xstart+(@cmds+1)*@xgap*((@minmax+1)%2)
          else
            self.x = @xstart+(@index+1)*@xgap
          end
          self.y = @ystart+@ygap*((@minmax+1)%2)
        end
      end
    end
  end
end

#===============================================================================
# Pokédex main screen
#===============================================================================
class PokemonPokedex_Scene
  MODENUMERICAL = 0
  MODEATOZ      = 1
  MODETALLEST   = 2
  MODESMALLEST  = 3
  MODEHEAVIEST  = 4
  MODELIGHTEST  = 5

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sliderbitmap       = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
    @typebitmap         = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @shapebitmap        = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
    @hwbitmap           = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
    @selbitmap          = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_searchslider"))
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites,"background","Pokedex/bg_list",@viewport)
=begin
    # Suggestion for changing the background depending on region. You can change
    # the line above with the following:
    if pbGetPokedexRegion==-1   # Using national Pokédex
      addBackgroundPlane(@sprites,"background","Pokedex/bg_national",@viewport)
    elsif pbGetPokedexRegion==0   # Using first regional Pokédex
      addBackgroundPlane(@sprites,"background","Pokedex/bg_regional",@viewport)
    end
=end
    addBackgroundPlane(@sprites,"searchbg","Pokedex/bg_search",@viewport)
    @sprites["searchbg"].visible = false
    @sprites["pokedex"] = Window_Pokedex.new(206,30,276,364,@viewport)
    @sprites["icon"] = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::Center)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    @sprites["searchcursor"].visible = false
    @searchResults = false
    @searchParams  = [$PokemonGlobal.pokedexMode,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @typebitmap.dispose
    @shapebitmap.dispose
    @hwbitmap.dispose
    @selbitmap.dispose
    @searchsliderbitmap.dispose
    @viewport.dispose
  end

  # Gets the region used for displaying Pokédex entries. Species will be listed
  # according to the given region's numbering and the returned region can have
  # any value defined in the town map data file. It is currently set to the
  # return value of pbGetCurrentRegion, and thus will change according to the
  # current map's MapPosition metadata setting.
  def pbGetPokedexRegion
    if Settings::USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region >= $Trainer.pokedex.dexes_count - 1
      return region
    else
      return $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
    end
  end

  # Determines which index of the array $PokemonGlobal.pokedexIndex to save the
  # "last viewed species" in. All regional dexes come first in order, then the
  # National Dex at the end.
  def pbGetSavePositionIndex
    index = pbGetPokedexRegion
    if index==-1   # National Dex (comes after regional Dex indices)
      index = $Trainer.pokedex.dexes_count - 1
    end
    return index
  end

  def pbCanAddForModeList?(mode, species)
    case mode
    when MODEATOZ
      return $Trainer.seen?(species)
    when MODEHEAVIEST, MODELIGHTEST, MODETALLEST, MODESMALLEST
      return $Trainer.owned?(species)
    end
    return true   # For MODENUMERICAL
  end

  def pbGetDexList
    region = pbGetPokedexRegion
    regionalSpecies = pbAllRegionalSpecies(region)
    if !regionalSpecies || regionalSpecies.length == 0
      # If no Regional Dex defined for the given region, use the National Pokédex
      regionalSpecies = []
      GameData::Species.each { |s| regionalSpecies.push(s.id) if s.form == 0 }
    end
    shift = Settings::DEXES_WITH_OFFSETS.include?(region)
    ret = []
    regionalSpecies.each_with_index do |species, i|
      next if !species
      next if !pbCanAddForModeList?($PokemonGlobal.pokedexMode, species)
      species_data = GameData::Species.get(species)
      color  = species_data.color
      type1  = species_data.type1
      type2  = species_data.type2 || type1
      shape  = species_data.shape
      height = species_data.height
      weight = species_data.weight
      ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape])
    end
    return ret
  end

  def pbRefreshDexList(index=0)
    dexlist = pbGetDexList
    case $PokemonGlobal.pokedexMode
    when MODENUMERICAL
      # Hide the Dex number 0 species if unseen
      dexlist[0] = nil if dexlist[0][5] && !$Trainer.seen?(dexlist[0][0])
      # Remove unseen species from the end of the list
      i = dexlist.length-1
      loop do break unless i>=0
        break if !dexlist[i] || $Trainer.seen?(dexlist[i][0])
        dexlist[i] = nil
        i -= 1
      end
      dexlist.compact!
      # Sort species in ascending order by Regional Dex number
      dexlist.sort! { |a,b| a[4]<=>b[4] }
    when MODEATOZ
      dexlist.sort! { |a,b| (a[1]==b[1]) ? a[4]<=>b[4] : a[1]<=>b[1] }
    when MODEHEAVIEST
      dexlist.sort! { |a,b| (a[3]==b[3]) ? a[4]<=>b[4] : b[3]<=>a[3] }
    when MODELIGHTEST
      dexlist.sort! { |a,b| (a[3]==b[3]) ? a[4]<=>b[4] : a[3]<=>b[3] }
    when MODETALLEST
      dexlist.sort! { |a,b| (a[2]==b[2]) ? a[4]<=>b[4] : b[2]<=>a[2] }
    when MODESMALLEST
      dexlist.sort! { |a,b| (a[2]==b[2]) ? a[4]<=>b[4] : a[2]<=>b[2] }
    end
    @dexlist = dexlist
    @sprites["pokedex"].commands = @dexlist
    @sprites["pokedex"].index    = index
    @sprites["pokedex"].refresh
    if @searchResults
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
    end
    pbRefresh
  end

  def pbRefresh
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    iconspecies = @sprites["pokedex"].species
    iconspecies = nil if !$Trainer.seen?(iconspecies)
    # Write various bits of text
    dexname = _INTL("Pokédex")
    if $Trainer.pokedex.dexes_count > 1
      thisdex = Settings.pokedex_names[pbGetSavePositionIndex]
      if thisdex!=nil
        dexname = (thisdex.is_a?(Array)) ? thisdex[0] : thisdex
      end
    end
    textpos = [
       [dexname,Graphics.width/2,-2,2,Color.new(248,248,248),Color.new(0,0,0)]
    ]
    textpos.push([GameData::Species.get(iconspecies).name,112,46,2,base,shadow]) if iconspecies
    if @searchResults
      textpos.push([_INTL("Search results"),112,302,2,base,shadow])
      textpos.push([@dexlist.length.to_s,112,334,2,base,shadow])
    else
      textpos.push([_INTL("Seen:"),42,302,0,base,shadow])
      textpos.push([$Trainer.pokedex.seen_count(pbGetPokedexRegion).to_s,182,302,1,base,shadow])
      textpos.push([_INTL("Owned:"),42,334,0,base,shadow])
      textpos.push([$Trainer.pokedex.owned_count(pbGetPokedexRegion).to_s,182,334,1,base,shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Set Pokémon sprite
    setIconBitmap(iconspecies)
    # Draw slider arrows
    itemlist = @sprites["pokedex"]
    showslider = false
    if itemlist.top_row>0
      overlay.blt(468,48,@sliderbitmap.bitmap,Rect.new(0,0,40,30))
      showslider = true
    end
    if itemlist.top_item+itemlist.page_item_max<itemlist.itemCount
      overlay.blt(468,346,@sliderbitmap.bitmap,Rect.new(0,30,40,30))
      showslider = true
    end
    # Draw slider box
    if showslider
      sliderheight = 268
      boxheight = (sliderheight*itemlist.page_row_max/itemlist.row_max).floor
      boxheight += [(sliderheight-boxheight)/2,sliderheight/6].min
      boxheight = [boxheight.floor,40].max
      y = 78
      y += ((sliderheight-boxheight)*itemlist.top_row/(itemlist.row_max-itemlist.page_row_max)).floor
      overlay.blt(468,y,@sliderbitmap.bitmap,Rect.new(40,0,40,8))
      i = 0
      while i*16<boxheight-8-16
        height = [boxheight-8-16-i*16,16].min
        overlay.blt(468,y+8+i*16,@sliderbitmap.bitmap,Rect.new(40,8,40,height))
        i += 1
      end
      overlay.blt(468,y+boxheight-16,@sliderbitmap.bitmap,Rect.new(40,24,40,16))
    end
  end

  def pbRefreshDexSearch(params,_index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(72,72,72)
    # Write various bits of text
    textpos = [
       [_INTL("Search Mode"),Graphics.width/2,-2,2,base,shadow],
       [_INTL("Order"),136,52,2,base,shadow],
       [_INTL("Name"),58,110,2,base,shadow],
       [_INTL("Type"),58,162,2,base,shadow],
       [_INTL("Height"),58,214,2,base,shadow],
       [_INTL("Weight"),58,266,2,base,shadow],
       [_INTL("Color"),326,110,2,base,shadow],
       [_INTL("Shape"),454,162,2,base,shadow],
       [_INTL("Reset"),80,338,2,base,shadow,1],
       [_INTL("Start"),Graphics.width/2,338,2,base,shadow,1],
       [_INTL("Cancel"),Graphics.width-80,338,2,base,shadow,1]
    ]
    # Write order, name and color parameters
    textpos.push([@orderCommands[params[0]],344,58,2,base,shadow,1])
    textpos.push([(params[1]<0) ? "----" : @nameCommands[params[1]],176,116,2,base,shadow,1])
    textpos.push([(params[8]<0) ? "----" : @colorCommands[params[8]].name,444,116,2,base,shadow,1])
    # Draw type icons
    if params[2]>=0
      type_number = @typeCommands[params[2]].id_number
      typerect = Rect.new(0,type_number*32,96,32)
      overlay.blt(128,168,@typebitmap.bitmap,typerect)
    else
      textpos.push(["----",176,168,2,base,shadow,1])
    end
    if params[3]>=0
      type_number = @typeCommands[params[3]].id_number
      typerect = Rect.new(0,type_number*32,96,32)
      overlay.blt(256,168,@typebitmap.bitmap,typerect)
    else
      textpos.push(["----",304,168,2,base,shadow,1])
    end
    # Write height and weight limits
    ht1 = (params[4]<0) ? 0 : (params[4]>=@heightCommands.length) ? 999 : @heightCommands[params[4]]
    ht2 = (params[5]<0) ? 999 : (params[5]>=@heightCommands.length) ? 0 : @heightCommands[params[5]]
    wt1 = (params[6]<0) ? 0 : (params[6]>=@weightCommands.length) ? 9999 : @weightCommands[params[6]]
    wt2 = (params[7]<0) ? 9999 : (params[7]>=@weightCommands.length) ? 0 : @weightCommands[params[7]]
    hwoffset = false
    if System.user_language[3..4]=="US"   # If the user is in the United States
      ht1 = (params[4]>=@heightCommands.length) ? 99*12 : (ht1/0.254).round
      ht2 = (params[5]<0) ? 99*12 : (ht2/0.254).round
      wt1 = (params[6]>=@weightCommands.length) ? 99990 : (wt1/0.254).round
      wt2 = (params[7]<0) ? 99990 : (wt2/0.254).round
      textpos.push([sprintf("%d'%02d''",ht1/12,ht1%12),166,220,2,base,shadow,1])
      textpos.push([sprintf("%d'%02d''",ht2/12,ht2%12),294,220,2,base,shadow,1])
      textpos.push([sprintf("%.1f",wt1/10.0),166,272,2,base,shadow,1])
      textpos.push([sprintf("%.1f",wt2/10.0),294,272,2,base,shadow,1])
      hwoffset = true
    else
      textpos.push([sprintf("%.1f",ht1/10.0),166,220,2,base,shadow,1])
      textpos.push([sprintf("%.1f",ht2/10.0),294,220,2,base,shadow,1])
      textpos.push([sprintf("%.1f",wt1/10.0),166,272,2,base,shadow,1])
      textpos.push([sprintf("%.1f",wt2/10.0),294,272,2,base,shadow,1])
    end
    overlay.blt(344,214,@hwbitmap.bitmap,Rect.new(0,(hwoffset) ? 44 : 0,32,44))
    overlay.blt(344,266,@hwbitmap.bitmap,Rect.new(32,(hwoffset) ? 44 : 0,32,44))
    # Draw shape icon
    if params[9] >= 0
      shape_number = @shapeCommands[params[9]].id_number
      shaperect = Rect.new(0, (shape_number - 1) * 60, 60, 60)
      overlay.blt(424, 218, @shapebitmap.bitmap, shaperect)
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end

  def pbRefreshDexSearchParam(mode,cmds,sel,_index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(72,72,72)
    # Write various bits of text
    textpos = [
       [_INTL("Search Mode"),Graphics.width/2,-2,2,base,shadow],
       [_INTL("OK"),80,338,2,base,shadow,1],
       [_INTL("Cancel"),Graphics.width-80,338,2,base,shadow,1]
    ]
    title = [_INTL("Order"),_INTL("Name"),_INTL("Type"),_INTL("Height"),
             _INTL("Weight"),_INTL("Color"),_INTL("Shape")][mode]
    textpos.push([title,102,(mode==6) ? 58 : 52,0,base,shadow])
    case mode
    when 0   # Order
      xstart = 46; ystart = 128
      xgap = 236; ygap = 64
      halfwidth = 92; cols = 2
      selbuttony = 0; selbuttonheight = 44
    when 1   # Name
      xstart = 78; ystart = 114
      xgap = 52; ygap = 52
      halfwidth = 22; cols = 7
      selbuttony = 156; selbuttonheight = 44
    when 2   # Type
      xstart = 8; ystart = 104
      xgap = 124; ygap = 44
      halfwidth = 62; cols = 4
      selbuttony = 44; selbuttonheight = 44
    when 3,4   # Height, weight
      xstart = 44; ystart = 110
      xgap = 304/(cmds.length+1); ygap = 112
      halfwidth = 60; cols = cmds.length+1
    when 5   # Color
      xstart = 62; ystart = 114
      xgap = 132; ygap = 52
      halfwidth = 62; cols = 3
      selbuttony = 44; selbuttonheight = 44
    when 6   # Shape
      xstart = 82; ystart = 116
      xgap = 70; ygap = 70
      halfwidth = 0; cols = 5
      selbuttony = 88; selbuttonheight = 68
    end
    # Draw selected option(s) text in top bar
    case mode
    when 2   # Type icons
      for i in 0...2
        if !sel[i] || sel[i]<0
          textpos.push(["----",298+128*i,58,2,base,shadow,1])
        else
          type_number = @typeCommands[sel[i]].id_number
          typerect = Rect.new(0,type_number*32,96,32)
          overlay.blt(250+128*i,58,@typebitmap.bitmap,typerect)
        end
      end
    when 3   # Height range
      ht1 = (sel[0]<0) ? 0 : (sel[0]>=@heightCommands.length) ? 999 : @heightCommands[sel[0]]
      ht2 = (sel[1]<0) ? 999 : (sel[1]>=@heightCommands.length) ? 0 : @heightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4]=="US"    # If the user is in the United States
        ht1 = (sel[0]>=@heightCommands.length) ? 99*12 : (ht1/0.254).round
        ht2 = (sel[1]<0) ? 99*12 : (ht2/0.254).round
        txt1 = sprintf("%d'%02d''",ht1/12,ht1%12)
        txt2 = sprintf("%d'%02d''",ht2/12,ht2%12)
        hwoffset = true
      else
        txt1 = sprintf("%.1f",ht1/10.0)
        txt2 = sprintf("%.1f",ht2/10.0)
      end
      textpos.push([txt1,286,58,2,base,shadow,1])
      textpos.push([txt2,414,58,2,base,shadow,1])
      overlay.blt(462,52,@hwbitmap.bitmap,Rect.new(0,(hwoffset) ? 44 : 0,32,44))
    when 4   # Weight range
      wt1 = (sel[0]<0) ? 0 : (sel[0]>=@weightCommands.length) ? 9999 : @weightCommands[sel[0]]
      wt2 = (sel[1]<0) ? 9999 : (sel[1]>=@weightCommands.length) ? 0 : @weightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4]=="US"   # If the user is in the United States
        wt1 = (sel[0]>=@weightCommands.length) ? 99990 : (wt1/0.254).round
        wt2 = (sel[1]<0) ? 99990 : (wt2/0.254).round
        txt1 = sprintf("%.1f",wt1/10.0)
        txt2 = sprintf("%.1f",wt2/10.0)
        hwoffset = true
      else
        txt1 = sprintf("%.1f",wt1/10.0)
        txt2 = sprintf("%.1f",wt2/10.0)
      end
      textpos.push([txt1,286,58,2,base,shadow,1])
      textpos.push([txt2,414,58,2,base,shadow,1])
      overlay.blt(462,52,@hwbitmap.bitmap,Rect.new(32,(hwoffset) ? 44 : 0,32,44))
    when 5   # Color
      if sel[0]<0
        textpos.push(["----",362,58,2,base,shadow,1])
      else
        textpos.push([cmds[sel[0]].name,362,58,2,base,shadow,1])
      end
    when 6   # Shape icon
      if sel[0] >= 0
        shaperect = Rect.new(0, (@shapeCommands[sel[0]].id_number - 1) * 60, 60, 60)
        overlay.blt(332, 50, @shapebitmap.bitmap, shaperect)
      end
    else
      if sel[0]<0
        text = ["----","-","----","","","----",""][mode]
        textpos.push([text,362,58,2,base,shadow,1])
      else
        textpos.push([cmds[sel[0]],362,58,2,base,shadow,1])
      end
    end
    # Draw selected option(s) button graphic
    if mode==3 || mode==4   # Height, weight
      xpos1 = xstart+(sel[0]+1)*xgap
      xpos1 = xstart if sel[0]<-1
      xpos2 = xstart+(sel[1]+1)*xgap
      xpos2 = xstart+cols*xgap if sel[1]<0
      xpos2 = xstart if sel[1]>=cols-1
      ypos1 = ystart+172
      ypos2 = ystart+28
      overlay.blt(16,120,@searchsliderbitmap.bitmap,Rect.new(0,192,32,44)) if sel[1]<cols-1
      overlay.blt(464,120,@searchsliderbitmap.bitmap,Rect.new(32,192,32,44)) if sel[1]>=0
      overlay.blt(16,264,@searchsliderbitmap.bitmap,Rect.new(0,192,32,44)) if sel[0]>=0
      overlay.blt(464,264,@searchsliderbitmap.bitmap,Rect.new(32,192,32,44)) if sel[0]<cols-1
      hwrect = Rect.new(0,0,120,96)
      overlay.blt(xpos2,ystart,@searchsliderbitmap.bitmap,hwrect)
      hwrect.y = 96
      overlay.blt(xpos1,ystart+ygap,@searchsliderbitmap.bitmap,hwrect)
      textpos.push([txt1,xpos1+halfwidth,ypos1,2,base,nil,1])
      textpos.push([txt2,xpos2+halfwidth,ypos2,2,base,nil,1])
    else
      for i in 0...sel.length
        if sel[i]>=0
          selrect = Rect.new(0,selbuttony,@selbitmap.bitmap.width,selbuttonheight)
          overlay.blt(xstart+(sel[i]%cols)*xgap,ystart+(sel[i]/cols).floor*ygap,@selbitmap.bitmap,selrect)
        else
          selrect = Rect.new(0,selbuttony,@selbitmap.bitmap.width,selbuttonheight)
          overlay.blt(xstart+(cols-1)*xgap,ystart+(cmds.length/cols).floor*ygap,@selbitmap.bitmap,selrect)
        end
      end
    end
    # Draw options
    case mode
    when 0,1   # Order, name
      for i in 0...cmds.length
        x = xstart+halfwidth+(i%cols)*xgap
        y = ystart+6+(i/cols).floor*ygap
        textpos.push([cmds[i],x,y,2,base,shadow,1])
      end
      if mode!=0
        textpos.push([(mode==1) ? "-" : "----",
           xstart+halfwidth+(cols-1)*xgap,ystart+6+(cmds.length/cols).floor*ygap,2,base,shadow,1])
      end
    when 2   # Type
      typerect = Rect.new(0,0,96,32)
      for i in 0...cmds.length
        typerect.y = @typeCommands[i].id_number*32
        overlay.blt(xstart+14+(i%cols)*xgap,ystart+6+(i/cols).floor*ygap,@typebitmap.bitmap,typerect)
      end
      textpos.push(["----",
         xstart+halfwidth+(cols-1)*xgap,ystart+6+(cmds.length/cols).floor*ygap,2,base,shadow,1])
    when 5   # Color
      for i in 0...cmds.length
        x = xstart+halfwidth+(i%cols)*xgap
        y = ystart+6+(i/cols).floor*ygap
        textpos.push([cmds[i].name,x,y,2,base,shadow,1])
      end
      textpos.push(["----",
         xstart+halfwidth+(cols-1)*xgap,ystart+6+(cmds.length/cols).floor*ygap,2,base,shadow,1])
    when 6   # Shape
      shaperect = Rect.new(0, 0, 60, 60)
      for i in 0...cmds.length
        shaperect.y = (@shapeCommands[i].id_number - 1) * 60
        overlay.blt(xstart + 4 + (i % cols) * xgap, ystart + 4 + (i / cols).floor * ygap, @shapebitmap.bitmap, shaperect)
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end

  def setIconBitmap(species)
    gender, form = $Trainer.pokedex.last_form_seen(species)
    @sprites["icon"].setSpeciesBitmap(species, gender, form)
  end

  def pbSearchDexList(params)
    $PokemonGlobal.pokedexMode = params[0]
    dexlist = pbGetDexList
    # Filter by name
    if params[1]>=0
      scanNameCommand = @nameCommands[params[1]].scan(/./)
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        firstChar = item[1][0,1]
        next scanNameCommand.any? { |v| v==firstChar }
      }
    end
    # Filter by type
    if params[2]>=0 || params[3]>=0
      stype1 = (params[2]>=0) ? @typeCommands[params[2]].id : nil
      stype2 = (params[3]>=0) ? @typeCommands[params[3]].id : nil
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        type1 = item[6]
        type2 = item[7]
        if stype1 && stype2
          # Find species that match both types
          next (type1==stype1 && type2==stype2) || (type1==stype2 && type2==stype1)
        elsif stype1
          # Find species that match first type entered
          next type1==stype1 || type2==stype1
        elsif stype2
          # Find species that match second type entered
          next type1==stype2 || type2==stype2
        else
          next false
        end
      }
    end
    # Filter by height range
    if params[4]>=0 || params[5]>=0
      minh = (params[4]<0) ? 0 : (params[4]>=@heightCommands.length) ? 999 : @heightCommands[params[4]]
      maxh = (params[5]<0) ? 999 : (params[5]>=@heightCommands.length) ? 0 : @heightCommands[params[5]]
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        height = item[2]
        next height>=minh && height<=maxh
      }
    end
    # Filter by weight range
    if params[6]>=0 || params[7]>=0
      minw = (params[6]<0) ? 0 : (params[6]>=@weightCommands.length) ? 9999 : @weightCommands[params[6]]
      maxw = (params[7]<0) ? 9999 : (params[7]>=@weightCommands.length) ? 0 : @weightCommands[params[7]]
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.owned?(item[0])
        weight = item[3]
        next weight>=minw && weight<=maxw
      }
    end
    # Filter by color
    if params[8]>=0
      scolor = @colorCommands[params[8]].id
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        next item[8] == scolor
      }
    end
    # Filter by shape
    if params[9]>=0
      sshape = @shapeCommands[params[9]].id
      dexlist = dexlist.find_all { |item|
        next false if !$Trainer.seen?(item[0])
        next item[9] == sshape
      }
    end
    # Remove all unseen species from the results
    dexlist = dexlist.find_all { |item| next $Trainer.seen?(item[0]) }
    case $PokemonGlobal.pokedexMode
    when MODENUMERICAL then dexlist.sort! { |a,b| a[4]<=>b[4] }
    when MODEATOZ      then dexlist.sort! { |a,b| a[1]<=>b[1] }
    when MODEHEAVIEST  then dexlist.sort! { |a,b| b[3]<=>a[3] }
    when MODELIGHTEST  then dexlist.sort! { |a,b| a[3]<=>b[3] }
    when MODETALLEST   then dexlist.sort! { |a,b| b[2]<=>a[2] }
    when MODESMALLEST  then dexlist.sort! { |a,b| a[2]<=>b[2] }
    end
    return dexlist
  end

  def pbCloseSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    oldspecies = @sprites["pokedex"].species
    @searchResults = false
    $PokemonGlobal.pokedexMode = MODENUMERICAL
    @searchParams  = [$PokemonGlobal.pokedexMode,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    for i in 0...@dexlist.length
      next if @dexlist[i][0]!=oldspecies
      @sprites["pokedex"].index = i
      pbRefresh
      break
    end
    $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbDexEntry(index)
    oldsprites = pbFadeOutAndHide(@sprites)
    region = -1
    if !Settings::USE_CURRENT_REGION_DEX
      dexnames = Settings.pokedex_names
      if dexnames[pbGetSavePositionIndex].is_a?(Array)
        region = dexnames[pbGetSavePositionIndex][1]
      end
    end
    scene = PokemonPokedexInfo_Scene.new
    screen = PokemonPokedexInfoScreen.new(scene)
    ret = screen.pbStartScreen(@dexlist,index,region)
    if @searchResults
      dexlist = pbSearchDexList(@searchParams)
      @dexlist = dexlist
      @sprites["pokedex"].commands = @dexlist
      ret = @dexlist.length-1 if ret>=@dexlist.length
      ret = 0 if ret<0
    else
      pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
      $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = ret
    end
    @sprites["pokedex"].index = ret
    @sprites["pokedex"].refresh
    pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbDexSearchCommands(mode,selitems,mainindex)
    cmds = [@orderCommands,@nameCommands,@typeCommands,@heightCommands,
            @weightCommands,@colorCommands,@shapeCommands][mode]
    cols = [2,7,4,1,1,3,5][mode]
    ret = nil
    # Set background
    case mode
    when 0    then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_order")
    when 1    then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_name")
    when 2
      count = 0
      GameData::Type.each { |t| count += 1 if !t.pseudo_type && t.id != :SHADOW }
      if count == 18
        @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_type_18")
      else
        @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_type")
      end
    when 3, 4 then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_size")
    when 5    then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_color")
    when 6    then @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search_shape")
    end
    selindex = selitems.clone
    index     = selindex[0]
    oldindex  = index
    minmax    = 1
    oldminmax = minmax
    if mode==3 || mode==4
      index = oldindex = selindex[minmax]
    end
    @sprites["searchcursor"].mode   = mode
    @sprites["searchcursor"].cmds   = cmds.length
    @sprites["searchcursor"].minmax = minmax
    @sprites["searchcursor"].index  = index
    nextparam = cmds.length%2
    pbRefreshDexSearchParam(mode,cmds,selindex,index)
    loop do
      pbUpdate
      if index!=oldindex || minmax!=oldminmax
        @sprites["searchcursor"].minmax = minmax
        @sprites["searchcursor"].index  = index
        oldindex  = index
        oldminmax = minmax
      end
      Graphics.update
      Input.update
      if mode==3 || mode==4
        if Input.trigger?(Input::UP)
          if index<-1; minmax = 0; index = selindex[minmax]   # From OK/Cancel
          elsif minmax==0; minmax = 1; index = selindex[minmax]
          end
          if index!=oldindex || minmax!=oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode,cmds,selindex,index)
          end
        elsif Input.trigger?(Input::DOWN)
          if minmax==1; minmax = 0; index = selindex[minmax]
          elsif minmax==0; minmax = -1; index = -2
          end
          if index!=oldindex || minmax!=oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode,cmds,selindex,index)
          end
        elsif Input.repeat?(Input::LEFT)
          if index==-3; index = -2
          elsif index>=-1
            if minmax==1 && index==-1
              index = cmds.length-1 if selindex[0]<cmds.length-1
            elsif minmax==1 && index==0
              index = cmds.length if selindex[0]<0
            elsif index>-1 && !(minmax==1 && index>=cmds.length)
              index -= 1 if minmax==0 || selindex[0]<=index-1
            end
          end
          if index!=oldindex
            selindex[minmax] = index if minmax>=0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode,cmds,selindex,index)
          end
        elsif Input.repeat?(Input::RIGHT)
          if index==-2; index = -3
          elsif index>=-1
            if minmax==1 && index>=cmds.length; index = 0
            elsif minmax==1 && index==cmds.length-1; index = -1
            elsif index<cmds.length && !(minmax==1 && index<0)
              index += 1 if minmax==1 || selindex[1]==-1 ||
                            (selindex[1]<cmds.length && selindex[1]>=index+1)
            end
          end
          if index!=oldindex
            selindex[minmax] = index if minmax>=0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode,cmds,selindex,index)
          end
        end
      else
        if Input.trigger?(Input::UP)
          if index==-1; index = cmds.length-1-(cmds.length-1)%cols-1   # From blank
          elsif index==-2; index = ((cmds.length-1)/cols).floor*cols   # From OK
          elsif index==-3 && mode==0; index = cmds.length-1   # From Cancel
          elsif index==-3; index = -1   # From Cancel
          elsif index>=cols; index -= cols
          end
          pbPlayCursorSE if index!=oldindex
        elsif Input.trigger?(Input::DOWN)
          if index==-1; index = -3   # From blank
          elsif index>=0
            if index+cols<cmds.length; index += cols
            elsif (index/cols).floor<((cmds.length-1)/cols).floor
              index = (index%cols<cols/2.0) ? cmds.length-1 : -1
            else
              index = (index%cols<cols/2.0) ? -2 : -3
            end
          end
          pbPlayCursorSE if index!=oldindex
        elsif Input.trigger?(Input::LEFT)
          if index==-3; index = -2
          elsif index==-1; index = cmds.length-1
          elsif index>0 && index%cols!=0; index -= 1
          end
          pbPlayCursorSE if index!=oldindex
        elsif Input.trigger?(Input::RIGHT)
          if index==-2; index = -3
          elsif index==cmds.length-1 && mode!=0; index = -1
          elsif index>=0 && index%cols!=cols-1; index += 1
          end
          pbPlayCursorSE if index!=oldindex
        end
      end
      if Input.trigger?(Input::ACTION)
        index = -2
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        ret = nil
        break
      elsif Input.trigger?(Input::USE)
        if index==-2      # OK
          pbPlayDecisionSE
          ret = selindex
          break
        elsif index==-3   # Cancel
          pbPlayCloseMenuSE
          ret = nil
          break
        elsif selindex!=index && mode!=3 && mode!=4
          if mode==2
            if index==-1
              nextparam = (selindex[1]>=0) ? 1 : 0
            elsif index>=0
              nextparam = (selindex[0]<0) ? 0 : (selindex[1]<0) ? 1 : nextparam
            end
            if index<0 || selindex[(nextparam+1)%2]!=index
              pbPlayDecisionSE
              selindex[nextparam] = index
              nextparam = (nextparam+1)%2
            end
          else
            pbPlayDecisionSE
            selindex[0] = index
          end
          pbRefreshDexSearchParam(mode,cmds,selindex,index)
        end
      end
    end
    Input.update
    # Set background image
    @sprites["searchbg"].setBitmap("Graphics/Pictures/Pokedex/bg_search")
    @sprites["searchcursor"].mode = -1
    @sprites["searchcursor"].index = mainindex
    return ret
  end

  def pbDexSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    params = @searchParams.clone
    @orderCommands = []
    @orderCommands[MODENUMERICAL] = _INTL("Numerical")
    @orderCommands[MODEATOZ]      = _INTL("A to Z")
    @orderCommands[MODEHEAVIEST]  = _INTL("Heaviest")
    @orderCommands[MODELIGHTEST]  = _INTL("Lightest")
    @orderCommands[MODETALLEST]   = _INTL("Tallest")
    @orderCommands[MODESMALLEST]  = _INTL("Smallest")
    @nameCommands = [_INTL("A"),_INTL("B"),_INTL("C"),_INTL("D"),_INTL("E"),
                    _INTL("F"),_INTL("G"),_INTL("H"),_INTL("I"),_INTL("J"),
                    _INTL("K"),_INTL("L"),_INTL("M"),_INTL("N"),_INTL("O"),
                    _INTL("P"),_INTL("Q"),_INTL("R"),_INTL("S"),_INTL("T"),
                    _INTL("U"),_INTL("V"),_INTL("W"),_INTL("X"),_INTL("Y"),
                    _INTL("Z")]
    @typeCommands = []
    GameData::Type.each { |t| @typeCommands.push(t) if !t.pseudo_type }
    @typeCommands.sort! { |a, b| a.id_number <=> b.id_number }
    @heightCommands = [1,2,3,4,5,6,7,8,9,10,
                       11,12,13,14,15,16,17,18,19,20,
                       21,22,23,24,25,30,35,40,45,50,
                       55,60,65,70,80,90,100]
    @weightCommands = [5,10,15,20,25,30,35,40,45,50,
                       55,60,70,80,90,100,110,120,140,160,
                       180,200,250,300,350,400,500,600,700,800,
                       900,1000,1250,1500,2000,3000,5000]
    @colorCommands = []
    GameData::BodyColor.each { |c| @colorCommands.push(c) }
    @shapeCommands = []
    GameData::BodyShape.each { |c| @shapeCommands.push(c) if c.id != :None }
    @sprites["searchbg"].visible     = true
    @sprites["overlay"].visible      = true
    @sprites["searchcursor"].visible = true
    index = 0
    oldindex = index
    @sprites["searchcursor"].mode    = -1
    @sprites["searchcursor"].index   = index
    pbRefreshDexSearch(params,index)
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if index!=oldindex
        @sprites["searchcursor"].index = index
        oldindex = index
      end
      if Input.trigger?(Input::UP)
        if index>=7; index = 4
        elsif index==5; index = 0
        elsif index>0; index -= 1
        end
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::DOWN)
        if index==4 || index==6; index = 8
        elsif index<7; index += 1
        end
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::LEFT)
        if index==5; index = 1
        elsif index==6; index = 3
        elsif index>7; index -= 1
        end
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::RIGHT)
        if index==1; index = 5
        elsif index>=2 && index<=4; index = 6
        elsif index==7 || index==8; index += 1
        end
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::ACTION)
        index = 8
        pbPlayCursorSE if index!=oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE if index!=9
        case index
        when 0   # Choose sort order
          newparam = pbDexSearchCommands(0,[params[0]],index)
          params[0] = newparam[0] if newparam!=nil
          pbRefreshDexSearch(params,index)
        when 1   # Filter by name
          newparam = pbDexSearchCommands(1,[params[1]],index)
          params[1] = newparam[0] if newparam!=nil
          pbRefreshDexSearch(params,index)
        when 2   # Filter by type
          newparam = pbDexSearchCommands(2,[params[2],params[3]],index)
          if newparam!=nil
            params[2] = newparam[0]
            params[3] = newparam[1]
          end
          pbRefreshDexSearch(params,index)
        when 3   # Filter by height range
          newparam = pbDexSearchCommands(3,[params[4],params[5]],index)
          if newparam!=nil
            params[4] = newparam[0]
            params[5] = newparam[1]
          end
          pbRefreshDexSearch(params,index)
        when 4   # Filter by weight range
          newparam = pbDexSearchCommands(4,[params[6],params[7]],index)
          if newparam!=nil
            params[6] = newparam[0]
            params[7] = newparam[1]
          end
          pbRefreshDexSearch(params,index)
        when 5   # Filter by color filter
          newparam = pbDexSearchCommands(5,[params[8]],index)
          params[8] = newparam[0] if newparam!=nil
          pbRefreshDexSearch(params,index)
        when 6   # Filter by form
          newparam = pbDexSearchCommands(6,[params[9]],index)
          params[9] = newparam[0] if newparam!=nil
          pbRefreshDexSearch(params,index)
        when 7   # Clear filters
          for i in 0...10
            params[i] = (i==0) ? MODENUMERICAL : -1
          end
          pbRefreshDexSearch(params,index)
        when 8   # Start search (filter)
          dexlist = pbSearchDexList(params)
          if dexlist.length==0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
            @searchParams = params
            break
          end
        when 9   # Cancel
          pbPlayCloseMenuSE
          break
        end
      end
    end
    pbFadeOutAndHide(@sprites)
    if @searchResults
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
    end
    pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
    Input.update
    return 0
  end

  def pbPokedex
    pbActivateWindow(@sprites,"pokedex") {
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        if oldindex!=@sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          if @searchResults
            pbPlayCancelSE
            pbCloseSearch
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          if $Trainer.seen?(@sprites["pokedex"].species)
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
        end
      end
    }
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPokedex
    @scene.pbEndScene
  end
end
