#===============================================================================
# Defines an event that procedures can subscribe to.
#===============================================================================
class Event
  def initialize
    @callbacks = {}
  end

  # Removes an event handler procedure from the event.
  def remove(key, proc)
    return false if !@callbacks.has_key?(key)
    @callbacks.delete(key)
  end

  # Adds an event handler procedure from the event.
  def add(key, proc)
    return false if @callbacks.has_key?(key)
    @callbacks[key] = proc
  end

  # Clears the event of event handlers.
  def clear
    @callbacks.clear
  end

  # Triggers the event and calls all its event handlers. Normally called only
  # by the code where the event occurred.
  def trigger(*args)
    @callbacks.each { |_, callback| callback.call(*args) }
  end
end

#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs.
#===============================================================================
module EventHandlers
  @@events = {}

  # Add a new Event to a handler. Also add a proc to the corresponding Event if
  # a proc has been provided
  def self.add(key, event = nil, proc = nil)
    @@events[key] = Event.new if !@@events.has_key?(key)
    @@events[key].add(event, proc) if proc && event
  end

  # Remove callback from an Event if it has been defined.
  def self.remove(key, event)
    return false if !@@events.has_key?(key)
    @@events[key].remove(event)
  end

  # Clear all callbacks from an Event if it has been defined.
  def self.clear(key)
    return false if !@@events.has_key?(key)
    @@events[key].clear
  end

  # Trigger all callbacks from an Event if it has been defined.
  def self.trigger(key, *args)
    return false if !@@events.has_key?(key)
    @@events[key].trigger(*args)
  end
end

