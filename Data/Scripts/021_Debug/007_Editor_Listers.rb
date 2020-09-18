#===============================================================================
# Core lister script
#===============================================================================
def pbListWindow(cmds,width=Graphics.width/2)
  list = Window_CommandPokemon.newWithSize(cmds,0,0,width,Graphics.height)
  list.index     = 0
  list.rowHeight = 24
  pbSetSmallFont(list.contents)
  list.refresh
  return list
end

def pbListScreen(title,lister)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([])
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.new(title)
  title.x        = Graphics.width/2
  title.y        = 0
  title.width    = Graphics.width-title.x
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length==0
    value = lister.value(-1)
    lister.dispose
    title.dispose
    list.dispose
    viewport.dispose
    return value
  end
  list.commands = commands
  list.index    = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index!=selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::B)
      selectedmap = -1
      break
    elsif Input.trigger?(Input::C) || (list.doubleclick? rescue false)
      break
    end
  end
  value = lister.value(selectedmap)
  lister.dispose
  title.dispose
  list.dispose
  viewport.dispose
  Input.update
  return value
end

def pbListScreenBlock(title,lister)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([],Graphics.width/2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.new(title)
  title.x        = Graphics.width/2
  title.y        = 0
  title.width    = Graphics.width-title.x
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length==0
    value = lister.value(-1)
    lister.dispose
    title.dispose
    list.dispose
    viewport.dispose
    return value
  end
  list.commands = commands
  list.index = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index!=selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::A)
      yield(Input::A, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index==list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::B)
      break
    elsif Input.trigger?(Input::C) || (list.doubleclick? rescue false)
      yield(Input::C, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index==list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    end
  end
  lister.dispose
  title.dispose
  list.dispose
  viewport.dispose
  Input.update
end



#===============================================================================
# General listers
#===============================================================================
class GraphicsLister
  def initialize(folder,selection)
    @sprite = IconSprite.new(0,0)
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width * 3 / 4
    @sprite.y      = (Graphics.height - 64) / 2 + 64
    @sprite.z      = 2
    @folder = folder
    @selection = selection
    @commands = []
    @index = 0
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    Dir.chdir(@folder) {
      Dir.glob("*.png") { |f| @commands.push(f) }
      Dir.glob("*.PNG") { |f| @commands.push(f) }
      Dir.glob("*.gif") { |f| @commands.push(f) }
      Dir.glob("*.GIF") { |f| @commands.push(f) }
#      Dir.glob("*.bmp") { |f| @commands.push(f) }
#      Dir.glob("*.BMP") { |f| @commands.push(f) }
#      Dir.glob("*.jpg") { |f| @commands.push(f) }
#      Dir.glob("*.JPG") { |f| @commands.push(f) }
#      Dir.glob("*.jpeg") { |f| @commands.push(f) }
#      Dir.glob("*.JPEG") { |f| @commands.push(f) }
    }
    @commands.sort!
    @commands.length.times do |i|
      @index = i if @commands[i]==@selection
    end
    pbMessage(_INTL("There are no files.")) if @commands.length==0
    return @commands
  end

  def value(index)
    return (index<0) ? "" : @commands[index]
  end

  def refresh(index)
    return if index<0
    @sprite.setBitmap(@folder+@commands[index])
    sprite_width = @sprite.bitmap.width
    sprite_height = @sprite.bitmap.height
    @sprite.ox = sprite_width/2
    @sprite.oy = sprite_height/2
    scale_x = (Graphics.width/2).to_f/sprite_width
    scale_y = (Graphics.height-64).to_f/sprite_height
    if scale_x<1.0 || scale_y<1.0
      min_scale = [scale_x, scale_y].min
      @sprite.zoom_x = @sprite.zoom_y = min_scale
    else
      @sprite.zoom_x = @sprite.zoom_y = 1.0
    end
  end
end



class MusicFileLister
  def initialize(bgm,setting)
    @oldbgm = getPlayingBGM
    @commands = []
    @bgm = bgm
    @setting = setting
    @index = 0
  end

  def dispose
    pbPlayBGM(@oldbgm)
  end

  def setViewport(viewport)
  end

  def getPlayingBGM
    ($game_system) ? $game_system.getPlayingBGM : nil
  end

  def pbPlayBGM(bgm)
    (bgm) ? pbBGMPlay(bgm) : pbBGMStop
  end

  def startIndex
    return @index
  end

  def commands
    folder = (@bgm) ? "Audio/BGM/" : "Audio/ME/"
    @commands.clear
    Dir.chdir(folder) {
      Dir.glob("*.mp3") { |f| @commands.push(f) }
      Dir.glob("*.MP3") { |f| @commands.push(f) }
      Dir.glob("*.ogg") { |f| @commands.push(f) }
      Dir.glob("*.OGG") { |f| @commands.push(f) }
      Dir.glob("*.wav") { |f| @commands.push(f) }
      Dir.glob("*.WAV") { |f| @commands.push(f) }
      Dir.glob("*.mid") { |f| @commands.push(f) }
      Dir.glob("*.MID") { |f| @commands.push(f) }
      Dir.glob("*.midi") { |f| @commands.push(f) }
      Dir.glob("*.MIDI") { |f| @commands.push(f) }
    }
    @commands.sort!
    @commands.length.times do |i|
      @index = i if @commands[i]==@setting
    end
    pbMessage(_INTL("There are no files.")) if @commands.length==0
    return @commands
  end

  def value(index)
    return (index<0) ? "" : @commands[index]
  end

  def refresh(index)
    return if index<0
    if @bgm
      pbPlayBGM(@commands[index])
    else
      pbPlayBGM("../../Audio/ME/"+@commands[index])
    end
  end
end



class MapLister
  def initialize(selmap,addGlobal=false)
    @sprite = SpriteWrapper.new
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width * 3 / 4
    @sprite.y      = (Graphics.height - 64) / 2 + 64
    @sprite.z      = -2
    @commands = []
    @maps = pbMapTree
    @addGlobalOffset = (addGlobal) ? 1 : 0
    @index = 0
    for i in 0...@maps.length
      @index = i+@addGlobalOffset if @maps[i][0]==selmap
    end
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    if @addGlobalOffset==1
      @commands.push(_INTL("[GLOBAL]"))
    end
    for i in 0...@maps.length
      @commands.push(sprintf("%s%03d %s",("  "*@maps[i][2]),@maps[i][0],@maps[i][1]))
    end
    return @commands
  end

  def value(index)
    if @addGlobalOffset==1
      return 0 if index==0
    end
    return (index<0) ? -1 : @maps[index-@addGlobalOffset][0]
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    return if index==0 && @addGlobalOffset==1
    @sprite.bitmap = createMinimap(@maps[index-@addGlobalOffset][0])
    @sprite.ox = @sprite.bitmap.width/2
    @sprite.oy = @sprite.bitmap.height/2
  end
end



class SpeciesLister
  def initialize(selection,includeNew=false)
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @trainers = nil
    @index = 0
  end

  def dispose; end
  def setViewport(viewport); end

  def startIndex
    return @index
  end

  def commands   # Sorted alphabetically
    @commands.clear
    @ids.clear
    cmds = []
    for i in 1..PBSpecies.maxValue
      cname = getConstantName(PBSpecies,i) rescue next
      name = PBSpecies.getName(i)
      cmds.push([i,name]) if name && name!=""
    end
    cmds.sort! { |a,b| a[1]<=>b[1] }
    if @includeNew
      @commands.push(_INTL("[NEW SPECIES]"))
      @ids.push(-1)
    end
    for i in cmds
      @commands.push(sprintf("%03d: %s",i[0],i[1]))
      @ids.push(i[0])
    end
    @index = @selection
    @index = @commands.length-1 if @index>=@commands.length
    @index = 0 if @index<0
    return @commands
  end

  def value(index)
    return nil if index<0
    return @ids[index]
  end

  def refresh(index); end
end



class ItemLister
  def initialize(selection,includeNew=false)
    @sprite = IconSprite.new(0,0)
    @sprite = ItemIconSprite.new(Graphics.width*3/4,Graphics.height/2,-1)
    @sprite.z = 2
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @trainers = nil
    @index = 0
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands   # Sorted alphabetically
    @commands.clear
    @ids.clear
    @itemdata = pbLoadItemsData
    cmds = []
    for i in 1..PBItems.maxValue
      next if !@itemdata[i]
      name = @itemdata[i][ITEM_NAME]
      if name && name!="" && @itemdata[i][ITEM_POCKET]!=0
        cmds.push([i,name])
      end
    end
    cmds.sort! { |a,b| a[1]<=>b[1] }
    if @includeNew
      @commands.push(_INTL("[NEW ITEM]"))
      @ids.push(-1)
    end
    for i in cmds
      @commands.push(sprintf("%03d: %s",i[0],i[1]))
      @ids.push(i[0])
    end
    @index = @selection
    @index = @commands.length-1 if @index>=@commands.length
    @index = 0 if @index<0
    return @commands
  end

  def value(index)
    return nil if index<0
    return @ids[index]
  end

  def refresh(index)
    @sprite.item = @ids[index]
  end
end



class TrainerTypeLister
  def initialize(selection,includeNew)
    @sprite = IconSprite.new(0,0)
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width * 3 / 4
    @sprite.y      = (Graphics.height - 64) / 2 + 64
    @sprite.z      = 2
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @trainers = nil
    @index = 0
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    @trainers = pbLoadTrainerTypesData
    if @includeNew
      @commands.push(_INTL("[NEW TRAINER TYPE]"))
      @ids.push(-1)
    end
    @trainers.length.times do |i|
      next if !@trainers[i]
      @commands.push(sprintf("%3d: %s",i,@trainers[i][2]))
      @ids.push(@trainers[i][0])
    end
    @commands.length.times do |i|
      @index = i if @ids[i]==@selection
    end
    return @commands
  end

  def value(index)
    return nil if index<0
    return [-1] if @ids[index]==-1
    return @trainers[@ids[index]]
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    begin
      @sprite.setBitmap(pbTrainerSpriteFile(@ids[index]),0)
    rescue
      @sprite.setBitmap(nil)
    end
    sprite_width = @sprite.bitmap.width
    sprite_height = @sprite.bitmap.height
    @sprite.ox = sprite_width/2
    @sprite.oy = sprite_height/2
    scale_x = (Graphics.width/2).to_f/sprite_width
    scale_y = (Graphics.height-64).to_f/sprite_height
    if scale_x<1.0 || scale_y<1.0
      min_scale = [scale_x, scale_y].min
      @sprite.zoom_x = @sprite.zoom_y = min_scale
    else
      @sprite.zoom_x = @sprite.zoom_y = 1.0
    end
  end
end



class TrainerBattleLister
  def initialize(selection,includeNew)
    @sprite = IconSprite.new
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width*3/4
    @sprite.y      = (Graphics.height/2)+32
    @sprite.z      = 2
    @pkmnList = Window_UnformattedTextPokemon.new()
    @pkmnList.x      = Graphics.width/2
    @pkmnList.y      = Graphics.height-64
    @pkmnList.width  = Graphics.width/2
    @pkmnList.height = 64
    @pkmnList.z      = 3
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @trainers = nil
    @index = 0
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
    @pkmnList.dispose
  end

  def setViewport(viewport)
    @sprite.viewport   = viewport
    @pkmnList.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    @trainers = pbLoadTrainersData
    if @includeNew
      @commands.push(_INTL("[NEW TRAINER BATTLE]"))
      @ids.push(-1)
    end
    @trainers.length.times do |i|
      next if !@trainers[i]
      if @trainers[i][4]>0
        # TrainerType TrainerName (version) xPartySize
        @commands.push(_ISPRINTF("{1:s} {2:s} ({3:d}) x{4:d}",
           PBTrainers.getName(@trainers[i][0]),@trainers[i][1],@trainers[i][4],
           @trainers[i][3].length))
      else
        # TrainerType TrainerName xPartySize
        @commands.push(_ISPRINTF("{1:s} {2:s} x{3:d}",
           PBTrainers.getName(@trainers[i][0]),@trainers[i][1],
           @trainers[i][3].length))
      end
      # Trainer type ID
      @ids.push(@trainers[i][0])
    end
    @index =  @selection
    @index = @commands.length-1 if @index>=@commands.length
    @index = 0 if @index<0
    return @commands
  end

  def value(index)
    return nil if index<0
    return [-1,nil] if index==0 && @includeNew
    realIndex = (@includeNew) ? index-1 : index
    return [realIndex,@trainers[realIndex]]
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    begin
      @sprite.setBitmap(pbTrainerSpriteFile(@ids[index]),0)
    rescue
      @sprite.setBitmap(nil)
    end
    @sprite.ox = @sprite.bitmap.width/2
    @sprite.oy = @sprite.bitmap.height
    text = ""
    if !@includeNew || index>0
      @trainers[(@includeNew) ? index-1 : index][3].each_with_index do |p,i|
        text += "\r\n" if i>0
        text += sprintf("%s Lv.%d",PBSpecies.getName(p[TPSPECIES]),p[TPLEVEL])
      end
    end
    @pkmnList.text = text
    @pkmnList.resizeHeightToFit(text,Graphics.width/2)
    @pkmnList.y = Graphics.height-@pkmnList.height
  end
end
