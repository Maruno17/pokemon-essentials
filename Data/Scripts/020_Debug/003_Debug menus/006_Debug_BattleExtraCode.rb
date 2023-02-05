#===============================================================================
# Effect values that can be edited via the battle debug menu.
#===============================================================================
module Battle::DebugVariables
  BATTLER_EFFECTS = {
    PBEffects::AquaRing       => {name: "Aqua Ring applies",                               default: false},
    PBEffects::Attract        => {name: "Battler that self is attracted to",               default: -1},   # Battler index
    PBEffects::BanefulBunker  => {name: "Baneful Bunker applies this round",               default: false},
#    PBEffects::BeakBlast - only applies to use of specific move, not suitable for setting via debug
    PBEffects::Bide           => {name: "Bide number of rounds remaining",                 default: 0},
    PBEffects::BideDamage     => {name: "Bide damage accumulated",                         default: 0, max: 999},
    PBEffects::BideTarget     => {name: "Bide last battler to hurt self",                  default: -1},   # Battler index
    PBEffects::BurnUp         => {name: "Burn Up has removed self's Fire type",            default: false},
    PBEffects::Charge         => {name: "Charge number of rounds remaining",               default: 0},
    PBEffects::ChoiceBand     => {name: "Move locked into by Choice items",                default: nil, type: :move},
    PBEffects::Confusion      => {name: "Confusion number of rounds remaining",            default: 0},
#    PBEffects::Counter - not suitable for setting via debug
#    PBEffects::CounterTarget - not suitable for setting via debug
    PBEffects::Curse          => {name: "Curse damaging applies",                          default: false},
#    PBEffects::Dancer - only used while Dancer is running, not suitable for setting via debug
    PBEffects::DefenseCurl    => {name: "Used Defense Curl",                               default: false},
#    PBEffects::DestinyBond - not suitable for setting via debug
#    PBEffects::DestinyBondPrevious - not suitable for setting via debug
#    PBEffects::DestinyBondTarget - not suitable for setting via debug
    PBEffects::Disable        => {name: "Disable number of rounds remaining",              default: 0},
    PBEffects::DisableMove    => {name: "Disabled move",                                   default: nil, type: :move},
    PBEffects::Electrify      => {name: "Electrify making moves Electric",                 default: false},
    PBEffects::Embargo        => {name: "Embargo number of rounds remaining",              default: 0},
    PBEffects::Encore         => {name: "Encore number of rounds remaining",               default: 0},
    PBEffects::EncoreMove     => {name: "Encored move",                                    default: nil, type: :move},
    PBEffects::Endure         => {name: "Endures all lethal damage this round",            default: false},
#    PBEffects::FirstPledge - only applies to use of specific move, not suitable for setting via debug
    PBEffects::FlashFire      => {name: "Flash Fire powering up Fire moves",               default: false},
    PBEffects::Flinch         => {name: "Will flinch this round",                          default: false},
    PBEffects::FocusEnergy    => {name: "Focus Energy critical hit stages (0-4)",          default: 0, max: 4},
#    PBEffects::FocusPunch - only applies to use of specific move, not suitable for setting via debug
    PBEffects::FollowMe       => {name: "Follow Me drawing in attacks (if 1+)",            default: 0},   # Order of use, lowest takes priority
    PBEffects::RagePowder     => {name: "Rage Powder applies (use with Follow Me)",        default: false},
    PBEffects::Foresight      => {name: "Foresight applies (Ghost loses immunities)",      default: false},
    PBEffects::FuryCutter     => {name: "Fury Cutter power multiplier 2**x (0-4)",         default: 0, max: 4},
    PBEffects::GastroAcid     => {name: "Gastro Acid is negating self's ability",          default: false},
#    PBEffects::GemConsumed - only applies during use of move, not suitable for setting via debug
    PBEffects::Grudge         => {name: "Grudge will apply if self faints",                default: false},
    PBEffects::HealBlock      => {name: "Heal Block number of rounds remaining",           default: 0},
    PBEffects::HelpingHand    => {name: "Helping Hand will power up self's move",          default: false},
    PBEffects::HyperBeam      => {name: "Hyper Beam recharge rounds remaining",            default: 0},
#    PBEffects::Illusion - is a Pokémon object, too complex to be worth bothering with
    PBEffects::Imprison       => {name: "Imprison disables others' moves known by self",   default: false},
    PBEffects::Ingrain        => {name: "Ingrain applies",                                 default: false},
#    PBEffects::Instruct - only used while Instruct is running, not suitable for setting via debug
#    PBEffects::Instructed - only used while Instruct is running, not suitable for setting via debug
    PBEffects::JawLock        => {name: "Battler trapping self with Jaw Lock",             default: -1},   # Battler index
    PBEffects::KingsShield    => {name: "King's Shield applies this round",                default: false},
    PBEffects::LaserFocus     => {name: "Laser Focus certain critial hit duration",        default: 0},
    PBEffects::LeechSeed      => {name: "Battler that used Leech Seed on self",            default: -1},   # Battler index
    PBEffects::LockOn         => {name: "Lock-On number of rounds remaining",              default: 0},
    PBEffects::LockOnPos      => {name: "Battler that self is targeting with Lock-On",     default: -1},   # Battler index
#    PBEffects::MagicBounce - only applies during use of move, not suitable for setting via debug
#    PBEffects::MagicCoat - only applies to use of specific move, not suitable for setting via debug
    PBEffects::MagnetRise     => {name: "Magnet Rise number of rounds remaining",          default: 0},
    PBEffects::MeanLook       => {name: "Battler trapping self with Mean Look, etc.",      default: -1},   # Battler index
#    PBEffects::MeFirst - only applies to use of specific move, not suitable for setting via debug
    PBEffects::Metronome      => {name: "Metronome item power multiplier 1 + 0.2*x (0-5)", default: 0, max: 5},
    PBEffects::MicleBerry     => {name: "Micle Berry boosting next move's accuracy",       default: false},
    PBEffects::Minimize       => {name: "Used Minimize",                                   default: false},
    PBEffects::MiracleEye     => {name: "Miracle Eye applies (Dark loses immunities)",     default: false},
#    PBEffects::MirrorCoat - not suitable for setting via debug
#    PBEffects::MirrorCoatTarget - not suitable for setting via debug
#    PBEffects::MoveNext - not suitable for setting via debug
    PBEffects::MudSport       => {name: "Used Mud Sport (Gen 5 and older)",                default: false},
    PBEffects::Nightmare      => {name: "Taking Nightmare damage",                         default: false},
    PBEffects::NoRetreat      => {name: "No Retreat trapping self in battle",              default: false},
    PBEffects::Obstruct       => {name: "Obstruct applies this round",                     default: false},
    PBEffects::Octolock       => {name: "Battler trapping self with Octolock",             default: -1},   # Battler index
    PBEffects::Outrage        => {name: "Outrage number of rounds remaining",              default: 0},
#    PBEffects::ParentalBond - only applies during use of move, not suitable for setting via debug
    PBEffects::PerishSong     => {name: "Perish Song number of rounds remaining",          default: 0},
    PBEffects::PerishSongUser => {name: "Battler that used Perish Song on self",           default: -1},   # Battler index
    PBEffects::PickupItem     => {name: "Item retrievable by Pickup",                      default: nil, type: :item},
    PBEffects::PickupUse      => {name: "Pickup item consumed time (higher=more recent)",  default: 0},
    PBEffects::Pinch          => {name: "(Battle Palace) Behavior changed at <50% HP",     default: false},
    PBEffects::Powder         => {name: "Powder will explode self's Fire move this round", default: false},
#    PBEffects::PowerTrick - doesn't actually swap the stats therefore does nothing, not suitable for setting via debug
#    PBEffects::Prankster - not suitable for setting via debug
#    PBEffects::PriorityAbility - not suitable for setting via debug
#    PBEffects::PriorityItem - not suitable for setting via debug
    PBEffects::Protect        => {name: "Protect applies this round",                      default: false},
    PBEffects::ProtectRate    => {name: "Protect success chance 1/x",                      default: 1, max: 999},
#    PBEffects::Quash - not suitable for setting via debug
#    PBEffects::Rage - only applies to use of specific move, not suitable for setting via debug
    PBEffects::Rollout        => {name: "Rollout rounds remaining (lower=stronger)",       default: 0},
    PBEffects::Roost          => {name: "Roost removing Flying type this round",           default: false},
#    PBEffects::ShellTrap - only applies to use of specific move, not suitable for setting via debug
#    PBEffects::SkyDrop - only applies to use of specific move, not suitable for setting via debug
    PBEffects::SlowStart      => {name: "Slow Start rounds remaining",                     default: 0},
    PBEffects::SmackDown      => {name: "Smack Down is grounding self",                    default: false},
#    PBEffects::Snatch - only applies to use of specific move, not suitable for setting via debug
    PBEffects::SpikyShield    => {name: "Spiky Shield applies this round",                 default: false},
    PBEffects::Spotlight      => {name: "Spotlight drawing in attacks (if 1+)",            default: 0},
    PBEffects::Stockpile      => {name: "Stockpile count (0-3)",                           default: 0, max: 3},
    PBEffects::StockpileDef   => {name: "Def stages gained by Stockpile (0-12)",           default: 0, max: 12},
    PBEffects::StockpileSpDef => {name: "Sp. Def stages gained by Stockpile (0-12)",       default: 0, max: 12},
    PBEffects::Substitute     => {name: "Substitute's HP",                                 default: 0, max: 999},
    PBEffects::TarShot        => {name: "Tar Shot weakening self to Fire",                 default: false},
    PBEffects::Taunt          => {name: "Taunt number of rounds remaining",                default: 0},
    PBEffects::Telekinesis    => {name: "Telekinesis number of rounds remaining",          default: 0},
    PBEffects::ThroatChop     => {name: "Throat Chop number of rounds remaining",          default: 0},
    PBEffects::Torment        => {name: "Torment preventing repeating moves",              default: false},
#    PBEffects::Toxic - set elsewhere
#    PBEffects::Transform - too complex to be worth bothering with
#    PBEffects::TransformSpecies - too complex to be worth bothering with
    PBEffects::Trapping       => {name: "Trapping number of rounds remaining",             default: 0},
    PBEffects::TrappingMove   => {name: "Move that is trapping self",                      default: nil, type: :move},
    PBEffects::TrappingUser   => {name: "Battler trapping self (for Binding Band)",        default: -1},   # Battler index
    PBEffects::Truant         => {name: "Truant will loaf around this round",              default: false},
#    PBEffects::TwoTurnAttack - only applies to use of specific moves, not suitable for setting via debug
#    PBEffects::ExtraType - set elsewhere
    PBEffects::Unburden       => {name: "Self lost its item (for Unburden)",               default: false},
    PBEffects::Uproar         => {name: "Uproar number of rounds remaining",               default: 0},
    PBEffects::WaterSport     => {name: "Used Water Sport (Gen 5 and older)",              default: false},
    PBEffects::WeightChange   => {name: "Weight change +0.1*x kg",                         default: 0, min: -99_999, max: 99_999},
    PBEffects::Yawn           => {name: "Yawn rounds remaining until falling asleep",      default: 0}
  }

  SIDE_EFFECTS = {
    PBEffects::AuroraVeil         => {name: "Aurora Veil duration",                   default: 0},
    PBEffects::CraftyShield       => {name: "Crafty Shield applies this round",       default: false},
    PBEffects::EchoedVoiceCounter => {name: "Echoed Voice rounds used (max. 5)",      default: 0, max: 5},
    PBEffects::EchoedVoiceUsed    => {name: "Echoed Voice used this round",           default: false},
    PBEffects::LastRoundFainted   => {name: "Round when side's battler last fainted", default: -2},   # Treated as -1, isn't a battler index
    PBEffects::LightScreen        => {name: "Light Screen duration",                  default: 0},
    PBEffects::LuckyChant         => {name: "Lucky Chant duration",                   default: 0},
    PBEffects::MatBlock           => {name: "Mat Block applies this round",           default: false},
    PBEffects::Mist               => {name: "Mist duration",                          default: 0},
    PBEffects::QuickGuard         => {name: "Quick Guard applies this round",         default: false},
    PBEffects::Rainbow            => {name: "Rainbow duration",                       default: 0},
    PBEffects::Reflect            => {name: "Reflect duration",                       default: 0},
    PBEffects::Round              => {name: "Round was used this round",              default: false},
    PBEffects::Safeguard          => {name: "Safeguard duration",                     default: 0},
    PBEffects::SeaOfFire          => {name: "Sea Of Fire duration",                   default: 0},
    PBEffects::Spikes             => {name: "Spikes layers (0-3)",                    default: 0, max: 3},
    PBEffects::StealthRock        => {name: "Stealth Rock exists",                    default: false},
    PBEffects::StickyWeb          => {name: "Sticky Web exists",                      default: false},
    PBEffects::Swamp              => {name: "Swamp duration",                         default: 0},
    PBEffects::Tailwind           => {name: "Tailwind duration",                      default: 0},
    PBEffects::ToxicSpikes        => {name: "Toxic Spikes layers (0-2)",              default: 0, max: 2},
    PBEffects::WideGuard          => {name: "Wide Guard applies this round",          default: false}
  }

  FIELD_EFFECTS = {
    PBEffects::AmuletCoin      => {name: "Amulet Coin doubling prize money", default: false},
    PBEffects::FairyLock       => {name: "Fairy Lock trapping duration",     default: 0},
    PBEffects::FusionBolt      => {name: "Fusion Bolt was used",             default: false},
    PBEffects::FusionFlare     => {name: "Fusion Flare was used",            default: false},
    PBEffects::Gravity         => {name: "Gravity duration",                 default: 0},
    PBEffects::HappyHour       => {name: "Happy Hour doubling prize money",  default: false},
    PBEffects::IonDeluge       => {name: "Ion Deluge making moves Electric", default: false},
    PBEffects::MagicRoom       => {name: "Magic Room duration",              default: 0},
    PBEffects::MudSportField   => {name: "Mud Sport duration (Gen 6+)",      default: 0},
    PBEffects::PayDay          => {name: "Pay Day additional prize money",   default: 0, max: Settings::MAX_MONEY},
    PBEffects::TrickRoom       => {name: "Trick Room duration",              default: 0},
    PBEffects::WaterSportField => {name: "Water Sport duration (Gen 6+)",    default: 0},
    PBEffects::WonderRoom      => {name: "Wonder Room duration",             default: 0}
  }

  POSITION_EFFECTS = {
#    PBEffects::FutureSightCounter - too complex to be worth bothering with
#    PBEffects::FutureSightMove - too complex to be worth bothering with
#    PBEffects::FutureSightUserIndex - too complex to be worth bothering with
#    PBEffects::FutureSightUserPartyIndex - too complex to be worth bothering with
    PBEffects::HealingWish => {name: "Whether Healing Wish is waiting to apply", default: false},
    PBEffects::LunarDance  => {name: "Whether Lunar Dance is waiting to apply",  default: false}
#    PBEffects::Wish - too complex to be worth bothering with
#    PBEffects::WishAmount - too complex to be worth bothering with
#    PBEffects::WishMaker - too complex to be worth bothering with
  }
