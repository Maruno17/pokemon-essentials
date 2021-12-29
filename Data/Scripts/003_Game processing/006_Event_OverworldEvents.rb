#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs.
#===============================================================================
module EventHandlers
  @@events = {}

  def self.add(key, event, proc)
    @@events[key] = Event.new if !@@events.has_key?(key)
    @@events[key].add(event, proc)
  end

  def self.remove(key, event)
    return false if !@@events.has_key?(key)
    @@events[key].remove(event)
  end

  def self.clear(key)
    return false if !@@events.has_key?(key)
    @@events[key].clear
  end

  def self.trigger(key, *args)
    return false if !@@events.has_key?(key)
    @@events[key].trigger(*args)
  end
end

#===============================================================================
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event. It will
# then be called whenever the event occurs.
#===============================================================================
module EncounterModifier
  @@procs    = []
  @@procsEnd = []

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    @@procs.each do |prc|
      encounter = prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd
    @@procsEnd.each do |prc|
      prc.call
    end
  end
end

# Unused
def pbOnSpritesetCreate(spriteset, viewport)
  EventHandlers.trigger(:on_spriteset_creation, spriteset, viewport)
end
