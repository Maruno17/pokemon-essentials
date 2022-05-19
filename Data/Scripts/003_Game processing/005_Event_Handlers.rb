#===============================================================================
# Defines an event that procedures can subscribe to.
#===============================================================================
class Event
  def initialize
    @callbacks = []
  end

  # Sets an event handler for this event and removes all other event handlers.
  def set(method)
    @callbacks.clear
    @callbacks.push(method)
  end

  # Removes an event handler procedure from the event.
  def -(other)
    @callbacks.delete(other)
    return self
  end

  # Adds an event handler procedure from the event.
  def +(other)
    return self if @callbacks.include?(other)
    @callbacks.push(other)
    return self
  end

  # Clears the event of event handlers.
  def clear
    @callbacks.clear
  end

  # Triggers the event and calls all its event handlers.  Normally called only
  # by the code where the event occurred.
  # The first argument is the sender of the event, the second argument contains
  # the event's parameters. If three or more arguments are given, this method
  # supports the following callbacks:
  # proc { |sender,params| } where params is an array of the other parameters, and
  # proc { |sender,arg0,arg1,...| }
  def trigger(*arg)
    arglist = arg[1, arg.length]
    @callbacks.each do |callback|
      if callback.arity > 2 && arg.length == callback.arity
        # Retrofitted for callbacks that take three or more arguments
        callback.call(*arg)
      else
        callback.call(arg[0], arglist)
      end
    end
  end

  # Triggers the event and calls all its event handlers. Normally called only
  # by the code where the event occurred. The first argument is the sender of
  # the event, the other arguments are the event's parameters.
  def trigger2(*arg)
    @callbacks.each do |callback|
      callback.call(*arg)
    end
  end
end

#===============================================================================
# Same as class Event, but each registered proc has a name (a symbol) so it can
# be referenced individually.
#===============================================================================
class NamedEvent
  def initialize
    @callbacks = {}
  end

  # Adds an event handler procedure from the event.
  def add(key, proc)
    @callbacks[key] = proc if !@callbacks.has_key?(key)
  end

  # Removes an event handler procedure from the event.
  def remove(key)
    @callbacks.delete(key)
  end

  # Clears the event of event handlers.
  def clear
    @callbacks.clear
  end

  # Triggers the event and calls all its event handlers. Normally called only
  # by the code where the event occurred.
  def trigger(*args)
    @callbacks.each_value { |callback| callback.call(*args) }
  end
end

#===============================================================================
# Unused.
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
# doesn't care about whether those symbols are defined as constants in a class
# or module.
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

  def add(sym, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{sym.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    @hash[sym] = handler || handlerBlock if sym
  end

  def addIf(conditionProc, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @add_ifs.push([conditionProc, handler || handlerBlock])
  end

  def copy(src, *dests)
    handler = self[src]
    return if !handler
    dests.each { |dest| add(dest, handler) }
  end

  def remove(key)
    @hash.delete(key)
  end

  def clear
    @hash.clear
  end

  def trigger(sym, *args)
    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
    handler = self[sym]
    return handler&.call(sym, *args)
  end
end

#===============================================================================
# An even more stripped down version of class HandlerHash which just takes
# hashes with keys, no matter what the keys are.
#===============================================================================
class HandlerHashBasic
  def initialize
    @hash   = {}
    @addIfs = []
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

  def add(entry, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{entry.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    return if !entry || entry.empty?
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
    dests.each { |dest| add(dest, handler) }
  end

  def remove(key)
    @hash.delete(key)
  end

  def clear
    @hash.clear
  end

  def each
    @hash.each_pair { |key, value| yield key, value }
  end

  def keys
    return @hash.keys.clone
  end

  def trigger(entry, *args)
    handler = self[entry]
    return handler&.call(*args)
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
