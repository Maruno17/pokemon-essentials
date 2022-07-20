class PokemonBox
  attr_reader   :pokemon
  attr_accessor :name
  attr_accessor :background

  BOX_WIDTH  = 6
  BOX_HEIGHT = 5
  BOX_SIZE   = BOX_WIDTH * BOX_HEIGHT

  def initialize(name, maxPokemon = BOX_SIZE)
    @name = name
    @background = 0
    @pokemon = []
    maxPokemon.times { |i| @pokemon[i] = nil }
  end

  def length
    return @pokemon.length
  end

  def nitems
    ret = 0
    @pokemon.each { |pkmn| ret += 1 if !pkmn.nil? }
    return ret
  end

  def full?
    return nitems == self.length
  end

  def empty?
    return nitems == 0
  end

  def [](i)
    return @pokemon[i]
  end

  def []=(i, value)
    @pokemon[i] = value
  end

  def each
    @pokemon.each { |item| yield item }
  end

  def clear
    @pokemon.clear
  end
end



class PokemonStorage
  attr_reader   :boxes
  attr_accessor :currentBox
  attr_writer   :unlockedWallpapers

  BASICWALLPAPERQTY = 16

  def initialize(maxBoxes = Settings::NUM_STORAGE_BOXES, maxPokemon = PokemonBox::BOX_SIZE)
    @boxes = []
    maxBoxes.times do |i|
      @boxes[i] = PokemonBox.new(_INTL("Box {1}", i + 1), maxPokemon)
      @boxes[i].background = i % BASICWALLPAPERQTY
    end
    @currentBox = 0
    @boxmode = -1
    @unlockedWallpapers = []
    allWallpapers.length.times do |i|
      @unlockedWallpapers[i] = false
    end
  end

  def allWallpapers
    return [
      # Basic wallpapers
      _INTL("Forest"), _INTL("City"), _INTL("Desert"), _INTL("Savanna"),
      _INTL("Crag"), _INTL("Volcano"), _INTL("Snow"), _INTL("Cave"),
      _INTL("Beach"), _INTL("Seafloor"), _INTL("River"), _INTL("Sky"),
      _INTL("Poké Center"), _INTL("Machine"), _INTL("Checks"), _INTL("Simple"),
      # Special wallpapers
      _INTL("Space"), _INTL("Backyard"), _INTL("Nostalgic 1"), _INTL("Torchic"),
      _INTL("Trio 1"), _INTL("PikaPika 1"), _INTL("Legend 1"), _INTL("Team Galactic 1"),
      _INTL("Distortion"), _INTL("Contest"), _INTL("Nostalgic 2"), _INTL("Croagunk"),
      _INTL("Trio 2"), _INTL("PikaPika 2"), _INTL("Legend 2"), _INTL("Team Galactic 2"),
      _INTL("Heart"), _INTL("Soul"), _INTL("Big Brother"), _INTL("Pokéathlon"),
      _INTL("Trio 3"), _INTL("Spiky Pika"), _INTL("Kimono Girl"), _INTL("Revival")
    ]
  end

  def unlockedWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return @unlockedWallpapers
  end

  def isAvailableWallpaper?(i)
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return true if i < BASICWALLPAPERQTY
    return true if @unlockedWallpapers[i]
    return false
  end

  def availableWallpapers
    ret = [[], []]   # Names, IDs
    papers = allWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    papers.length.times do |i|
      next if !isAvailableWallpaper?(i)
      ret[0].push(papers[i])
      ret[1].push(i)
    end
    return ret
  end

  def party
    $player.party
  end

  def party=(_value)
    raise ArgumentError.new("Not supported")
  end

  def party_full?
    return $player.party_full?
  end

  def maxBoxes
    return @boxes.length
  end

  def maxPokemon(box)
    return 0 if box >= self.maxBoxes
    return (box < 0) ? Settings::MAX_PARTY_SIZE : self[box].length
  end

  def full?
    self.maxBoxes.times do |i|
      return false if !@boxes[i].full?
    end
    return true
  end

  def pbFirstFreePos(box)
    if box == -1
      ret = self.party.length
      return (ret >= Settings::MAX_PARTY_SIZE) ? -1 : ret
    end
    maxPokemon(box).times do |i|
      return i if !self[box, i]
    end
    return -1
  end

  def [](x, y = nil)
    if y.nil?
      return (x == -1) ? self.party : @boxes[x]
    else
      @boxes.each do |i|
        raise "Box is a Pokémon, not a box" if i.is_a?(Pokemon)
      end
      return (x == -1) ? self.party[y] : @boxes[x][y]
    end
  end

  def []=(x, y, value)
    if x == -1
      self.party[y] = value
    else
      @boxes[x][y] = value
    end
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    if indexDst < 0 && boxDst < self.maxBoxes
      found = false
      maxPokemon(boxDst).times do |i|
        next if self[boxDst, i]
        found = true
        indexDst = i
        break
      end
      return false if !found
    end
    if boxDst == -1   # Copying into party
      return false if party_full?
      self.party[self.party.length] = self[boxSrc, indexSrc]
      self.party.compact!
    else   # Copying into box
      pkmn = self[boxSrc, indexSrc]
      raise "Trying to copy nil to storage" if !pkmn
      if Settings::HEAL_STORED_POKEMON
        old_ready_evo = pkmn.ready_to_evolve
        pkmn.heal
        pkmn.ready_to_evolve = old_ready_evo
      end
      self[boxDst, indexDst] = pkmn
    end
    return true
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    return false if !pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    pbDelete(boxSrc, indexSrc)
    return true
  end

  def pbMoveCaughtToParty(pkmn)
    return false if party_full?
    self.party[self.party.length] = pkmn
  end

  def pbMoveCaughtToBox(pkmn, box)
    maxPokemon(box).times do |i|
      next unless self[box, i].nil?
      if Settings::HEAL_STORED_POKEMON && box >= 0
        old_ready_evo = pkmn.ready_to_evolve
        pkmn.heal
        pkmn.ready_to_evolve = old_ready_evo
      end
      self[box, i] = pkmn
      return true
    end
    return false
  end

  def pbStoreCaught(pkmn)
    if Settings::HEAL_STORED_POKEMON && @currentBox >= 0
      old_ready_evo = pkmn.ready_to_evolve
      pkmn.heal
      pkmn.ready_to_evolve = old_ready_evo
    end
    maxPokemon(@currentBox).times do |i|
      if self[@currentBox, i].nil?
        self[@currentBox, i] = pkmn
        return @currentBox
      end
    end
    self.maxBoxes.times do |j|
      maxPokemon(j).times do |i|
        next unless self[j, i].nil?
        self[j, i] = pkmn
        @currentBox = j
        return @currentBox
      end
    end
    return -1
  end

  def pbDelete(box, index)
    if self[box, index]
      self[box, index] = nil
      self.party.compact! if box == -1
    end
  end

  def clear
    self.maxBoxes.times { |i| @boxes[i].clear }
  end