end

#===============================================================================
# Screen for listing the above battle variables for modifying.
#===============================================================================
class SpriteWindow_DebugBattleFieldEffects < Window_DrawableCommand
  BASE_TEXT_COLOR   = Color.new(96, 96, 96)
  RED_TEXT_COLOR    = Color.new(168, 48, 56)
  GREEN_TEXT_COLOR  = Color.new(0, 144, 0)
  TEXT_SHADOW_COLOR = Color.new(208, 208, 200)

  def initialize(viewport, battle, variables, variables_data)
    @battle         = battle
    @variables      = variables
    @variables_data = variables_data
    super(0, 0, Graphics.width, Graphics.height, viewport)
  end

  def itemCount
    return @variables_data.length
  end

  def shadowtext(x, y, w, h, t, align = 0, colors = 0)
    width = self.contents.text_size(t).width
    case align
    when 1   # Right aligned
      x += w - width
    when 2   # Centre aligned
      x += (w - width) / 2
    end
    base_color = BASE_TEXT_COLOR
    case colors
    when 1 then base_color = RED_TEXT_COLOR
    when 2 then base_color = GREEN_TEXT_COLOR
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, base_color, TEXT_SHADOW_COLOR)
  end

  def drawItem(index, _count, rect)
    pbSetNarrowFont(self.contents)
    variable_data = @variables_data[@variables_data.keys[index]]
    variable = @variables[@variables_data.keys[index]]
    # Variables which aren't their default value are colored differently
    default = variable_data[:default]
    default = -1 if default == -2
    different = (variable || default) != default
    color = (different) ? 2 : 0
    # Draw cursor
    rect = drawCursor(index, rect)
    # Get value's text to draw
    variable_text = variable.to_s
    case variable_data[:default]
    when -1   # Battler
      if variable >= 0
        battler_name = @battle.battlers[variable].name
        battler_name = "-" if nil_or_empty?(battler_name)
        variable_text = sprintf("[%d] %s", variable, battler_name)
      else
        variable_text = _INTL("[None]")
      end
    when nil   # Move, item
      variable_text = _INTL("[None]") if !variable
    end
    # Draw text
    total_width = rect.width
    name_width  = total_width * 80 / 100
    value_width = total_width * 20 / 100
    self.shadowtext(rect.x, rect.y + 8, name_width, rect.height, variable_data[:name], 0, color)
    self.shadowtext(rect.x + name_width, rect.y + 8, value_width, rect.height, variable_text, 1, color)
  end