#===============================================================================
#
#===============================================================================
class HandlerHash
  def initialize(mod)
    @mod         = mod
    @hash        = {}
    @addIfs      = []
    @symbolCache = {}
  end

  def fromSymbol(sym)
    return sym unless sym.is_a?(Symbol) || sym.is_a?(String)
    mod = Object.const_get(@mod) rescue nil
    return nil if !mod
    return mod.const_get(sym.to_sym) rescue nil
  end

  def toSymbol(sym)
    return sym.to_sym if sym.is_a?(Symbol) || sym.is_a?(String)
    ret = @symbolCache[sym]
    return ret if ret
    mod = Object.const_get(@mod) rescue nil
    return nil if !mod
    mod.constants.each do |key|
      next if mod.const_get(key) != sym
      ret = key.to_sym
      @symbolCache[sym] = ret
      break
    end
    return ret
  end

  def addIf(conditionProc, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @addIfs.push([conditionProc, handler || handlerBlock])
  end

  def add(sym, handler = nil, &handlerBlock) # 'sym' can be an ID or symbol
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{sym.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    id = fromSymbol(sym)
    @hash[id] = handler || handlerBlock if id
    symbol = toSymbol(sym)
    @hash[symbol] = handler || handlerBlock if symbol
  end

  def copy(src, *dests)
    handler = self[src]
    if handler
      dests.each do |dest|
        self.add(dest, handler)
      end
    end
  end

  def [](sym)   # 'sym' can be an ID or symbol
    id = fromSymbol(sym)
    ret = nil
    ret = @hash[id] if id && @hash[id]   # Real ID from the item
    symbol = toSymbol(sym)
    ret = @hash[symbol] if symbol && @hash[symbol]   # Symbol or string
    unless ret
      @addIfs.each do |addif|
        return addif[1] if addif[0].call(id)
      end
    end
    return ret
  end

  def trigger(sym, *args)
    handler = self[sym]
    return (handler) ? handler.call(fromSymbol(sym), *args) : nil
  end

  def clear
    @hash.clear
  end
end

#===============================================================================
# A stripped-down version of class HandlerHash which only deals with symbols and
# doesn't care about whether those symbols actually relate to a defined thing.
#===============================================================================
class HandlerHash2
  def initialize
    @hash    = {}
    @add_ifs = []
  end

  def [](sym)
    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
    return @hash[sym] if sym && @hash[sym]
    @add_ifs.each do |add_if|
      return add_if[1] if add_if[0].call(sym)
    end
    return nil
  end

  def addIf(conditionProc, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @add_ifs.push([conditionProc, handler || handlerBlock])
  end

  def add(sym, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{sym.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    @hash[sym] = handler || handlerBlock if sym
  end

  def copy(src, *dests)
    handler = self[src]
    return if !handler
    dests.each do |dest|
      self.add(dest, handler)
    end
  end

  def clear
    @hash.clear
  end

  def trigger(sym, *args)
    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
    handler = self[sym]
    return (handler) ? handler.call(sym, *args) : nil
  end
end

#===============================================================================
# An even more stripped down version of class HandlerHash which just takes
# hashes with keys, no matter what the keys are.
#===============================================================================
class HandlerHashBasic

  attr_reader :ordered_keys

  def initialize
    @ordered_keys = []
    @hash         = {}
    @addIfs       = []
  end

  def [](entry)
    ret = nil
    ret = @hash[entry] if entry && @hash[entry]
    unless ret
      @addIfs.each do |addif|
        return addif[1] if addif[0].call(entry)
      end
    end
    return ret
  end

  def each
    @ordered_keys.each { |key| yield key, @hash[key] }
  end

  def add(entry, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{entry.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    return if !entry || entry.empty?
    @ordered_keys.push(entry) if !@ordered_keys.include?(entry)
    @hash[entry] = handler || handlerBlock
  end

  def addIf(conditionProc, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @addIfs.push([conditionProc, handler || handlerBlock])
  end

  def copy(src, *dests)
    handler = self[src]
    return if !handler
    dests.each { |dest| self.add(dest, handler) }
  end

  def clear
    @hash.clear
    @ordered_keys.clear
  end

  def trigger(entry, *args)
    handler = self[entry]
    return (handler) ? handler.call(*args) : nil
  end
end

#===============================================================================
#
#===============================================================================
class SpeciesHandlerHash < HandlerHash2
end

class AbilityHandlerHash < HandlerHash2
end

class ItemHandlerHash < HandlerHash2
end

class MoveHandlerHash < HandlerHash2
end

#===============================================================================
# Menu Option Handler Modules
#===============================================================================
module MenuHandlers
  @@handlers = {}

  def self.register(key, option, hash)
    @@handlers[key] = HandlerHashBasic.new if !@@handlers.has_key?(key)
    @@handlers[key].add(option, hash)
  end

  def self.register_if(key, condition, hash)
    @@handlers[key] = HandlerHashBasic.new if !@@handlers.has_key?(key)
    @@handlers[key].addIf(condition, hash)
  end

  def self.copy(key, option, *new_options)
    return if !@@handlers.has_key?(key)
    @@handlers[key].copy(option, *new_options)
  end

  def self.each(key)
    return if !@@handlers.has_key?(key)
    @@handlers[key].each { |option, hash| yield option, hash }
  end

  def self.each_available(key)
    return if !@@handlers.has_key?(key)
    option_hash = @@handlers[key]
    keys = option_hash.ordered_keys.sort_by { |option| option_hash[option]["order"] rescue 0 }
    keys.each { |option|
      hash = option_hash[option]
      condition = hash["condition"]
      yield option, hash if !condition.respond_to?(:call) || condition.call
    }
  end

  def self.has_function?(key, option, function)
    return false if !@@handlers.has_key?(key)
    option_hash = @@handlers[key][option]
    return option_hash&.has_key?(function)
  end

  def self.get_function(key, option, function)
    return false if !@@handlers.has_key?(key)
    option_hash = @@handlers[key][option]
    return (option_hash && option_hash[function]) ? option_hash[function] : nil
  end

  def self.get_string_option(key, function, option)
    return false if !@@handlers.has_key?(key)
    option_hash = @@handlers[key][option]
    return option if !option_hash || !option_hash[function]
    if option_hash[function].is_a?(Proc)
      return option_hash[function].call
    elsif option_hash[function].is_a?(String)
      return _INTL(option_hash[function])
    end
    return option
  end

  def self.call(key, function, option, *args)
    option_hash = @@handlers[key][option]
    return nil if !option_hash || !option_hash[function]
    return option_hash[function].call(*args) == true
  end
end
