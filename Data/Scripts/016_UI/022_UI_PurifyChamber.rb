#===============================================================================
#
#===============================================================================
class Player < Trainer
  attr_accessor :has_snag_machine
  attr_accessor :seen_purify_chamber

  alias __shadowPkmn__initialize initialize unless private_method_defined?(:__shadowPkmn__initialize)
  def initialize(name, trainer_type)
    __shadowPkmn__initialize(name, trainer_type)
    @has_snag_machine    = false
    @seen_purify_chamber = false
  end
end

class PokemonGlobalMetadata
  attr_writer :purifyChamber

  def purifyChamber
    @purifyChamber = PurifyChamber.new if !@purifyChamber
    return @purifyChamber
  end
end

#===============================================================================
# General purpose utilities
#===============================================================================
def pbDrawGauge(bitmap, rect, color, value, maxValue)
  return if !bitmap
  bitmap.fill_rect(rect.x, rect.y, rect.width, rect.height, Color.new(0, 0, 0))
  width = (maxValue <= 0) ? 0 : (rect.width - 4) * value / maxValue
  if rect.width >= 4 && rect.height >= 4
    bitmap.fill_rect(rect.x + 2, rect.y + 2, rect.width - 4, rect.height - 4, Color.new(248, 248, 248))
    bitmap.fill_rect(rect.x + 2, rect.y + 2, width, rect.height - 4, color)
  end
end

def calcPoint(x, y, distance, angle) # angle in degrees
  angle -= (angle / 360.0).floor * 360 # normalize
  angle = (angle / 360.0) * (2 * Math::PI) # convert to radians
  angle = -angle % (2 * Math::PI) # normalize radians
  point = [(Math.cos(angle) * distance), (Math.sin(angle) * distance)]
  point[0] += x
  point[1] += y
  return point
end

#===============================================================================
#
#===============================================================================
class PurifyChamberSet
  attr_reader :shadow   # The Shadow Pokémon in the middle
  attr_reader :facing   # Index in list of Pokémon the Shadow Pokémon is facing

  def partialSum(x)
    return ((x * x) + x) / 2   # pattern: 1, 3, 6, 10, 15, 21, 28, ...
  end

  def length
    return @list.length
  end

  def initialize
    @list = []
    @facing = 0
  end

  def facing=(value)
    if value >= 0 && value < @list.length
      @facing = value
    end
  end

  def shadow=(value)
    if value.nil? || value.shadowPokemon?
      @shadow = value
    end
  end

  # Main component is tempo
  # Boosted if center has advantage over facing Pokemon
  # Boosted based on number of best circles
  def flow
    ret = 0
    return 0 if !@shadow
    @list.length.times do |i|
      ret += (PurifyChamberSet.isSuperEffective(@list[i], @list[(i + 1) % @list.length])) ? 1 : 0
    end
    if @list[@facing]
      ret += PurifyChamberSet.isSuperEffective(@shadow, @list[@facing]) ? 1 : 0
    end
    return ret + (@list.length / 2)
  end

  def shadowAffinity
    return 0 if @facing < 0 || @facing >= @list.length || !@shadow
    return (PurifyChamberSet.isSuperEffective(@shadow, @list[@facing])) ? 2 : 1
  end

  def affinity(i)
    return 0 if i < 0 || i >= @list.length
    return (PurifyChamberSet.isSuperEffective(@list[i], @list[(i + 1) % @list.length])) ? 2 : 1
  end

  # Tempo refers to the type advantages of each Pokemon in a certain set in a
  # clockwise direction. Tempo also depends on the number of Pokemon in the set
  def tempo
    ret = 0
    @list.length.times do |i|
      ret += (PurifyChamberSet.isSuperEffective(@list[i], @list[(i + 1) % @list.length])) ? 1 : 0
    end
    return partialSum(@list.length) + ret
  end

  def list
    return @list.clone
  end

  def [](index)
    return @list[index]
  end

  def insertAfter(index, value)
    return if self.length >= PurifyChamber::SETSIZE
    return if index < 0 || index >= PurifyChamber::SETSIZE
    unless value&.shadowPokemon?
      @list.insert(index + 1, value)
      @list.compact!
      @facing += 1 if @facing > index && value
      @facing = [[@facing, @list.length - 1].min, 0].max
    end
  end

  def insertAt(index, value)
    return if index < 0 || index >= PurifyChamber::SETSIZE
    unless value&.shadowPokemon?
      @list[index] = value
      @list.compact!
      @facing = [[@facing, @list.length - 1].min, 0].max
    end
  end

  # Purify Chamber treats Normal/Normal matchup as super effective
  def self.typeAdvantage(p1, p2)
    return true if p1 == :NORMAL && p2 == :NORMAL
    return Effectiveness.super_effective_type?(p1, p2)
  end

  def self.isSuperEffective(p1, p2)
    return true if typeAdvantage(p1.types[0], p2.types[0])
    return true if p2.types[1] && typeAdvantage(p1.types[0], p2.types[1])
    return false if p1.types[1].nil?
    return true if typeAdvantage(p1.types[1], p2.types[0])
    return true if p2.types[1] && typeAdvantage(p1.types[1], p2.types[1])
    return false
  end