end



#===============================================================================
# Regional Storage scripts
#===============================================================================
class RegionalStorage
  def initialize
    @storages = []
    @lastmap = -1
    @rgnmap = -1
  end

  def getCurrentStorage
    if !$game_map
      raise _INTL("The player is not on a map, so the region could not be determined.")
    end
    if @lastmap != $game_map.map_id
      @rgnmap = pbGetCurrentRegion   # may access file IO, so caching result
      @lastmap = $game_map.map_id
    end
    if @rgnmap < 0
      raise _INTL("The current map has no region set. Please set the MapPosition metadata setting for this map.")
    end
    if !@storages[@rgnmap]
      @storages[@rgnmap] = PokemonStorage.new
    end
    return @storages[@rgnmap]
  end

  def allWallpapers
    return getCurrentStorage.allWallpapers
  end

  def availableWallpapers
    return getCurrentStorage.availableWallpapers
  end

  def unlockWallpaper(index)
    getCurrentStorage.unlockWallpaper(index)
  end

  def boxes
    return getCurrentStorage.boxes
  end

  def party
    return getCurrentStorage.party
  end

  def party_full?
    return getCurrentStorage.party_full?
  end

  def maxBoxes
    return getCurrentStorage.maxBoxes
  end

  def maxPokemon(box)
    return getCurrentStorage.maxPokemon(box)
  end

  def full?
    getCurrentStorage.full?
  end

  def currentBox
    return getCurrentStorage.currentBox
  end

  def currentBox=(value)
    getCurrentStorage.currentBox = value
  end

  def [](x, y = nil)
    getCurrentStorage[x, y]
  end

  def []=(x, y, value)
    getCurrentStorage[x, y] = value
  end

  def pbFirstFreePos(box)
    getCurrentStorage.pbFirstFreePos(box)
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMoveCaughtToParty(pkmn)
    getCurrentStorage.pbMoveCaughtToParty(pkmn)
  end

  def pbMoveCaughtToBox(pkmn, box)
    getCurrentStorage.pbMoveCaughtToBox(pkmn, box)
  end

  def pbStoreCaught(pkmn)
    getCurrentStorage.pbStoreCaught(pkmn)
  end

  def pbDelete(box, index)
    getCurrentStorage.pbDelete(pkmn)
  end
end



#===============================================================================
#
#===============================================================================
def pbUnlockWallpaper(index)
  $PokemonStorage.unlockedWallpapers[index] = true
end

def pbLockWallpaper(index)   # Don't know why you'd want to do this
  $PokemonStorage.unlockedWallpapers[index] = false
end

#===============================================================================
# Look through Pokémon in storage
#===============================================================================
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  (-1...$PokemonStorage.maxBoxes).each do |i|
    $PokemonStorage.maxPokemon(i).times do |j|
      pkmn = $PokemonStorage[i][j]
      yield(pkmn, i) if pkmn
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon { |pkmn, box| yield(pkmn, box) if !pkmn.egg? }
end
