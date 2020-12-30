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
  def -(method)
    for i in 0...@callbacks.length
      next if @callbacks[i]!=method
      @callbacks.delete_at(i)
      break
    end
    return self
  end

  # Adds an event handler procedure from the event.
  def +(method)
    for i in 0...@callbacks.length
      return self if @callbacks[i]==method
    end
    @callbacks.push(method)
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
    arglist = arg[1,arg.length]
    for callback in @callbacks
      if callback.arity>2 && arg.length==callback.arity
        # Retrofitted for callbacks that take three or more arguments
        callback.call(*arg)
      else
        callback.call(arg[0],arglist)
      end
    end
  end

  # Triggers the event and calls all its event handlers. Normally called only
  # by the code where the event occurred. The first argument is the sender of
  # the event, the other arguments are the event's parameters.
  def trigger2(*arg)
    for callback in @callbacks
      callback.call(*arg)
    end
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
    for key in mod.constants
      next if mod.const_get(key)!=sym
      ret = key.to_sym
      @symbolCache[sym] = ret
      break
    end
    return ret
  end

  def addIf(conditionProc,handler=nil,&handlerBlock)
    if ![Proc,Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @addIfs.push([conditionProc,handler || handlerBlock])
  end

  def add(sym,handler=nil,&handlerBlock) # 'sym' can be an ID or symbol
    if ![Proc,Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{sym.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    id = fromSymbol(sym)
    @hash[id] = handler || handlerBlock if id
    symbol = toSymbol(sym)
    @hash[symbol] = handler || handlerBlock if symbol
  end

  def copy(src,*dests)
    handler = self[src]
    if handler
      for dest in dests
        self.add(dest,handler)
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
      for addif in @addIfs
        return addif[1] if addif[0].call(id)
      end
    end
    return ret
  end

  def trigger(sym,*args)
    handler = self[sym]
    return (handler) ? handler.call(fromSymbol(sym),*args) : nil
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
    for add_if in @add_ifs
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
    for dest in dests
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
  def initialize
    @ordered_keys = []
    @hash         = {}
    @addIfs       = []
  end

  def [](entry)
    ret = nil
    ret = @hash[entry] if entry && @hash[entry]
    unless ret
      for addif in @addIfs
        return addif[1] if addif[0].call(entry)
      end
    end
    return ret
  end

  def each
    @ordered_keys.each { |key| yield key, @hash[key] }
  end

  def add(entry, handler = nil, &handlerBlock)
    if ![Proc,Hash].include?(handler.class) && !block_given?
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