end

#===============================================================================
#
#===============================================================================
class PurifyChamber
  attr_reader :sets
  attr_reader :currentSet

  NUMSETS = 9
  SETSIZE = 4

  def self.maximumTempo   # Calculates the maximum possible tempo
    x = SETSIZE + 1
    return (((x * x) + x) / 2) - 1
  end

  def initialize
    @sets = []
    @currentSet = 0
    NUMSETS.times { |i| @sets[i] = PurifyChamberSet.new }
  end

  def currentSet=(value)
    @currentSet = value if value >= 0 && value < NUMSETS
  end

  # Number of regular Pokemon in a set
  def setCount(set)
    return @sets[set].length
  end

  def setList(set)
    return [] if set < 0 || set >= NUMSETS
    return @sets[set].list
  end

  def chamberFlow(chamber)   # for speeding up purification
    return 0 if chamber < 0 || chamber >= NUMSETS
    return @sets[chamber].flow
  end

  def getShadow(chamber)
    return nil if chamber < 0 || chamber >= NUMSETS
    return @sets[chamber].shadow
  end

  def setShadow(chamber, value)   # allow only "shadow" Pokemon
    return if chamber < 0 || chamber >= NUMSETS
    @sets[chamber].shadow = value
  end

  def switch(set1, set2)
    return if set1 < 0 || set1 >= NUMSETS
    return if set2 < 0 || set2 >= NUMSETS
    s = @sets[set1]
    @sets[set1] = @sets[set2]
    @sets[set2] = s
  end

  def insertAfter(set, index, value)
    return if set < 0 || set >= NUMSETS
    @sets[set].insertAfter(index, value)
  end

  def insertAt(set, index, value)
    return if set < 0 || set >= NUMSETS
    @sets[set].insertAt(index, value)
  end

  def [](chamber, slot = nil)
    if slot.nil?
      return @sets[chamber]
    end
    return nil if chamber < 0 || chamber >= NUMSETS
    return nil if slot < 0 || slot >= SETSIZE
    return @sets[chamber][slot]
  end

  def isPurifiableIgnoreRegular?(set)
    shadow = getShadow(set)
    return false if !shadow
    return false if shadow.heart_gauge != 0
    # Define an exception for Lugia
    if shadow.isSpecies?(:LUGIA)
      maxtempo = PurifyChamber.maximumTempo
      NUMSETS.times do |i|
        return false if @sets[i].tempo != maxtempo
      end
    end
    return true
  end

  def isPurifiable?(set)
    isPurifiableIgnoreRegular?(set) && setCount(set) > 0
  end

  # Called upon each step taken in the overworld
  def update
    NUMSETS.times do |set|
      next if !@sets[set].shadow || @sets[set].shadow.heart_gauge <= 0
      # If a Shadow Pokemon and a regular Pokemon are on the same set
      flow = self.chamberFlow(set)
      @sets[set].shadow.adjustHeart(-flow)
      next if !isPurifiable?(set)
      pbMessage(_INTL("Your {1} in the Purify Chamber is ready for purification!",
                      @sets[set].shadow.name))
    end
  end

  def debugAddShadow(set, species)
    pkmn = Pokemon.new(species, 1)
    pkmn.makeShadow
    setShadow(set, pkmn)
  end

  def debugAddNormal(set, species)
    pkmn = Pokemon.new(species, 1)
    insertAfter(set, setCount(set), pkmn)
  end

  def debugAdd(set, shadow, type1, type2 = nil)
    pkmn = PseudoPokemon.new(shadow, type1, type2 || type1)
    if pkmn.shadowPokemon?
      self.setShadow(set, pkmn)
    else
      self.insertAfter(set, setCount(set), pkmn)
    end
  end
end

#===============================================================================
#
#===============================================================================
module PurifyChamberHelper
  def self.pbGetPokemon2(chamber, set, position)
    if position == 0
      return chamber.getShadow(set)
    elsif position > 0
      position -= 1
      if position.even?
        return chamber[set, position / 2]
      else # In between two indices
        return nil
      end
    end
    return nil
  end

  def self.pbGetPokemon(chamber, position)
    if position == 0
      return chamber.getShadow(chamber.currentSet)
    elsif position > 0
      position -= 1
      if position.even?
        return chamber[chamber.currentSet, position / 2]
      else # In between two indices
        return nil
      end
    end
    return nil
  end

  def self.adjustOnInsert(position)
    if position > 0
      position -= 1
      oldpos = position / 2
      if position.even?
        return position + 1
      else
        return ((oldpos + 1) * 2) + 1
      end
    end
    return position
  end

  def self.pbSetPokemon(chamber, position, value)
    if position == 0
      chamber.setShadow(chamber.currentSet, value)
    elsif position > 0
      position -= 1
      if position.even?
        chamber.insertAt(chamber.currentSet, position / 2, value)
      else # In between two indices
        chamber.insertAfter(chamber.currentSet, position / 2, value)
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class PurifyChamberScreen
  def initialize(scene)
    @scene = scene
    @chamber = $PokemonGlobal.purifyChamber
