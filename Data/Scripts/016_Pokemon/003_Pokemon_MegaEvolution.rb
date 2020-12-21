#===============================================================================
# Mega Evolution
# NOTE: These are treated as form changes in Essentials.
#===============================================================================
class PokeBattle_Pokemon
  def getMegaForm(checkItemOnly=false)
    formData = pbLoadFormToSpecies
    return 0 if !formData[@species] || formData[@species].length==0
    ret = 0
    if hasSpecificMegaForm?
      ret = getSpecificMegaForm
    else
      speciesData = pbLoadSpeciesData
      for i in 0...formData[@species].length
        fSpec = formData[@species][i]
        next if !fSpec || fSpec<=0
        megaStone = speciesData[fSpec][SpeciesMegaStone] || 0
        if megaStone>0 && self.hasItem?(megaStone)
          ret = i; break
        end
        if !checkItemOnly
          megaMove = speciesData[fSpec][SpeciesMegaMove] || 0
          if megaMove>0 && self.hasMove?(megaMove)
            ret = i; break
          end
        end
      end
    end
    return ret   # form number, or 0 if no accessible Mega form
  end

  def getUnmegaForm
    return -1 if !mega? && !hasSpecificUnmegaForm?
    unmegaForm = pbGetSpeciesData(@species,formSimple,SpeciesUnmegaForm)
    unmegaForm = getSpecificUnmegaForm if hasSpecificUnmegaForm?
    return unmegaForm   # form number
  end

  def hasMegaForm?
    megaForm = self.getMegaForm
    return megaForm>0 && megaForm!=self.formSimple
  end

  def mega?
    megaForm = self.getMegaForm
    return megaForm>0 && megaForm==self.formSimple
  end
  alias isMega? mega?

  def makeMega
    megaForm = self.getMegaForm
    self.form = megaForm if megaForm>0
  end

  def makeUnmega
    unmegaForm = self.getUnmegaForm
    self.form = unmegaForm if unmegaForm>=0
  end

  def megaName
    formName = pbGetMessage(MessageTypes::FormNames,self.fSpecies)
    return (formName && formName!="") ? formName : _INTL("Mega {1}",PBSpecies.getName(@species))
  end

  def megaMessage   # 0=default message, 1=Rayquaza message
    return pbGetSpeciesData(@species,getMegaForm,SpeciesMegaMessage)
  end
end



#===============================================================================
# Primal Reversion
# NOTE: These are treated as form changes in Essentials.
#===============================================================================
class PokeBattle_Pokemon
  def hasPrimalForm?
    v = MultipleForms.call("getPrimalForm",self)
    return v!=nil
  end

  def primal?
    v = MultipleForms.call("getPrimalForm",self)
    return v!=nil && v==@form
  end
  alias isPrimal? primal?

  def makePrimal
    v = MultipleForms.call("getPrimalForm",self)
    self.form = v if v!=nil
  end

  def makeUnprimal
    v = MultipleForms.call("getUnprimalForm",self)
    if v!=nil;     self.form = v
    elsif primal?; self.form = 0
    end
  end
end



MultipleForms.register(:GROUDON,{
  "getPrimalForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:REDORB)
    next
  }
})

MultipleForms.register(:KYOGRE,{
  "getPrimalForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:BLUEORB)
    next
  }
})

#===============================================================================
# Form Specific Mega Evolution
# To prevent Galarian Slowbro from Mega Evolving
#===============================================================================
class PokeBattle_Pokemon
  def hasSpecificMegaForm?
    v = MultipleForms.call("getSpecificMegaForm",self)
    return v!=nil
  end

  def getSpecificMegaForm
    v = MultipleForms.call("getSpecificMegaForm",self)
    return v if v.is_a?(Numeric)
  end

  def hasSpecificUnmegaForm?
    v = MultipleForms.call("getSpecificUnmegaForm",self)
    return v!=nil
  end

  def getSpecificUnmegaForm
    v = MultipleForms.call("getSpecificUnmegaForm",self)
    v = self.form if !v || v<0
    return v if v.is_a?(Numeric)
  end
end



MultipleForms.register(:SLOWBRO,{
  "getSpecificMegaForm" => proc { |pkmn|
    next 2 if (pkmn.form == 0 && pkmn.hasItem?(:SLOWBRONITE))
    next
  },
  "getSpecificUnmegaForm" => proc { |pkmn|
    next 0 if pkmn.form == 2
    next
  }
})
