class Battle::Scene
  #=============================================================================
  # Animates the battle intro
  #=============================================================================
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
    if @battle.showAnims
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

  #=============================================================================
  # Animates a party lineup appearing for the given side
  #=============================================================================
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

  #=============================================================================
  # Animates an opposing trainer sliding in from off-screen. Will animate a
  # previous trainer that is already on-screen slide off first. Used at the end
  # of battle.
  #=============================================================================
  def pbShowOpponent(idxTrainer)
    # Set up trainer appearing animation
    appearAnim = Animation::TrainerAppear.new(@sprites, @viewport, idxTrainer)
    @animations.push(appearAnim)
    # Play the animation
    while inPartyAnimation?
      pbUpdate
    end
  end

  #=============================================================================
  # Animates a trainer's sprite and party lineup hiding (if they are visible).
  # Animates a Pokémon being sent out into battle, then plays the shiny
  # animation for it if relevant.
  # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
  #=============================================================================
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
      next if !@battle.showAnims || !@battle.battlers[b[0]].shiny?
      if Settings::SUPER_SHINY && @battle.battlers[b[0]].super_shiny?
        pbCommonAnimation("SuperShiny", @battle.battlers[b[0]])
      else
        pbCommonAnimation("Shiny", @battle.battlers[b[0]])
      end
    end
  end

  #=============================================================================
  # Animates a Pokémon being recalled into its Poké Ball and its data box hiding
  #=============================================================================
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

  #=============================================================================
  # Ability splash bar animations
  #=============================================================================
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

  #=============================================================================
  # HP change animations
  #=============================================================================
  # Shows a HP-changing common animation and animates a data box's HP bar.
  # Called by def pbReduceHP, def pbRecoverHP.
  def pbHPChanged(battler, oldHP, showAnim = false)
    @briefMessage = false
    if battler.hp > oldHP
      pbCommonAnimation("HealthUp", battler) if showAnim && @battle.showAnims
    elsif battler.hp < oldHP
      pbCommonAnimation("HealthDown", battler) if showAnim && @battle.showAnims
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

  #=============================================================================
  # Animates a data box's Exp bar
  #=============================================================================
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

  #=============================================================================
  # Shows stats windows upon a Pokémon levelling up
  #=============================================================================
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

  #=============================================================================
  # Animates a Pokémon fainting
  #=============================================================================
  def pbFaintBattler(battler)
    @briefMessage = false
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
  end

  #=============================================================================
  # Animates throwing a Poké Ball at a Pokémon in an attempt to catch it
  #=============================================================================
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

  #=============================================================================
  # Hides all battler shadows before yielding to a move animation, and then
  # restores the shadows afterwards
  #=============================================================================
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

  #=============================================================================
  # Loads a move/common animation
  #=============================================================================
  # Returns the animation ID to use for a given move/user. Returns nil if that
  # move has no animations defined for it.
  def pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum = 0)
    real_move_id = GameData::Move.try_get(moveID)&.id || moveID
    noFlip = false
    if (idxUser & 1) == 0   # On player's side
      anim = move2anim[0][real_move_id]
    else                # On opposing side
      anim = move2anim[1][real_move_id]
      noFlip = true if anim
      anim = move2anim[0][real_move_id] if !anim
    end
    return [anim + hitNum, noFlip] if anim
    return nil
  end

  # Returns the animation ID to use for a given move. If the move has no
  # animations, tries to use a default move animation depending on the move's
  # type. If that default move animation doesn't exist, trues to use Tackle's
  # move animation. Returns nil if it can't find any of these animations to use.
  def pbFindMoveAnimation(moveID, idxUser, hitNum)
    begin
      move2anim = pbLoadMoveToAnim
      # Find actual animation requested (an opponent using the animation first
      # looks for an OppMove version then a Move version)
      anim = pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
      return anim if anim
      # Actual animation not found, get the default animation for the move's type
      moveData = GameData::Move.get(moveID)
      target_data = GameData::Target.get(moveData.target)
      moveType = moveData.type
      moveKind = moveData.category
      moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
      moveKind += 3 if moveData.status? && target_data.num_targets > 0
      # [one target physical, one target special, user status,
      #  multiple targets physical, multiple targets special, non-user status]
      typeDefaultAnim = {
        :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,  :SWIFT,        :TAILWHIP],
        :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,         nil,           nil],
        :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,    :FEATHERDANCE],
        :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,         :POISONPOWDER],
        :GROUND   => [:SANDTOMB,     :MUDSLAP,      nil,          :EARTHQUAKE, :EARTHPOWER,   :MUDSPORT],
        :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  nil,           :SANDSTORM],
        :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,  :STRINGSHOT],
        :GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,         nil,           :CONFUSERAY],
        :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,           :METALSOUND],
        :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,   :WILLOWISP],
        :WATER    => [:CRABHAMMER,   :WATERGUN,     :AQUARING,    nil,         :SURF,         :WATERSPORT],
        :GRASS    => [:VINEWHIP,     :MEGADRAIN,    :COTTONGUARD, :RAZORLEAF,  nil,           :SPORE],
        :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,    :THUNDERWAVE],
        :PSYCHIC  => [:ZENHEADBUTT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE, :MIRACLEEYE],
        :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,         :POWDERSNOW,   :HAIL],
        :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,      nil],
        :DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,        :EMBARGO],
        :FAIRY    => [:TACKLE,       :FAIRYWIND,    :MOONLIGHT,   nil,         :SWIFT,        :SWEETKISS]
      }
      if typeDefaultAnim[moveType]
        anims = typeDefaultAnim[moveType]
        if GameData::Move.exists?(anims[moveKind])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
        end
        if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
        end
        if !anim && GameData::Move.exists?(anims[2])
          anim = pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
        end
      end
      return anim if anim
      # Default animation for the move's type not found, use Tackle's animation
      if GameData::Move.exists?(:TACKLE)
        return pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
      end
    rescue
    end
    return nil
  end

  #=============================================================================
  # Plays a move/common animation
  #=============================================================================
  # Plays a move animation.
  def pbAnimation(moveID, user, targets, hitNum = 0)
    animID = pbFindMoveAnimation(moveID, user.index, hitNum)
    return if !animID
    anim = animID[0]
    target = (targets.is_a?(Array)) ? targets[0] : targets
    animations = pbLoadBattleAnimations
    return if !animations
    pbSaveShadows do
      if animID[1]   # On opposing side and using OppMove animation
        pbAnimationCore(animations[anim], target, user, true)
      else           # On player's side, and/or using Move animation
        pbAnimationCore(animations[anim], user, target)
      end
    end
  end

  # Plays a common animation.
  def pbCommonAnimation(animName, user = nil, target = nil)
    return if nil_or_empty?(animName)
    target = target[0] if target.is_a?(Array)
    animations = pbLoadBattleAnimations
    return if !animations
    animations.each do |a|
      next if !a || a.name != "Common:" + animName
      pbAnimationCore(a, user, target || user)
      return
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

  # Ball burst common animations should have a focus of "Target" and a priority
  # of "Front".
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
end