#    for j in 0...PurifyChamber::NUMSETS
#      @chamber.debugAddShadow(j,rand(100)+1)
#      @chamber[j].shadow.heart_gauge = 0
#      for i in 0...PurifyChamber::SETSIZE
#        @chamber.debugAddNormal(j,rand(100)+1)
#      end
#    end
  end

  def pbPlace(pkmn, position)
    return false if !pkmn
    if pkmn.egg?
      @scene.pbDisplay(_INTL("Can't place an egg there."))
      return false
    end
    if position == 0
      if pkmn.shadowPokemon?
        # Remove from storage and place in set
        oldpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, position)
        if oldpkmn
          @scene.pbShift(position, pkmn)
        else
          @scene.pbPlace(position, pkmn)
        end
        PurifyChamberHelper.pbSetPokemon(@chamber, position, pkmn)
        @scene.pbRefresh
      else
        @scene.pbDisplay(_INTL("Only a Shadow Pokémon can go there."))
        return false
      end
    elsif position >= 1
      if pkmn.shadowPokemon?
        @scene.pbDisplay(_INTL("Can't place a Shadow Pokémon there."))
        return false
      else
        oldpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, position)
        if oldpkmn
          @scene.pbShift(position, pkmn)
        else
          @scene.pbPlace(position, pkmn)
        end
        PurifyChamberHelper.pbSetPokemon(@chamber, position, pkmn)
        @scene.pbRefresh
      end
    end
    return true
  end

  def pbPlacePokemon(pos, position)
    return false if !pos
    pkmn = $PokemonStorage[pos[0], pos[1]]
    if pbPlace(pkmn, position)
      $PokemonStorage.pbDelete(pos[0], pos[1])
      return true
    end
    return false
  end

  def pbOnPlace(pkmn)
    set = @chamber.currentSet
    if @chamber.setCount(set) == 0 && @chamber.isPurifiableIgnoreRegular?(set)
      pkmn = @chamber.getShadow(set)
      @scene.pbDisplay(
        _INTL("This {1} is ready to open its heart. However, there must be at least one regular Pokémon in the set to perform a purification ceremony.",
              pkmn.name)
      )
    end
  end

  def pbOpenSetDetail
    chamber = @chamber
    @scene.pbOpenSetDetail(chamber.currentSet)
    heldpkmn = nil
    loop do
      # Commands
      # array[0]==0 - a position was chosen
      # array[0]==1 - a new set was chosen
      # array[0]==2 - choose Pokemon command
      cmd = @scene.pbSetScreen
      if cmd[0] == 0
        # Place Pokemon in the set
        curpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, cmd[1])
        if curpkmn || heldpkmn
          commands = [_INTL("MOVE"), _INTL("SUMMARY"), _INTL("WITHDRAW")]
          if curpkmn && heldpkmn
            commands[0] = _INTL("EXCHANGE")
          elsif heldpkmn
            commands[0] = _INTL("PLACE")
          end
          cmdReplace = -1
          cmdRotate = -1
          if !heldpkmn && curpkmn && cmd[1] == 0 &&
             @chamber[@chamber.currentSet].length > 0
            commands[cmdRotate = commands.length] = _INTL("ROTATE")
          end
          if !heldpkmn && curpkmn
            commands[cmdReplace = commands.length] = _INTL("REPLACE")
          end
          commands.push(_INTL("CANCEL"))
          choice = @scene.pbShowCommands(
            _INTL("What shall I do with this {1}?", heldpkmn ? heldpkmn.name : curpkmn.name),
            commands
          )
          if choice == 0
            if heldpkmn
              if pbPlace(heldpkmn, cmd[1]) # calls place or shift as appropriate
                if curpkmn
                  heldpkmn = curpkmn # Pokemon was shifted
                else
                  pbOnPlace(heldpkmn)
                  @scene.pbPositionHint(PurifyChamberHelper.adjustOnInsert(cmd[1]))
                  heldpkmn = nil # Pokemon was placed
                end
              end
            else
              @scene.pbMove(cmd[1])
              PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], nil)
              @scene.pbRefresh
              heldpkmn = curpkmn
            end
          elsif choice == 1
            @scene.pbSummary(cmd[1], heldpkmn)
          elsif choice == 2
            if pbBoxesFull?
              @scene.pbDisplay("All boxes are full.")
            elsif heldpkmn
              @scene.pbWithdraw(cmd[1], heldpkmn)
              $PokemonStorage.pbStoreCaught(heldpkmn)
              heldpkmn = nil
              @scene.pbRefresh
            else
              # Store and delete Pokemon.
              @scene.pbWithdraw(cmd[1], heldpkmn)
              $PokemonStorage.pbStoreCaught(curpkmn)
              PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], nil)
              @scene.pbRefresh
            end
          elsif cmdRotate >= 0 && choice == cmdRotate
            count = @chamber[@chamber.currentSet].length
            nextPos = @chamber[@chamber.currentSet].facing
            if count > 0
              @scene.pbRotate((nextPos + 1) % count)
              @chamber[@chamber.currentSet].facing = (nextPos + 1) % count
              @scene.pbRefresh
            end
          elsif cmdReplace >= 0 && choice == cmdReplace
            pos = @scene.pbChoosePokemon
            if pos
              newpkmn = $PokemonStorage[pos[0], pos[1]]
              if newpkmn
                if (newpkmn.shadowPokemon?) == (curpkmn.shadowPokemon?)
                  @scene.pbReplace(cmd, pos)
                  PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], newpkmn)
                  $PokemonStorage[pos[0], pos[1]] = curpkmn
                  @scene.pbRefresh
                  pbOnPlace(curpkmn)
                else
                  @scene.pbDisplay(_INTL("That Pokémon can't be placed there."))
                end
              end
            end
          end
        else  # No current Pokemon
          pos = @scene.pbChoosePokemon
          if pbPlacePokemon(pos, cmd[1])
            curpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, cmd[1])
            pbOnPlace(curpkmn)
            @scene.pbPositionHint(PurifyChamberHelper.adjustOnInsert(cmd[1]))
          end
        end
      elsif cmd[0] == 1 # Change the active set
        @scene.pbChangeSet(cmd[1])
        chamber.currentSet = cmd[1]
      elsif cmd[0] == 2 # Choose a Pokemon
        pos = @scene.pbChoosePokemon
        pkmn = pos ? $PokemonStorage[pos[0], pos[1]] : nil
        heldpkmn = pkmn if pkmn
      else # cancel
        if heldpkmn
          @scene.pbDisplay("You're holding a Pokémon!")
        else
          if !@scene.pbConfirm("Continue editing sets?")
            break
          end
        end
      end
    end
    if pbCheckPurify
      @scene.pbDisplay(_INTL("There is a Pokémon that is ready to open its heart!\1"))
      @scene.pbCloseSetDetail
      pbDoPurify
      return false
    else
      @scene.pbCloseSetDetail
      return true
    end
  end

  def pbDisplay(msg)
    @scene.pbDisplay(msg)
  end

  def pbConfirm(msg)
    @scene.pbConfirm(msg)
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbCheckPurify
    purifiables = []
    PurifyChamber::NUMSETS.times do |set|
      if @chamber.isPurifiable?(set) # if ready for purification
        purifiables.push(set)
      end
    end
    return purifiables.length > 0
  end

  def pbDoPurify
    purifiables = []
    PurifyChamber::NUMSETS.times do |set|
      if @chamber.isPurifiable?(set) # if ready for purification
        purifiables.push(set)
      end
    end
    purifiables.length.times do |i|
      set = purifiables[i]
      @chamber.currentSet = set
      @scene.pbOpenSet(set)
      @scene.pbPurify
      pbPurify(@chamber[set].shadow, self)
      pbStorePokemon(@chamber[set].shadow)
      @chamber.setShadow(set, nil) # Remove shadow Pokemon from set
      if (i + 1) != purifiables.length
        @scene.pbDisplay(_INTL("There is another Pokémon that is ready to open its heart!"))
        if !@scene.pbConfirm("Would you like to switch sets?")
          @scene.pbCloseSet
          break
        end
      end
      @scene.pbCloseSet
    end
  end

  def pbStartPurify
    chamber = @chamber
    @scene.pbStart(chamber)
    if pbCheckPurify
      pbDoPurify
      @scene.pbEnd
      return
    end
    @scene.pbOpenSet(chamber.currentSet)
    loop do
      set = @scene.pbChooseSet
      if set < 0
        if !@scene.pbConfirm("Continue viewing holograms?")
          break
        end
      else
        chamber.currentSet = set
        cmd = @scene.pbShowCommands(_INTL("What do you want to do?"),
                                    [_INTL("EDIT"), _INTL("SWITCH"), _INTL("CANCEL")])
        case cmd
        when 0   # edit
          if !pbOpenSetDetail
            break
          end
        when 1   # switch
          chamber.currentSet = set
          newSet = @scene.pbSwitch(set)
          chamber.switch(set, newSet)
          chamber.currentSet = newSet
          @scene.pbRefresh
        end
      end
    end
    @scene.pbCloseSet
    @scene.pbEnd
  end
