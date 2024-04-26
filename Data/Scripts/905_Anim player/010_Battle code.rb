#===============================================================================
#
#===============================================================================
class Battle::Scene
  ANIMATION_DEFAULTS = [:TACKLE, :DEFENSECURL]   # With target, without target
  ANIMATION_DEFAULTS_FOR_TYPE_CATEGORY = {
    :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :BODYSLAM,   nil,            :TAILWHIP],
    :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :BULKUP,      nil,         nil,            nil],
    :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,     :FEATHERDANCE],
    :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,          :POISONPOWDER],
    :GROUND   => [:SANDTOMB,     :MUDSLAP,      :MUDSPORT,    :EARTHQUAKE, :EARTHPOWER,    :SANDATTACK],
    :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  nil,            :SANDSTORM],
    :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,   :STRINGSHOT],
    :GHOST    => [:ASTONISH,     :SHADOWBALL,   :GRUDGE,      nil,         nil,            :CONFUSERAY],
    :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,            :METALSOUND],
    :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,    :WILLOWISP],
    :WATER    => [:CRABHAMMER,   :WATERGUN,     :AQUARING,    nil,         :SURF,          :WATERSPORT],
    :GRASS    => [:VINEWHIP,     :RAZORLEAF,    :COTTONGUARD, nil,         nil,            :SPORE],
    :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,     :THUNDERWAVE],
    :PSYCHIC  => [:ZENHEADBUTT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE,  :MIRACLEEYE],
    :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        :AVALANCHE,  :POWDERSNOW,    :HAIL],
    :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,       nil],
    :DARK     => [:KNOCKOFF,     :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,         :EMBARGO],
    :FAIRY    => [:TACKLE,       :FAIRYWIND,    :MOONLIGHT,   nil,         :DAZZLINGGLEAM, :SWEETKISS]
  }

  #-----------------------------------------------------------------------------

  def pbAnimation(move_id, user, targets, version = 0)
    anims = find_move_animation(move_id, version, user&.index)
    return if !anims || anims.empty?
    if anims[0].is_a?(GameData::Animation)   # New animation
      pbSaveShadows do
        # NOTE: anims.sample is a random valid animation.
        play_better_animation(anims.sample, user, targets)
      end
    else                                     # Old animation
      anim = anims[0]
      target = (targets.is_a?(Array)) ? targets[0] : targets
      animations = pbLoadBattleAnimations
      return if !animations
      pbSaveShadows do
        if anims[1]   # On opposing side and using OppMove animation
          pbAnimationCore(animations[anim], target, user, true)
        else           # On player's side, and/or using Move animation
          pbAnimationCore(animations[anim], user, target)
        end
      end
    end
  end

  alias __newanims__pbCommonAnimation pbCommonAnimation unless method_defined?(:__newanims__pbCommonAnimation)
  def pbCommonAnimation(anim_name, user = nil, target = nil)
    return if nil_or_empty?(anim_name)
    anims = try_get_better_common_animation(anim_name, user.index)
    if anims
      # NOTE: anims.sample is a random valid animation.
      play_better_animation(anims.sample, user, target)
    else
      __newanims__pbCommonAnimation(anim_name, user, target)
    end
  end

  #-----------------------------------------------------------------------------

  # Returns an array of GameData::Animation if a new animation(s) is found.
  # Return [animation index, shouldn't be flipped] if an old animation is found.
  def find_move_animation(move_id, version, user_index)
    # Get animation
    anims = find_move_animation_for_move(move_id, version, user_index)
    return anims if anims
    # Get information to decide which default animation to try
    move_data = GameData::Move.get(move_id)
    target_data = GameData::Target.get(move_data.target)
    move_type = move_data.type
    default_idx = move_data.category
    default_idx += 3 if target_data.num_targets > 1 ||
                        (target_data.num_targets > 0 && move_data.status?)
    # Check for a default animation
    wanted_move = ANIMATION_DEFAULTS_FOR_TYPE_CATEGORY[move_type][default_idx]
    anims = find_move_animation_for_move(wanted_move, 0, user_index)
    return anims if anims
    if default_idx >= 3
      wanted_move = ANIMATION_DEFAULTS_FOR_TYPE_CATEGORY[move_type][default_idx - 3]
      anims = find_move_animation_for_move(wanted_move, 0, user_index)
      return anims if anims
      return nil if ANIMATION_DEFAULTS.include?(wanted_move)   # No need to check for these animations twice
    end
    # Use Tackle or Defense Curl's animation
    if target_data.num_targets == 0 && target.data.id != :None
      return find_move_animation_for_move(ANIMATION_DEFAULTS[1], 0, user_index)
    end
    return find_move_animation_for_move(ANIMATION_DEFAULTS[0], 0, user_index)
  end

  # Find an animation(s) for the given move_id.
  def find_move_animation_for_move(move_id, version, user_index)
    # Find new animation
    anims = try_get_better_move_animation(move_id, version, user_index)
    return anims if anims
    if version > 0
      anims = try_get_better_move_animation(move_id, 0, user_index)
      return anims if anims
    end
    # Find old animation
    anim = pbFindMoveAnimDetails(pbLoadMoveToAnim, move_id, user_index, version)
    return anim
  end

  # Finds a new animation for the given move_id and version. Prefers opposing
  # animations if the user is opposing. Can return multiple animations.
  def try_get_better_move_animation(move_id, version, user_index)
    ret = []
    backup_ret = []
    GameData::Animation.each do |anim|
      next if !anim.move_animation? || anim.ignore
      next if anim.move != move_id.to_s
      next if anim.version != version
      if !user_index
        ret.push(anim)
        next
      end
      if user_index.even?   # User is on player's side
        ret.push(anim) if !anim.opposing_animation?
      else                  # User is on opposing side
        (anim.opposing_animation?) ? ret.push(anim) : backup_ret.push(anim)
      end
    end
    return ret if !ret.empty?
    return backup_ret if !backup_ret.empty?
    return nil
  end

  def try_get_better_common_animation(anim_name, user_index)
    ret = []
    backup_ret = []
    GameData::Animation.each do |anim|
      next if !anim.common_animation? || anim.ignore
      next if anim.move != anim_name
      if !user_index
        ret.push(anim)
        next
      end
      if user_index.even?   # User is on player's side
        ret.push(anim) if !anim.opposing_animation?
      else                  # User is on opposing side
        (anim.opposing_animation?) ? ret.push(anim) : backup_ret.push(anim)
      end
    end
    return ret if !ret.empty?
    return backup_ret if !backup_ret.empty?
    return nil
  end

  #-----------------------------------------------------------------------------

  def play_better_animation(anim_data, user, targets)
    return if !anim_data
    @briefMessage = false
    # Memorize old battler coordinates, to be reset after the animation
    old_battler_coords = []
    if user
      sprite = @sprites["pokemon_#{user.index}"]
      old_battler_coords[user.index] = [sprite.x, sprite.y]
    end
    if targets
      targets.each do |target|
        sprite = @sprites["pokemon_#{target.index}"]
        old_battler_coords[target.index] = [sprite.x, sprite.y]
      end
    end
    # Create animation player
    anim_player = AnimationPlayer.new(anim_data, user, targets, self)
    anim_player.set_up
    # Play animation
    anim_player.start
    loop do
      pbUpdate
      anim_player.update
      break if anim_player.can_continue_battle?
    end
    anim_player.dispose
    # Restore old battler coordinates
    old_battler_coords.each_with_index do |values, i|
      next if !values
      sprite = @sprites["pokemon_#{i}"]
      sprite.x = values[0]
      sprite.y = values[1]
    end
  end
end