end

#===============================================================================
#
#===============================================================================
class Battle::DebugSetEffects
  def initialize(battle, mode, side = 0)
    @battle = battle
    @mode = mode
    @side = side
    case @mode
    when :field
      @variables_data = Battle::DebugVariables::FIELD_EFFECTS
      @variables = @battle.field.effects
    when :side
      @variables_data = Battle::DebugVariables::SIDE_EFFECTS
      @variables = @battle.sides[@side].effects
    when :position
      @variables_data = Battle::DebugVariables::POSITION_EFFECTS
      @variables = @battle.positions[@side].effects
    when :battler
      @variables_data = Battle::DebugVariables::BATTLER_EFFECTS
      @variables = @battle.battlers[@side].effects
    end
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @window = SpriteWindow_DebugBattleFieldEffects.new(@viewport, @battle, @variables, @variables_data)
    @window.active = true
  end

  def dispose
    @window.dispose
    @viewport.dispose
  end

  def choose_number(default, min, max)
    params = ChooseNumberParams.new
    params.setRange(min, max)
    params.setDefaultValue(default)
    params.setNegativesAllowed(true) if min < 0
    return pbMessageChooseNumber(_INTL("Set value ({1}-{2}).", min, max), params)
  end

  def choose_battler(default)
    commands = [_INTL("[None]")]
    cmds = [-1]
    cmd = 0
    @battle.battlers.each_with_index do |battler, i|
      next if battler.nil?   # Position doesn't exist
      name = battler.pbThis
      name = "-" if battler.fainted? || nil_or_empty?(name)
      commands.push(sprintf("[%d] %s", i, name))
      cmds.push(i)
      cmd = cmds.length - 1 if default == i
    end
    cmd = pbMessage("\\ts[]" + _INTL("Choose a battler/position."), commands, -1, nil, cmd)
    return (cmd >= 0) ? cmds[cmd] : default
  end

  def update_input_for_boolean(effect, variable_data)
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      @variables[effect] = !@variables[effect]
      return true
    elsif Input.trigger?(Input::ACTION) && @variables[effect]
      pbPlayDecisionSE
      @variables[effect] = false
      return true
    elsif Input.repeat?(Input::LEFT) && @variables[effect]
      pbPlayCursorSE
      @variables[effect] = false
      return true
    elsif Input.repeat?(Input::RIGHT) && !@variables[effect]
      pbPlayCursorSE
      @variables[effect] = true
      return true
    end
    return false
  end

  def update_input_for_integer(effect, default, variable_data)
    true_default = (default == -2) ? -1 : default
    min = variable_data[:min] || true_default
    max = variable_data[:max] || 99
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      new_value = choose_number(@variables[effect], min, max)
      if new_value != @variables[effect]
        @variables[effect] = new_value
        return true
      end
    elsif Input.trigger?(Input::ACTION) && @variables[effect] != true_default
      pbPlayDecisionSE
      @variables[effect] = true_default
      return true
    elsif Input.repeat?(Input::LEFT) && @variables[effect] > min
      pbPlayCursorSE
      @variables[effect] -= 1
      return true
    elsif Input.repeat?(Input::RIGHT) && @variables[effect] < max
      pbPlayCursorSE
      @variables[effect] += 1
      return true
    end
    return false
  end

  def update_input_for_battler_index(effect, variable_data)
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      new_value = choose_battler(@variables[effect])
      if new_value != @variables[effect]
        @variables[effect] = new_value
        return true
      end
    elsif Input.trigger?(Input::ACTION) && @variables[effect] != -1
      pbPlayDecisionSE
      @variables[effect] = -1
      return true
    elsif Input.repeat?(Input::LEFT)
      if @variables[effect] > -1
        pbPlayCursorSE
        loop do
          @variables[effect] -= 1
          break if @variables[effect] == -1 || @battle.battlers[@variables[effect]]
        end
        return true
      end
    elsif Input.repeat?(Input::RIGHT)
      if @variables[effect] < @battle.battlers.length - 1
        pbPlayCursorSE
        loop do
          @variables[effect] += 1
          break if @battle.battlers[@variables[effect]]
        end
        return true
      end
    end
    return false
  end

  def update_input_for_move(effect, variable_data)
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      new_value = pbChooseMoveList(@variables[effect])
      if new_value && new_value != @variables[effect]
        @variables[effect] = new_value
        return true
      end
    elsif Input.trigger?(Input::ACTION) && @variables[effect]
      pbPlayDecisionSE
      @variables[effect] = nil
      return true
    end
    return false
  end

  def update_input_for_item(effect, variable_data)
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      new_value = pbChooseItemList(@variables[effect])
      if new_value && new_value != @variables[effect]
        @variables[effect] = new_value
        return true
      end
    elsif Input.trigger?(Input::ACTION) && @variables[effect]
      pbPlayDecisionSE
      @variables[effect] = nil
      return true
    end
    return false
  end

  def update
    loop do
      Graphics.update
      Input.update
      @window.update
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      end
      index = @window.index
      effect = @variables_data.keys[index]
      variable_data = @variables_data[effect]
      if variable_data[:default] == false
        @window.refresh if update_input_for_boolean(effect, variable_data)
      elsif [0, 1, -2].include?(variable_data[:default])
        @window.refresh if update_input_for_integer(effect, variable_data[:default], variable_data)
      elsif variable_data[:default] == -1
        @window.refresh if update_input_for_battler_index(effect, variable_data)
      elsif variable_data[:default].nil?
        case variable_data[:type]
        when :move
          @window.refresh if update_input_for_move(effect, variable_data)
        when :item
          @window.refresh if update_input_for_item(effect, variable_data)
        else
          raise "Unknown kind of variable!"
        end
      else
        raise "Unknown kind of variable!"
      end
    end
  end
end