end

#===============================================================================
#
#===============================================================================
class Window_PurifyChamberSets < Window_DrawableCommand
  attr_reader :switching

  def initialize(chamber, x, y, width, height, viewport = nil)
    @chamber = chamber
    @switching = -1
    super(x, y, width, height, viewport)
  end

  def itemCount
    return PurifyChamber::NUMSETS
  end

  def switching=(value)
    @switching = value
    refresh
  end

  def drawItem(index, _count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    if index == @switching
      textpos.push([(index + 1).to_s, rect.x, rect.y, false, Color.new(248, 0, 0), self.shadowColor])
    else
      textpos.push([(index + 1).to_s, rect.x, rect.y, false, self.baseColor, self.shadowColor])
    end
    if @chamber.setCount(index) > 0
      pbDrawGauge(self.contents, Rect.new(rect.x + 16, rect.y + 6, 48, 8),
                  Color.new(0, 0, 256), @chamber[index].tempo, PurifyChamber.maximumTempo)
    end
    if @chamber.getShadow(index)
      pbDrawGauge(self.contents, Rect.new(rect.x + 16, rect.y + 18, 48, 8),
                  Color.new(192, 0, 256),
                  @chamber.getShadow(index).heart_gauge,
                  @chamber.getShadow(index).max_gauge_size)
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class DirectFlowDiagram
  def initialize(viewport = nil)
    @points = []
    @angles = []
    @viewport = viewport
    @strength = 0
    @offset = 0
    @x = 306
    @y = 158
    @distance = 96
  end

# 0=none, 1=weak, 2=strong
  def setFlowStrength(strength)
    @strength = strength
  end

  def visible=(value)
    @points.each do |point|
      point.visible = value
    end
  end

  def dispose
    @points.each do |point|
      point.dispose
    end
  end

  def ensurePoint(j)
    if !@points[j] || @points[j].disposed?
      @points[j] = BitmapSprite.new(8, 8, @viewport)
      @points[j].bitmap.fill_rect(0, 0, 8, 8, Color.new(0, 0, 0))
    end
    @points[j].tone = (@strength == 2) ? Tone.new(232, 232, 248) : Tone.new(16, 16, 232)
    @points[j].visible = (@strength != 0)
  end

  def update
    @points.each do |point|
      point.update
      point.visible = false
    end
    j = 0
    i = 0
    while i < @distance
      o = (i + @offset) % @distance
      if o >= 0 && o < @distance
        ensurePoint(j)
        pt = calcPoint(@x, @y, o, @angle)
        @points[j].x = pt[0]
        @points[j].y = pt[1]
        j += 1
      end
      i += (@strength == 2) ? 16 : 32
    end
    @offset += (@strength == 2) ? 3 : 2
    @offset %= @distance
  end

  def color=(value)
    @points.each do |point|
      point.color = value
    end
  end

  def setAngle(angle1)
    @angle = angle1 - ((angle1 / 360).floor * 360)
  end
end

#===============================================================================
#
#===============================================================================
class FlowDiagram
  def initialize(viewport = nil)
    @points = []
    @angles = []
    @viewport = viewport
    @strength = 0
    @offset = 0
    @x = 306
    @y = 158
    @distance = 96
  end

# 0=none, 1=weak, 2=strong
  def setFlowStrength(strength)
    @strength = strength
  end

  def visible=(value)
    @points.each do |point|
      point.visible = value
    end
  end

  def dispose
    @points.each do |point|
      point.dispose
    end
  end

  def ensurePoint(j)
    if !@points[j] || @points[j].disposed?
      @points[j] = BitmapSprite.new(8, 8, @viewport)
      @points[j].bitmap.fill_rect(0, 0, 8, 8, Color.new(0, 0, 0))
    end
    @points[j].tone = (@strength == 2) ? Tone.new(232, 232, 248) : Tone.new(16, 16, 232)
    @points[j].visible = (@strength != 0)
  end

  def withinRange(angle, startAngle, endAngle)
    if startAngle > endAngle
      return (angle >= startAngle || angle <= endAngle) &&
             (angle >= 0 && angle <= 360)
    else
      return (angle >= startAngle && angle <= endAngle)
    end
  end

  def update
    @points.each do |point|
      point.update
      point.visible = false
    end
    j = 0
    i = 0
    while i < 360
      angle = (i + @offset) % 360
      if withinRange(angle, @startAngle, @endAngle)
        ensurePoint(j)
        pt = calcPoint(@x, @y, @distance, angle)
        @points[j].x = pt[0]
        @points[j].y = pt[1]
        j += 1
      end
      i += (@strength == 2) ? 10 : 20
    end
    @offset -= (@strength == 2) ? 3 : 2
    @offset %= (360 * 6)
  end

  def color=(value)
    @points.each do |point|
      point.color = value
    end
  end

  def setRange(angle1, angle2)
    @startAngle = angle1 - ((angle1 / 360).floor * 360)
    @endAngle = angle2 - ((angle2 / 360).floor * 360)
    if @startAngle == @endAngle && angle1 != angle2
      @startAngle = 0
      @endAngle = 359.99
    end
  end
end

#===============================================================================
#
#===============================================================================
class PurifyChamberSetView < Sprite
  attr_reader :set
  attr_reader :cursor
  attr_reader :heldpkmn

  def initialize(chamber, set, viewport = nil)
    super(viewport)
    @set = set
    @heldpkmn = nil
    @cursor = -1
    @view = BitmapSprite.new(64, 64, viewport)
    @view.bitmap.fill_rect(8, 8, 48, 48, Color.new(255, 255, 255))
    @view.bitmap.fill_rect(10, 10, 44, 44, Color.new(255, 255, 255, 128))
    @info = BitmapSprite.new(Graphics.width - 112, 48, viewport)
    @flows = []
    @directflow = DirectFlowDiagram.new(viewport)
    @directflow.setAngle(0)
    @directflow.setFlowStrength(1)
    @__sprites = []
    @__sprites[0] = PokemonIconSprite.new(nil, viewport)
    @__sprites[0].setOffset
    (PurifyChamber::SETSIZE * 2).times do |i|
      @__sprites[i + 1] = PokemonIconSprite.new(nil, viewport)
      @__sprites[i + 1].setOffset
    end
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)] = PokemonIconSprite.new(nil, viewport)
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].setOffset
    @chamber = chamber
    refresh
  end

  def refreshFlows
    @flows.each do |flow|
      flow.setFlowStrength(0)
    end
    setcount = @chamber.setCount(@set)
    setcount.times do |i|
      if !@flows[i]
        @flows[i] = FlowDiagram.new(self.viewport)
      end
      angle = 360 - (i * 360 / setcount)
      angle += 90 # start at 12 not 3 o'clock
      endAngle = angle - (360 / setcount)
      @flows[i].setRange(endAngle, angle)
      @flows[i].setFlowStrength(@chamber[@set].affinity(i))
    end
  end

  def moveCursor(button)
    points = [@chamber.setCount(@set) * 2, 1].max
    oldcursor = @cursor
    if @cursor == 0 && points > 0
      @cursor = 1 if button == Input::UP
      @cursor = (points * 1 / 4) + 1 if button == Input::RIGHT
      @cursor = (points * 2 / 4) + 1 if button == Input::DOWN
      @cursor = (points * 3 / 4) + 1 if button == Input::LEFT
    elsif @cursor > 0
      pos = @cursor - 1
      if @chamber.setCount(@set) == PurifyChamber::SETSIZE
        points = [points / 2, 1].max
        pos /= 2
      end
      seg = pos * 8 / points
      case seg
      when 7, 0
        pos -= 1 if button == Input::LEFT
        pos += 1 if button == Input::RIGHT
        pos = nil if button == Input::DOWN
      when 1, 2
        pos -= 1 if button == Input::UP
        pos += 1 if button == Input::DOWN
        pos = nil if button == Input::LEFT
      when 3, 4
        pos -= 1 if button == Input::RIGHT
        pos += 1 if button == Input::LEFT
        pos = nil if button == Input::UP
      when 5, 6
        pos -= 1 if button == Input::DOWN
        pos += 1 if button == Input::UP
        pos = nil if button == Input::RIGHT
      end
      if pos.nil?
        @cursor = 0
      else
        pos -= (pos / points).floor * points # modulus
        pos *= 2 if @chamber.setCount(@set) == PurifyChamber::SETSIZE
        @cursor = pos + 1
      end
    end
    if @cursor != oldcursor
      refresh
    end
  end

  def checkCursor(index)
    if @cursor == index
      @view.x = @__sprites[index].x - @view.bitmap.width / 2
      @view.y = @__sprites[index].y - @view.bitmap.height / 2
      @view.visible = true
    end
  end

  def refresh
    pkmn = @chamber.getShadow(@set)
    @view.visible = false
    @info.bitmap.fill_rect(0, 0, @info.bitmap.width, @info.bitmap.height, Color.new(0, 248, 0))
    pbSetSmallFont(@info.bitmap)
    textpos = []
    if pkmn
      if pkmn.types.length == 1
        textpos.push([_INTL("{1}  Lv.{2}  {3}", pkmn.name, pkmn.level,
                            GameData::Type.get(pkmn.types[0]).name),
                      2, 6, 0, Color.new(248, 248, 248), Color.new(128, 128, 128)])
      else
        textpos.push([_INTL("{1}  Lv.{2}  {3}/{4}", pkmn.name, pkmn.level,
                            GameData::Type.get(pkmn.types[0]).name,
                            GameData::Type.get(pkmn.types[1]).name),
                      2, 6, 0, Color.new(248, 248, 248), Color.new(128, 128, 128)])
      end
      textpos.push([_INTL("FLOW"), 2 + (@info.bitmap.width / 2), 30, 0,
                    Color.new(248, 248, 248), Color.new(128, 128, 128)])
      # draw heart gauge
      pbDrawGauge(@info.bitmap, Rect.new(@info.bitmap.width * 3 / 4, 8, @info.bitmap.width * 1 / 4, 8),
                  Color.new(192, 0, 256), pkmn.heart_gauge, pkmn.max_gauge_size)
      # draw flow gauge
      pbDrawGauge(@info.bitmap, Rect.new(@info.bitmap.width * 3 / 4, 32, @info.bitmap.width * 1 / 4, 8),
                  Color.new(0, 0, 248), @chamber.chamberFlow(@set), 7)
    end
    if @chamber.setCount(@set) > 0
      textpos.push([_INTL("TEMPO"), 2, 30, 0,
                    Color.new(248, 248, 248), Color.new(128, 128, 128)])
      # draw tempo gauge
      pbDrawGauge(@info.bitmap, Rect.new(@info.bitmap.width * 1 / 4, 32, @info.bitmap.width * 1 / 4, 8),
                  Color.new(0, 0, 248), @chamber[@set].tempo, PurifyChamber.maximumTempo)
    end
    pbDrawTextPositions(@info.bitmap, textpos)
    @info.x = Graphics.width - @info.bitmap.width
    @info.y = Graphics.height - @info.bitmap.height
    @__sprites[0].pokemon = pkmn
    @__sprites[0].x = 306
    @__sprites[0].y = 158
    @__sprites[0].z = 2
    @directflow.setAngle(angle)
    @directflow.setFlowStrength(0)
    checkCursor(0)
    points = [@chamber.setCount(@set) * 2, 1].max
    setList = @chamber.setList(@set)
    refreshFlows
    (PurifyChamber::SETSIZE * 2).times do |i|
      pkmn = (i.odd? || i >= points) ? nil : setList[i / 2]
      angle = 360 - (i * 360 / points)
      angle += 90   # start at 12 not 3 o'clock
      if pkmn && @chamber[@set].facing == i / 2
        @directflow.setAngle(angle)
        @directflow.setFlowStrength(@chamber[@set].shadowAffinity)
      end
      point = calcPoint(306, 158, 96, angle)
      @__sprites[i + 1].x = point[0]
      @__sprites[i + 1].y = point[1]
      @__sprites[i + 1].z = 2
      @__sprites[i + 1].pokemon = pkmn
      checkCursor(i + 1)
    end
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].pokemon = @heldpkmn
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].visible = @view.visible
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].x = @view.x + @view.bitmap.width / 2
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].y = @view.y + @view.bitmap.height / 2
    @__sprites[1 + (PurifyChamber::SETSIZE * 2)].z = 3
  end

  def getCurrent
    return PurifyChamberHelper.pbGetPokemon(@chamber, @cursor)
  end

  def cursor=(value)
    @cursor = value
    refresh
  end

  def heldpkmn=(value)
    @heldpkmn = value
    refresh
  end

  def set=(value)
    @set = value
    refresh
  end

  def visible=(value)
    super
    @__sprites.each do |sprite|
      sprite.visible = value
    end
    @flows.each do |flow|
      flow.visible = value
    end
    @directflow.visible = value
    @view.visible = value
    @info.visible = value
  end

  def color=(value)
    super
    @__sprites.each do |sprite|
      sprite.color = value.clone
    end
    @flows.each do |flow|
      flow.color = value.clone
    end
    @directflow.color = value.clone
    @view.color = value.clone
    @info.color = value.clone
  end

  def update
    super
    @__sprites.each do |sprite|
      sprite&.update
    end
    @flows.each do |flow|
      flow.update
    end
    @directflow.update
    @view.update
    @info.update
  end

  def dispose
    @__sprites.each do |sprite|
      sprite&.dispose
    end
    @flows.each do |flow|
      flow.dispose
    end
    @directflow.dispose
    @view.dispose
    @info.dispose
    @__sprites.clear
    super
  end
