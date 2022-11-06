class FusionSelectOptionsScene < PokemonOption_Scene
  attr_accessor :selectedAbility
  attr_accessor :selectedNature
  attr_accessor :hasNickname
  attr_accessor :nickname


  def initialize(abilityList,natureList, pokemon1, pokemon2)
    @abilityList = abilityList
    @natureList = natureList
    @selectedAbility=nil
    @selectedNature=nil
    @selBaseColor = Color.new(48,96,216)
    @selShadowColor = Color.new(32,32,32)
    @show_frame=false
    @hasNickname = false
    @nickname = nil

    @pokemon1=pokemon1
    @pokemon2=pokemon2
  end


  def initUIElements
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select your Pokémon's ability and nature"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    @sprites["title"].opacity=0
  end

  def pbStartScene(inloadscreen = nil)
    super
    @sprites["option"].opacity=0
  end


  def getAbilityName(ability)
    return GameData::Ability.get(ability.id).real_name
  end

  def getAbilityDescription(ability)
    return GameData::Ability.get(ability.id).real_description
  end

  def getNatureName(nature)
    return GameData::Nature.get(nature.id).real_name
  end

  def getNatureDescription(nature)
    change= GameData::Nature.get(nature.id).stat_changes
    return "Neutral nature" if change.empty?
    positiveChange = change[0]
    negativeChange = change[1]
    return _INTL("+ {1}\n- {2}",GameData::Stat.get(positiveChange[0]).name,GameData::Stat.get(negativeChange[0]).name)
  end

  def shouldSelectNickname
    if @pokemon1.nicknamed? && @pokemon2.nicknamed?
      @hasNickname=true
      return true
    end
    if @pokemon1.nicknamed? && !@pokemon2.nicknamed?
      @hasNickname=true
      @nickname = @pokemon1.name
      return false
    end
    if !@pokemon1.nicknamed? && @pokemon2.nicknamed?
      @hasNickname=true
      @nickname = @pokemon2.name
      return false
    end
    @hasNickname=false
    return false
  end

  def pbGetOptions(inloadscreen = false)

    options = []
    if shouldSelectNickname
      options << EnumOption.new(_INTL("Nickname"), [_INTL(@pokemon1.name), _INTL(@pokemon2.name)],
                                proc { 0 },
                                proc { |value|
                                  if value ==0
                                    @nickname = @pokemon1.name
                                  else
                                    @nickname = @pokemon2.name
                                  end
                                }, "Select the Pokémon's nickname")
    end

    options << EnumOption.new(_INTL("Ability"), [_INTL(getAbilityName(@abilityList[0])), _INTL(getAbilityName(@abilityList[1]))],
                     proc { 0 },
                     proc { |value|
                       @selectedAbility=@abilityList[value]
                     }, [getAbilityDescription(@abilityList[0]), getAbilityDescription(@abilityList[1])]
      )

    options << EnumOption.new(_INTL("Nature"), [_INTL(getNatureName(@natureList[0])), _INTL(getNatureName(@natureList[1]))],
                     proc { 0 },
                     proc { |value|
                       @selectedNature=@natureList[value]
                     }, [getNatureDescription(@natureList[0]), getNatureDescription(@natureList[1])]
      )

    return options
  end

  def isConfirmedOnKeyPress
    return true
  end

end

