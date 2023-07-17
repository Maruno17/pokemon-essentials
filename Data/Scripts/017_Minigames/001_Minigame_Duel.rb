#===============================================================================
# "Duel" mini-game
# Based on the Duel minigame by Alael
#===============================================================================
class DuelWindow < Window_AdvancedTextPokemon
  attr_reader :hp
  attr_reader :name
  attr_reader :is_enemy

  PLAYER_TEXT_BASE   = Color.new(48, 80, 200)   # Blue
  PLAYER_TEXT_SHADOW = Color.new(160, 192, 240)
  ENEMY_TEXT_BASE    = Color.new(224, 8, 8)   # Red
  ENEMY_TEXT_SHADOW  = Color.new(248, 184, 112)
  HP_TEXT_BASE       = Color.new(32, 152, 8)   # Green
  HP_TEXT_SHADOW     = Color.new(144, 240, 144)

  def initialize(name, is_enemy)
    @hp       = 10
    @name     = name
    @is_enemy = is_enemy
    super()
    self.width  = 160
    self.height = 96
    duel_refresh
  end

  def hp=(value)
    @hp = value
    duel_refresh
  end

  def name=(value)
    @name = value
    duel_refresh
  end

  def is_enemy=(value)
    @is_enemy = value
    duel_refresh
  end

  def duel_refresh
    if @is_enemy
      name_tag = shadowc3tag(ENEMY_TEXT_BASE, ENEMY_TEXT_SHADOW)
    else
      name_tag = shadowc3tag(PLAYER_TEXT_BASE, PLAYER_TEXT_SHADOW)
    end
    hp_tag = shadowc3tag(HP_TEXT_BASE, HP_TEXT_SHADOW)
    self.text = name_tag + fmtEscape(@name) + "\n" + hp_tag + _INTL("HP: {1}", @hp)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonDuel
  def pbStartDuel(opponent, event)
    @event = event
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["player"] = IconSprite.new(-160, 96, @viewport)
    @sprites["player"].setBitmap(GameData::TrainerType.front_sprite_filename($player.trainer_type))
    @sprites["opponent"] = IconSprite.new(Graphics.width + 32, 96, @viewport)
    @sprites["opponent"].setBitmap(GameData::TrainerType.front_sprite_filename(opponent.trainer_type))
    @sprites["playerwindow"] = DuelWindow.new($player.name, false)
    @sprites["playerwindow"].x        = -@sprites["playerwindow"].width
    @sprites["playerwindow"].viewport = @viewport
    @sprites["opponentwindow"] = DuelWindow.new(opponent.name, true)
    @sprites["opponentwindow"].x        = Graphics.width
    @sprites["opponentwindow"].viewport = @viewport
    pbWait(0.5)
    pbWait(0.5) do |delta_t|
      @sprites["player"].x = lerp(-160, 0, 0.4, delta_t)
      @sprites["playerwindow"].x = lerp(-@sprites["playerwindow"].width, 160 - @sprites["playerwindow"].width, 0.4, delta_t)
      @sprites["opponent"].x = lerp(Graphics.width + 32, Graphics.width - 128, 0.4, delta_t)
      @sprites["opponentwindow"].x = lerp(Graphics.width, Graphics.width - 160, 0.4, delta_t)
    end
    @sprites["player"].x = 0
    @sprites["playerwindow"].x = 160 - @sprites["playerwindow"].width
    @sprites["opponent"].x = Graphics.width - 128
    @sprites["opponentwindow"].x = Graphics.width - 160
    @oldmovespeed = $game_player.move_speed
    @oldeventspeed = event.move_speed
    pbMoveRoute($game_player,
                [PBMoveRoute::CHANGE_SPEED, 2,
                 PBMoveRoute::DIRECTION_FIX_ON])
    pbMoveRoute(event,
                [PBMoveRoute::CHANGE_SPEED, 2,
                 PBMoveRoute::DIRECTION_FIX_ON])
    pbWait(0.75)
  end

  def pbDuel(opponent, event, speeches)
    pbStartDuel(opponent, event)
    @hp = [10, 10]
    @special = [false, false]
    decision = nil
    loop do
      @hp[0] = 0 if @hp[0] < 0
      @hp[1] = 0 if @hp[1] < 0
      pbRefresh
      if @hp[0] <= 0
        decision = false
        break
      elsif @hp[1] <= 0
        decision = true
        break
      end
      action = 0
      scores = [3, 4, 4, 2]
      choices = (@special[1]) ? 3 : 4
      scores[3] = 0 if @special[1]
      total = scores[0] + scores[1] + scores[2] + scores[3]
      if total <= 0
        action = rand(choices)
      else
        num = rand(total)
        cumtotal = 0
        4.times do |i|
          cumtotal += scores[i]
          if num < cumtotal
            action = i
            break
          end
        end
      end
      @special[1] = true if action == 3
      pbMessage(_INTL("{1}: {2}", opponent.name, speeches[(action * 3) + rand(3)]))
      list = [
        _INTL("DEFEND"),
        _INTL("PRECISE ATTACK"),
        _INTL("FIERCE ATTACK")
      ]
      list.push(_INTL("SPECIAL ATTACK")) if !@special[0]
      command = pbMessage(_INTL("Choose a command."), list, 0)
      @special[0] = true if command == 3
      if action == 0 && command == 0
        pbMoveRoute($game_player,
                    [PBMoveRoute::SCRIPT_ASYNC, "moveRight90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveLeft90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveLeft90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveRight90"])
        pbMoveRoute(event,
                    [PBMoveRoute::SCRIPT_ASYNC, "moveLeft90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveRight90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveRight90",
                     PBMoveRoute::SCRIPT_ASYNC, "moveLeft90"])
        pbWait(0.5)
        pbMessage(_INTL("You study each other's movements..."))
      elsif action == 0 && command == 1
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::FORWARD])
        pbWait(0.4)
        pbShake(9, 9, 8)
        pbFlashScreens(false, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        @hp[1] -= 1
        pbMessage(_INTL("Your attack was not blocked!"))
      elsif action == 0 && command == 2
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::BACKWARD])
        pbWait(1.0)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::FORWARD])
        pbMessage(_INTL("Your attack was evaded!"))
      elsif [0, 1, 2].include?(action) && command == 3
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbWait(0.4)
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 5,
                     PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbWait(0.5)
        pbShake(9, 9, 8)
        pbFlashScreens(false, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::FORWARD])
        @hp[1] -= 3
        pbMessage(_INTL("You pierce through the opponent's defenses!"))
      elsif action == 1 && command == 0
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::FORWARD])
        pbWait(0.4)
        pbShake(9, 9, 8)
        pbFlashScreens(true, false)
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        @hp[0] -= 1
        pbMessage(_INTL("You fail to block the opponent's attack!"))
      elsif action == 1 && command == 1
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::FORWARD])
        pbWait(0.6)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::FORWARD])
        pbWait(0.6)
        pbMoveRoute(event, [PBMoveRoute::BACKWARD])
        pbMoveRoute($game_player, [PBMoveRoute::FORWARD])
        pbWait(0.6)
        pbMoveRoute($game_player, [PBMoveRoute::BACKWARD])
        pbMessage(_INTL("You cross blades with the opponent!"))
      elsif (action == 1 && command == 2) ||
            (action == 2 && command == 1) ||
            (action == 2 && command == 2)
        pbMoveRoute($game_player,
                    [PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbWait(0.8)
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::FORWARD])
        pbWait(0.9)
        pbShake(9, 9, 8)
        pbFlashScreens(true, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbMoveRoute(event,
                    [PBMoveRoute::BACKWARD,
                     PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbWait(1.0)
        pbMoveRoute(event, [PBMoveRoute::FORWARD])
        pbMoveRoute($game_player, [PBMoveRoute::FORWARD])
        @hp[0] -= action    # Enemy action
        @hp[1] -= command   # Player command
        pbMessage(_INTL("You hit each other!"))
      elsif action == 2 && command == 0
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::FORWARD])
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpBackward"])
        pbWait(1.0)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::FORWARD])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        pbMessage(_INTL("You evade the opponent's attack!"))
      elsif action == 3 && [0, 1, 2].include?(command)
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbWait(0.4)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 5,
                     PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbWait(0.5)
        pbShake(9, 9, 8)
        pbFlashScreens(true, false)
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::FORWARD])
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 2,
                     PBMoveRoute::BACKWARD])
        @hp[0] -= 3
        pbMessage(_INTL("The opponent pierces through your defenses!"))
      elsif action == 3 && command == 3
        pbMoveRoute($game_player, [PBMoveRoute::BACKWARD])
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbMoveRoute(event,
                    [PBMoveRoute::WAIT, 15,
                     PBMoveRoute::CHANGE_SPEED, 4,
                     PBMoveRoute::SCRIPT_ASYNC, "jumpForward"])
        pbWait(1.0)
        pbMoveRoute(event,
                    [PBMoveRoute::CHANGE_SPEED, 5,
                     PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbMoveRoute($game_player,
                    [PBMoveRoute::CHANGE_SPEED, 5,
                     PBMoveRoute::BACKWARD,
                     PBMoveRoute::CHANGE_SPEED, 2])
        pbShake(9, 9, 8)
        pbFlash(Color.new(255, 255, 255, 255), 20)
        pbFlashScreens(true, true)
        pbMoveRoute($game_player, [PBMoveRoute::FORWARD])
        @hp[0] -= 4
        @hp[1] -= 4
        pbMessage(_INTL("Your special attacks collide!"))
      end
    end
    pbEndDuel
    return decision
  end

  def pbEndDuel
    pbWait(0.75)
    pbMoveRoute($game_player,
                [PBMoveRoute::DIRECTION_FIX_OFF,
                 PBMoveRoute::CHANGE_SPEED, @oldmovespeed])
    pbMoveRoute(@event,
                [PBMoveRoute::DIRECTION_FIX_OFF,
                 PBMoveRoute::CHANGE_SPEED, @oldeventspeed])
    pbWait(0.4) do |delta_t|
      new_opacity = lerp(255, 0, 0.4, delta_t)
      @sprites["player"].opacity = new_opacity
      @sprites["opponent"].opacity = new_opacity
      @sprites["playerwindow"].contents_opacity = new_opacity
      @sprites["opponentwindow"].contents_opacity = new_opacity
      @sprites["playerwindow"].opacity = new_opacity
      @sprites["opponentwindow"].opacity = new_opacity
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbFlashScreens(player, opponent)
    pbWait(0.2) do |delta_t|
      new_alpha = lerp(0, 255, 0.2, delta_t)
      if player
        @sprites["player"].color = Color.new(255, 255, 255, new_alpha)
        @sprites["playerwindow"].color = Color.new(255, 255, 255, new_alpha)
      end
      if opponent
        @sprites["opponent"].color = Color.new(255, 255, 255, new_alpha)
        @sprites["opponentwindow"].color = Color.new(255, 255, 255, new_alpha)
      end
    end
    pbWait(0.2) do |delta_t|
      new_alpha = lerp(255, 0, 0.2, delta_t)
      if player
        @sprites["player"].color = Color.new(255, 255, 255, new_alpha)
        @sprites["playerwindow"].color = Color.new(255, 255, 255, new_alpha)
      end
      if opponent
        @sprites["opponent"].color = Color.new(255, 255, 255, new_alpha)
        @sprites["opponentwindow"].color = Color.new(255, 255, 255, new_alpha)
      end
    end
    @sprites["player"].color.alpha = 0
    @sprites["playerwindow"].color.alpha = 0
    @sprites["opponent"].color.alpha = 0
    @sprites["opponentwindow"].color.alpha = 0
    pbWait(0.4) if !player || !opponent
  end

  def pbRefresh
    @sprites["playerwindow"].hp   = @hp[0]
    @sprites["opponentwindow"].hp = @hp[1]
    pbWait(0.25)
  end
end

# Starts a duel.
# trainer_id - ID or symbol of the opponent's trainer type.
# trainer_name - Name of the opponent
# event - Game_Event object for the character's event
# speeches - Array of 12 speeches
def pbDuel(trainer_id, trainer_name, event, speeches)
  trainer_id = GameData::TrainerType.get(trainer_id).id
  duel = PokemonDuel.new
  opponent = NPCTrainer.new(
    pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainer_name), trainer_id
  )
  speech_texts = []
  12.times do |i|
    speech_texts.push(_I(speeches[i]))
  end
  duel.pbDuel(opponent, event, speech_texts)
end