end

#===============================================================================
#
#===============================================================================
class PurifyChamberScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbRefresh
    if @sprites["setview"]
      @sprites["setview"].refresh
      @sprites["setwindow"].refresh
    end
  end

  def pbStart(chamber)
    @chamber = chamber
  end

  def pbEnd
  end

  def pbOpenSet(set)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @viewportmsg = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewportmsg.z = 99999
    addBackgroundOrColoredPlane(@sprites, "bg", "purifychamberbg",
                                Color.new(64, 48, 96), @viewport)
    @sprites["setwindow"] = Window_PurifyChamberSets.new(
      @chamber, 0, 0, 112, Graphics.height, @viewport
    )
    @sprites["setview"] = PurifyChamberSetView.new(@chamber, set, @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].viewport = @viewportmsg
    @sprites["msgwindow"].visible = false
    @sprites["setwindow"].index = set
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbCloseSet
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewportmsg.dispose
  end

  def pbOpenSetDetail(set)
    @sprites["setwindow"].index = set
    @sprites["setview"].set = set
    @sprites["setview"].cursor = 0
  end

  def pbCloseSetDetail
  end

  def pbPurify
    pbRefresh
  end

  def pbMove(_pos)
    @sprites["setview"].heldpkmn = @sprites["setview"].getCurrent
    pbRefresh
  end

  def pbShift(_pos, _heldpoke)
    @sprites["setview"].heldpkmn = @sprites["setview"].getCurrent
    pbRefresh
  end

  def pbPlace(_pos, _heldpoke)
    @sprites["setview"].heldpkmn = nil
    pbRefresh
  end

  def pbReplace(_pos, _storagePos)
    @sprites["setview"].heldpkmn = nil
    pbRefresh
  end

  def pbRotate(facing); end

  def pbWithdraw(_pos, _heldpoke)
    @sprites["setview"].heldpkmn = nil
    pbRefresh
  end

  def pbDisplay(msg)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, false) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbShowCommands(msg, commands)
    UIHelper.pbShowCommands(@sprites["msgwindow"], msg, commands) { pbUpdate }
  end

  def pbSetScreen
    pbDeactivateWindows(@sprites) {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        btn = 0
        btn = Input::DOWN if Input.repeat?(Input::DOWN)
        btn = Input::UP if Input.repeat?(Input::UP)
        btn = Input::RIGHT if Input.repeat?(Input::RIGHT)
        btn = Input::LEFT if Input.repeat?(Input::LEFT)
        if btn != 0
          pbPlayCursorSE
          @sprites["setview"].moveCursor(btn)
        end
        if Input.repeat?(Input::JUMPUP)
          nextset = (@sprites["setview"].set == 0) ? PurifyChamber::NUMSETS - 1 : @sprites["setview"].set - 1
          pbPlayCursorSE
          return [1, nextset]
        elsif Input.repeat?(Input::JUMPDOWN)
          nextset = (@sprites["setview"].set == PurifyChamber::NUMSETS - 1) ? 0 : @sprites["setview"].set + 1
          pbPlayCursorSE
          return [1, nextset]
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          return [0, @sprites["setview"].cursor]
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          return [3, 0]
        end
      end
    }
  end

  def pbChooseSet
    pbActivateWindow(@sprites, "setwindow") {
      oldindex = @sprites["setwindow"].index
      loop do
        if oldindex != @sprites["setwindow"].index
          oldindex = @sprites["setwindow"].index
          @sprites["setview"].set = oldindex
        end
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE
          return @sprites["setwindow"].index
        end
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          return -1
        end
      end
    }
  end

  def pbSwitch(set)
    @sprites["setwindow"].switching = set
    ret = pbChooseSet
    @sprites["setwindow"].switching = -1
    return ret < 0 ? set : ret
  end

  def pbSummary(pos, heldpkmn)
    if heldpkmn
      oldsprites = pbFadeOutAndHide(@sprites)
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      screen.pbStartScreen([heldpkmn], 0)
      pbFadeInAndShow(@sprites, oldsprites)
      return
    end
    party = []
    indexes = []
    startindex = 0
    set = @sprites["setview"].set
    (@chamber.setCount(set) * 2).times do |i|
      p = PurifyChamberHelper.pbGetPokemon2(@chamber, set, i)
      next if !p
      startindex = party.length if i == pos
      party.push(p)
      indexes.push(i)
    end
    return if party.length == 0
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    selection = screen.pbStartScreen(party, startindex)
    @sprites["setview"].cursor = indexes[selection]
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbPositionHint(pos)
    @sprites["setview"].cursor = pos
    pbRefresh
  end

  def pbChangeSet(set)
    @sprites["setview"].set = set
    @sprites["setwindow"].index = set
    @sprites["setwindow"].refresh
    pbRefresh
  end

  def pbChoosePokemon
    visible = pbFadeOutAndHide(@sprites)
    scene = PokemonStorageScene.new
    screen = PokemonStorageScreen.new(scene, $PokemonStorage)
    pos = screen.pbChoosePokemon
    pbRefresh
    pbFadeInAndShow(@sprites, visible)
    return pos
  end
end

#===============================================================================
#
#===============================================================================
def pbPurifyChamber
  $player.seen_purify_chamber = true
  pbFadeOutIn {
    scene = PurifyChamberScene.new
    screen = PurifyChamberScreen.new(scene)
    screen.pbStartPurify
  }
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_menu, :purify_chamber, {
  "name"      => _INTL("Purify Chamber"),
  "order"     => 30,
  "condition" => proc { next $player.seen_purify_chamber },
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]Accessed the Purify Chamber."))
    pbPurifyChamber
    next false
  }
})
