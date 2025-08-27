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

  # Animates the battle intro.
  def pbBattleIntroAnimation
    # Make everything appear
    introAnim = Animation::Intro.new(@sprites, @viewport, @battle)
    loop do
      introAnim.update
      pbUpdate
      break if introAnim.animDone?
    end
    introAnim.dispose
    # Post-appearance activities
    # Trainer battle: get ready to show the party lineups (they are brought
    # on-screen by a separate animation)
    if @battle.trainerBattle?
      # NOTE: Here is where you'd make trainer sprites animate if they had an
      #       entrance animation. Be sure to set it up like a Pokémon entrance
      #       animation, i.e. add them to @animations so that they can play out
      #       while party lineups appear and messages show.
      pbShowPartyLineup(0, true)
      pbShowPartyLineup(1, true)
      return
    end
    # Wild battle: play wild Pokémon's intro animations (including cry), show
    # data box(es), return the wild Pokémon's sprite(s) to normal colour, show
    # shiny animation(s)
    # Set up data box animation
    @battle.sideSizes[1].times do |i|
      idxBattler = (2 * i) + 1
      next if !@battle.battlers[idxBattler]
      dataBoxAnim = Animation::DataBoxAppear.new(@sprites, @viewport, idxBattler)
      @animations.push(dataBoxAnim)
    end
    # Set up wild Pokémon returning to normal colour and playing intro
    # animations (including cry)
    @animations.push(Animation::Intro2.new(@sprites, @viewport, @battle.sideSizes[1]))
    # Play all the animations
    while inPartyAnimation?
      pbUpdate
    end
    # Show shiny animation for wild Pokémon
    if !@battle.rules[:no_battle_animations]
      @battle.sideSizes[1].times do |i|
        idxBattler = (2 * i) + 1
        next if !@battle.battlers[idxBattler] || !@battle.battlers[idxBattler].shiny?
        if Settings::SUPER_SHINY && @battle.battlers[idxBattler].super_shiny?
          pbCommonAnimation("SuperShiny", @battle.battlers[idxBattler])
        else
          pbCommonAnimation("Shiny", @battle.battlers[idxBattler])
        end
      end
    end
  end

  # Animates a party lineup appearing for the given side.
  def pbShowPartyLineup(side, fullAnim = false)
    @animations.push(
      Animation::LineupAppear.new(@sprites, @viewport, side,
                                  @battle.pbParty(side), @battle.pbPartyStarts(side),
                                  fullAnim)
    )
    return if fullAnim
    while inPartyAnimation?
      pbUpdate
    end
  end

  # Animates an opposing trainer sliding in from off-screen. Will animate a
  # previous trainer that is already on-screen slide off first. Used at the end
  # of battle.
  def pbShowOpponent(idxTrainer)
    # Set up trainer appearing animation
    appearAnim = Animation::TrainerAppear.new(@sprites, @viewport, idxTrainer)
    @animations.push(appearAnim)
    # Play the animation
    while inPartyAnimation?
      pbUpdate
    end
  end

  # Animates a trainer's sprite and party lineup hiding (if they are visible).
  # Animates a Pokémon being sent out into battle, then plays the shiny
  # animation for it if relevant.
  # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
  def pbSendOutBattlers(sendOuts, startBattle = false)
    return if sendOuts.length == 0
    # If party balls are still appearing, wait for them to finish showing up, as
    # the FadeAnimation will make them disappear.
    while inPartyAnimation?
      pbUpdate
    end
    @briefMessage = false
    # Make all trainers and party lineups disappear (player-side trainers may
    # animate throwing a Poké Ball)
    if @battle.opposes?(sendOuts[0][0])
      fadeAnim = Animation::TrainerFade.new(@sprites, @viewport, startBattle)
    else
      fadeAnim = Animation::PlayerFade.new(@sprites, @viewport, startBattle)
    end
    # For each battler being sent out, set the battler's sprite and create two
    # animations (the Poké Ball moving and battler appearing from it, and its
    # data box appearing)
    sendOutAnims = []
    sendOuts.each_with_index do |b, i|
      pkmn = @battle.battlers[b[0]].effects[PBEffects::Illusion] || b[1]
      pbChangePokemon(b[0], pkmn)
      pbRefresh
      if @battle.opposes?(b[0])
        sendOutAnim = Animation::PokeballTrainerSendOut.new(
          @sprites, @viewport, @battle.pbGetOwnerIndexFromBattlerIndex(b[0]) + 1,
          @battle.battlers[b[0]], startBattle, i
        )
      else
        sendOutAnim = Animation::PokeballPlayerSendOut.new(
          @sprites, @viewport, @battle.pbGetOwnerIndexFromBattlerIndex(b[0]) + 1,
          @battle.battlers[b[0]], startBattle, i
        )
      end
      dataBoxAnim = Animation::DataBoxAppear.new(@sprites, @viewport, b[0])
      sendOutAnims.push([sendOutAnim, dataBoxAnim, false])
    end
    # Play all animations
    loop do
      fadeAnim.update
      sendOutAnims.each do |a|
        next if a[2]
        a[0].update
        a[1].update if a[0].animDone?
        a[2] = true if a[1].animDone?
      end
      pbUpdate
      break if !inPartyAnimation? && sendOutAnims.none? { |a| !a[2] }
    end
    fadeAnim.dispose
    sendOutAnims.each do |a|
      a[0].dispose
      a[1].dispose
    end
    # Play shininess animations for shiny Pokémon
    sendOuts.each do |b|
      next if @battle.rules[:no_battle_animations] || !@battle.battlers[b[0]].shiny?
      if Settings::SUPER_SHINY && @battle.battlers[b[0]].super_shiny?
        pbCommonAnimation("SuperShiny", @battle.battlers[b[0]])
      else
        pbCommonAnimation("Shiny", @battle.battlers[b[0]])
      end
    end
  end

  # Animates a Pokémon being recalled into its Poké Ball and its data box hiding.
  def pbRecall(idxBattler)
    @briefMessage = false
    # Recall animation
    recallAnim = Animation::BattlerRecall.new(@sprites, @viewport, @battle.battlers[idxBattler])
    loop do
      recallAnim&.update
      pbUpdate
      break if recallAnim.animDone?
    end
    recallAnim.dispose
    # Data box disappear animation
    dataBoxAnim = Animation::DataBoxDisappear.new(@sprites, @viewport, idxBattler)
    loop do
      dataBoxAnim.update
      pbUpdate
      break if dataBoxAnim.animDone?
    end
    dataBoxAnim.dispose
  end

  #-----------------------------------------------------------------------------
  # Ability splash bar animations.
  #-----------------------------------------------------------------------------

  def pbShowAbilitySplash(battler)
    return if !USE_ABILITY_SPLASH
    side = battler.index % 2
    pbHideAbilitySplash(battler) if @sprites["abilityBar_#{side}"].visible
    @sprites["abilityBar_#{side}"].battler = battler
    abilitySplashAnim = Animation::AbilitySplashAppear.new(@sprites, @viewport, side)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end

  def pbHideAbilitySplash(battler)
    return if !USE_ABILITY_SPLASH
    side = battler.index % 2
    return if !@sprites["abilityBar_#{side}"].visible
    abilitySplashAnim = Animation::AbilitySplashDisappear.new(@sprites, @viewport, side)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end

  def pbReplaceAbilitySplash(battler)
    return if !USE_ABILITY_SPLASH
    pbShowAbilitySplash(battler)
  end

  #-----------------------------------------------------------------------------
  # HP change animations.
  #-----------------------------------------------------------------------------

  # Shows a HP-changing common animation and animates a data box's HP bar.
  # Called by def pbReduceHP, def pbRecoverHP.
  def pbHPChanged(battler, oldHP, showAnim = false)
    @briefMessage = false
    if battler.hp > oldHP
      pbCommonAnimation("HealthUp", battler) if showAnim && !@battle.rules[:no_battle_animations]
    elsif battler.hp < oldHP
      pbCommonAnimation("HealthDown", battler) if showAnim && !@battle.rules[:no_battle_animations]
    end
    @sprites["dataBox_#{battler.index}"].animate_hp(oldHP, battler.hp)
    while @sprites["dataBox_#{battler.index}"].animating_hp?
      pbUpdate
    end
  end

  def pbDamageAnimation(battler, effectiveness = 0)
    @briefMessage = false
    # Damage animation
    damageAnim = Animation::BattlerDamage.new(@sprites, @viewport, battler.index, effectiveness)
    loop do
      damageAnim.update
      pbUpdate
      break if damageAnim.animDone?
    end
    damageAnim.dispose
  end

  # Animates battlers flashing and data boxes' HP bars because of damage taken
  # by an attack. targets is an array, which are all animated simultaneously.
  # Each element in targets is also an array: [battler, old HP, effectiveness]
  def pbHitAndHPLossAnimation(targets)
    @briefMessage = false
    # Set up animations
    damageAnims = []
    targets.each do |t|
      anim = Animation::BattlerDamage.new(@sprites, @viewport, t[0].index, t[2])
      damageAnims.push(anim)
      @sprites["dataBox_#{t[0].index}"].animate_hp(t[1], t[0].hp)
    end
    # Update loop
    loop do
      damageAnims.each { |a| a.update }
      pbUpdate
      allDone = true
      targets.each do |t|
        next if !@sprites["dataBox_#{t[0].index}"].animating_hp?
        allDone = false
        break
      end
      next if !allDone
      damageAnims.each do |a|
        next if a.animDone?
        allDone = false
        break
      end
      next if !allDone
      break
    end
    damageAnims.each { |a| a.dispose }
  end

  #-----------------------------------------------------------------------------

  # Animates a data box's Exp bar.
  def pbEXPBar(battler, startExp, endExp, tempExp1, tempExp2)
    return if !battler || endExp == startExp
    startExpLevel = tempExp1 - startExp
    endExpLevel   = tempExp2 - startExp
    expRange      = endExp - startExp
    dataBox = @sprites["dataBox_#{battler.index}"]
    dataBox.animate_exp(startExpLevel, endExpLevel, expRange)
    while dataBox.animating_exp?
      pbUpdate
    end
  end

  # Shows stats windows upon a Pokémon levelling up.
  def pbLevelUp(pkmn, _battler, oldTotalHP, oldAttack, oldDefense, oldSpAtk, oldSpDef, oldSpeed)
    pbTopRightWindow(
      _INTL("Max. HP<r>+{1}\nAttack<r>+{2}\nDefense<r>+{3}\nSp. Atk<r>+{4}\nSp. Def<r>+{5}\nSpeed<r>+{6}",
            pkmn.totalhp - oldTotalHP, pkmn.attack - oldAttack, pkmn.defense - oldDefense,
            pkmn.spatk - oldSpAtk, pkmn.spdef - oldSpDef, pkmn.speed - oldSpeed)
    )
    pbTopRightWindow(
      _INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
            pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed)
    )
  end

  # Animates a Pokémon fainting.
  def pbFaintBattler(battler)
    @briefMessage = false
    old_height = @sprites["pokemon_#{battler.index}"].src_rect.height
    # Pokémon plays cry and drops down, data box disappears
    faintAnim   = Animation::BattlerFaint.new(@sprites, @viewport, battler.index, @battle)
    dataBoxAnim = Animation::DataBoxDisappear.new(@sprites, @viewport, battler.index)
    loop do
      faintAnim.update
      dataBoxAnim.update
      pbUpdate
      break if faintAnim.animDone? && dataBoxAnim.animDone?
    end
    faintAnim.dispose
    dataBoxAnim.dispose
    @sprites["pokemon_#{battler.index}"].src_rect.height = old_height
  end

  #-----------------------------------------------------------------------------
  # Animates throwing a Poké Ball at a Pokémon in an attempt to catch it.
  #-----------------------------------------------------------------------------

  def pbThrow(ball, shakes, critical, targetBattler, showPlayer = false)
    @briefMessage = false
    captureAnim = Animation::PokeballThrowCapture.new(
      @sprites, @viewport, ball, shakes, critical, @battle.battlers[targetBattler], showPlayer
    )
    loop do
      captureAnim.update
      pbUpdate
      break if captureAnim.animDone? && !inPartyAnimation?
    end
    captureAnim.dispose
  end

  def pbThrowSuccess
    return if @battle.opponent
    @briefMessage = false
    pbMEPlay(pbGetWildCaptureME)
    timer_start = System.uptime
    loop do
      pbUpdate
      break if System.uptime - timer_start >= 3.5
    end
    pbMEStop
  end

  def pbHideCaptureBall(idxBattler)
    # NOTE: It's not really worth writing a whole Battle::Scene::Animation class
    #       for making the capture ball fade out.
    ball = @sprites["captureBall"]
    return if !ball
    # Data box disappear animation
    dataBoxAnim = Animation::DataBoxDisappear.new(@sprites, @viewport, idxBattler)
    timer_start = System.uptime
    loop do
      dataBoxAnim.update
      ball.opacity = lerp(255, 0, 1.0, timer_start, System.uptime)
      pbUpdate
      break if dataBoxAnim.animDone? && ball.opacity <= 0
    end
    dataBoxAnim.dispose
  end

  def pbThrowAndDeflect(ball, idxBattler)
    @briefMessage = false
    throwAnim = Animation::PokeballThrowDeflect.new(
      @sprites, @viewport, ball, @battle.battlers[idxBattler]
    )
    loop do
      throwAnim.update
      pbUpdate
      break if throwAnim.animDone?
    end
    throwAnim.dispose
  end

  #-----------------------------------------------------------------------------

  # Hides all battler shadows before yielding to a move animation, and then
  # restores the shadows afterwards.
  def pbSaveShadows
    # Remember which shadows were visible
    shadows = Array.new(@battle.battlers.length) do |i|
      shadow = @sprites["shadow_#{i}"]
      ret = (shadow) ? shadow.visible : false
      shadow.visible = false if shadow
      next ret
    end
    # Yield to other code, i.e. playing an animation
    yield
    # Restore shadow visibility
    @battle.battlers.length.times do |i|
      shadow = @sprites["shadow_#{i}"]
      shadow.visible = shadows[i] if shadow
    end
  end

  #-----------------------------------------------------------------------------
  # Loads a move animation.
  #-----------------------------------------------------------------------------

  # Returns an array of GameData::Animation if a new animation(s) is found.
  # Return [animation index, shouldn't be flipped] if an old animation is found.
  def find_move_animation(move_id, version, user_index)
    # Get animation
    anims = find_move_animation_for_move(move_id, version, user_index)
    return anims if anims
    # Get information to decide which default animation to try
    # TODO: This is going to crash if the animation is for Struggle which isn't
    #       a defined move.
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
    if target_data.num_targets == 0 && target_data.id != :None
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
    anim = pbFindMoveAnimDetails(move_id, user_index, version)
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

  # Returns the animation ID to use for a given move/user. Returns nil if that
  # move has no animations defined for it.
  def pbFindMoveAnimDetails(moveID, idxUser, hitNum = 0)
    real_move_id = GameData::Move.try_get(moveID)&.id || moveID
    anims = pbLoadBattleAnimations
    return nil if !anims
    anim_id = -1
    foe_anim_id = -1
    no_flip = false
    anims.length.times do |i|
      next if !anims[i]
      if anims[i].name[/^OppMove\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          foe_anim_id = i if moveid == real_move_id
        end
      elsif anims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          anim_id = i if moveid == real_move_id
        end
      end
    end
    if (idxUser & 1) == 0   # On player's side
      anim = anim_id
    else                # On opposing side
      anim = foe_anim_id
      no_flip = true if anim >= 0
      anim = anim_id if anim < 0
    end
    return [anim + hitNum, no_flip] if anim >= 0
    return nil
  end

  #-----------------------------------------------------------------------------
  # Loads a common animation.
  #-----------------------------------------------------------------------------

  def try_get_better_common_animation(anim_name, user_index)
    # Find a new format common animation to play
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
    # Find an old format common animation to play
    target = target[0] if target.is_a?(Array)
    animations = pbLoadBattleAnimations
    return nil if !animations
    animations.each do |anim|
      next if !anim || anim.name != "Common:" + anim_name
      ret = anim
      break
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Plays a move/common animation.
  #-----------------------------------------------------------------------------

  # Plays a move animation.
  def pbAnimation(move_id, user, targets, version = 0)
    anims = find_move_animation(move_id, version, user&.index)
    return if !anims || anims.empty?
    if anims[0].is_a?(GameData::Animation)   # New format animation
      pbSaveShadows do
        # NOTE: anims.sample is a random valid animation.
        play_better_animation(anims.sample, user, targets)
      end
    else                                     # Old format animation
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

  # Plays a common animation.
  def pbCommonAnimation(anim_name, user = nil, target = nil)
    return if nil_or_empty?(anim_name)
    # Find an animation to play (new format or old format)
    anims = try_get_better_common_animation(anim_name, user&.index)
    return if !anims
    # Play a new format animation
    if anims.is_a?(Array)
      # NOTE: anims.sample is a random valid animation.
      play_better_animation(anims.sample, user, target)
      return
    end
    # Play an old format animation
    target = target[0] if target.is_a?(Array)
    pbAnimationCore(anims, user, target || user)
  end

  # Ball burst common animations should have a focus of "Target" and a priority
  # of "Front".
  # TODO: This is unused. It also doesn't support the new animation format.
  def pbBallBurstCommonAnimation(_picture_ex, anim_name, battler, target_x, target_y)
    return if nil_or_empty?(anim_name)
    animations = pbLoadBattleAnimations
    anim = animations&.get_from_name("Common:" + anim_name)
    return if !anim
    animPlayer = PBAnimationPlayerX.new(anim, battler, nil, self)
    animPlayer.discard_user_and_target_sprites   # Don't involve user/target in animation
    animPlayer.set_target_origin(target_x, target_y)
    animPlayer.start
    @animations.push(animPlayer)
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

  def pbAnimationCore(animation, user, target, oppMove = false)
    return if !animation
    @briefMessage = false
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    # Remember the original positions of Pokémon sprites
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    # Create the animation player
    animPlayer = PBAnimationPlayerX.new(animation, user, target, self, oppMove)
    # Apply a transformation to the animation based on where the user and target
    # actually are. Get the centres of each sprite.
    userHeight = (userSprite&.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
      FOCUSUSER_X, FOCUSUSER_Y, FOCUSTARGET_X, FOCUSTARGET_Y,
      oldUserX, oldUserY - (userHeight / 2), oldTargetX, oldTargetY - (targetHeight / 2)
    )
    # Play the animation
    animPlayer.start
    loop do
      animPlayer.update
      pbUpdate
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    # Return Pokémon sprites to their original positions
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
  end
end
