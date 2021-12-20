#===============================================================================
# "Duel" mini-game
# Based on the Duel minigame by Alael
#===============================================================================
class DuelWindow < Window_AdvancedTextPokemon
  attr_reader :hp
  attr_reader :name
  attr_reader :is_enemy

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
    name_color = @is_enemy ? "<ar><c3=E00808,F8B870>" : "<c3=3050C8,A0C0F0>"
    hp_color   = "<c3=209808,90F090>"
    self.text = _INTL("{1}{2}\r\n{3}HP: {4}", name_color, fmtescape(@name), hp_color, @hp)
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
    @sprites["player"] = IconSprite.new(-128 - 32, 96, @viewport)
    @sprites["player"].setBitmap(GameData::TrainerType.front_sprite_filename($player.trainer_type))
    @sprites["opponent"] = IconSprite.new(Graphics.width + 32, 96, @viewport)
    @sprites["opponent"].setBitmap(GameData::TrainerType.front_sprite_filename(opponent.trainer_type))
    @sprites["playerwindow"] = DuelWindow.new($player.name, false)
    @sprites["playerwindow"].x        = -@sprites["playerwindow"].width
    @sprites["playerwindow"].viewport = @viewport
    @sprites["opponentwindow"] = DuelWindow.new(opponent.name, true)
    @sprites["opponentwindow"].x        = Graphics.width
    @sprites["opponentwindow"].viewport = @viewport
    pbWait(Graphics.frame_rate / 2)
    distance_per_frame = 8 * 20 / Graphics.frame_rate
    while @sprites["player"].x < 0
      @sprites["player"].x         += distance_per_frame
      @sprites["playerwindow"].x   += distance_per_frame
      @sprites["opponent"].x       -= distance_per_frame
      @sprites["opponentwindow"].x -= distance_per_frame
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    @oldmovespeed = $game_player.move_speed
    @oldeventspeed = event.move_speed
    pbMoveRoute($game_player,
                [PBMoveRoute::ChangeSpeed, 2,
                 PBMoveRoute::DirectionFixOn])
    pbMoveRoute(event,
                [PBMoveRoute::ChangeSpeed, 2,
                 PBMoveRoute::DirectionFixOn])
    pbWait(Graphics.frame_rate * 3 / 4)
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
                    [PBMoveRoute::ScriptAsync, "moveRight90",
                     PBMoveRoute::ScriptAsync, "moveLeft90",
                     PBMoveRoute::ScriptAsync, "moveLeft90",
                     PBMoveRoute::ScriptAsync, "moveRight90"])
        pbMoveRoute(event,
                    [PBMoveRoute::ScriptAsync, "moveLeft90",
                     PBMoveRoute::ScriptAsync, "moveRight90",
                     PBMoveRoute::ScriptAsync, "moveRight90",
                     PBMoveRoute::ScriptAsync, "moveLeft90"])
        pbWait(Graphics.frame_rate / 2)
        pbMessage(_INTL("You study each other's movements..."))
      elsif action == 0 && command == 1
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 4 / 10)
        pbShake(9, 9, 8)
        pbFlashScreens(false, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        @hp[1] -= 1
        pbMessage(_INTL("Your attack was not blocked!"))
      elsif action == 0 && command == 2
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Backward])
        pbWait(Graphics.frame_rate)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Forward])
        pbMessage(_INTL("Your attack was evaded!"))
      elsif [0, 1, 2].include?(action) && command == 3
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbWait(Graphics.frame_rate * 4 / 10)
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 5,
                     PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbWait(Graphics.frame_rate / 2)
        pbShake(9, 9, 8)
        pbFlashScreens(false, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Forward])
        @hp[1] -= 3
        pbMessage(_INTL("You pierce through the opponent's defenses!"))
      elsif action == 1 && command == 0
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 4 / 10)
        pbShake(9, 9, 8)
        pbFlashScreens(true, false)
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        @hp[0] -= 1
        pbMessage(_INTL("You fail to block the opponent's attack!"))
      elsif action == 1 && command == 1
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 6 / 10)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 6 / 10)
        pbMoveRoute(event, [PBMoveRoute::Backward])
        pbMoveRoute($game_player, [PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 6 / 10)
        pbMoveRoute($game_player, [PBMoveRoute::Backward])
        pbMessage(_INTL("You cross blades with the opponent!"))
      elsif (action == 1 && command == 2) ||
            (action == 2 && command == 1) ||
            (action == 2 && command == 2)
        pbMoveRoute($game_player,
                    [PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbWait(Graphics.frame_rate * 8 / 10)
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Forward])
        pbWait(Graphics.frame_rate * 9 / 10)
        pbShake(9, 9, 8)
        pbFlashScreens(true, true)
        pbMoveRoute($game_player,
                    [PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbMoveRoute(event,
                    [PBMoveRoute::Backward,
                     PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbWait(Graphics.frame_rate)
        pbMoveRoute(event, [PBMoveRoute::Forward])
        pbMoveRoute($game_player, [PBMoveRoute::Forward])
        @hp[0] -= action    # Enemy action
        @hp[1] -= command   # Player command
        pbMessage(_INTL("You hit each other!"))
      elsif action == 2 && command == 0
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::Forward])
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpBackward"])
        pbWait(Graphics.frame_rate)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Forward])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        pbMessage(_INTL("You evade the opponent's attack!"))
      elsif action == 3 && [0, 1, 2].include?(command)
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbWait(Graphics.frame_rate * 4 / 10)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 5,
                     PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbWait(Graphics.frame_rate / 2)
        pbShake(9, 9, 8)
        pbFlashScreens(true, false)
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Forward])
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 2,
                     PBMoveRoute::Backward])
        @hp[0] -= 3
        pbMessage(_INTL("The opponent pierces through your defenses!"))
      elsif action == 3 && command == 3
        pbMoveRoute($game_player, [PBMoveRoute::Backward])
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbMoveRoute(event,
                    [PBMoveRoute::Wait, 15,
                     PBMoveRoute::ChangeSpeed, 4,
                     PBMoveRoute::ScriptAsync, "jumpForward"])
        pbWait(Graphics.frame_rate)
        pbMoveRoute(event,
                    [PBMoveRoute::ChangeSpeed, 5,
                     PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbMoveRoute($game_player,
                    [PBMoveRoute::ChangeSpeed, 5,
                     PBMoveRoute::Backward,
                     PBMoveRoute::ChangeSpeed, 2])
        pbShake(9, 9, 8)
        pbFlash(Color.new(255, 255, 255, 255), 20)
        pbFlashScreens(true, true)
        pbMoveRoute($game_player, [PBMoveRoute::Forward])
        @hp[0] -= 4
        @hp[1] -= 4
        pbMessage(_INTL("Your special attacks collide!"))
      end
    end
    pbEndDuel
    return decision
  end

  def pbEndDuel
    pbWait(Graphics.frame_rate * 3 / 4)
    pbMoveRoute($game_player,
                [PBMoveRoute::DirectionFixOff,
                 PBMoveRoute::ChangeSpeed, @oldmovespeed])
    pbMoveRoute(@event,
                [PBMoveRoute::DirectionFixOff,
                 PBMoveRoute::ChangeSpeed, @oldeventspeed])
    fade_time = Graphics.frame_rate * 4 / 10
    alpha_diff = (255.0 / fade_time).ceil
    fade_time.times do
      @sprites["player"].opacity                  -= alpha_diff
      @sprites["opponent"].opacity                -= alpha_diff
      @sprites["playerwindow"].contents_opacity   -= alpha_diff
      @sprites["opponentwindow"].contents_opacity -= alpha_diff
      @sprites["playerwindow"].opacity            -= alpha_diff
      @sprites["opponentwindow"].opacity          -= alpha_diff
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbFlashScreens(player, opponent)
    i = 0
    flash_time = Graphics.frame_rate * 2 / 10
    alpha_diff = (2 * 255.0 / flash_time).ceil
    flash_time.times do
      i += 1
      if player
        @sprites["player"].color       = Color.new(255, 255, 255, i * alpha_diff)
        @sprites["playerwindow"].color = Color.new(255, 255, 255, i * alpha_diff)
      end
      if opponent
        @sprites["opponent"].color       = Color.new(255, 255, 255, i * alpha_diff)
        @sprites["opponentwindow"].color = Color.new(255, 255, 255, i * alpha_diff)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    flash_time.times do
      i -= 1
      if player
        @sprites["player"].color       = Color.new(255, 255, 255, i * alpha_diff)
        @sprites["playerwindow"].color = Color.new(255, 255, 255, i * alpha_diff)
      end
      if opponent
        @sprites["opponent"].color       = Color.new(255, 255, 255, i * alpha_diff)
        @sprites["opponentwindow"].color = Color.new(255, 255, 255, i * alpha_diff)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    pbWait(Graphics.frame_rate * 4 / 10) if !player || !opponent
  end

  def pbRefresh
    @sprites["playerwindow"].hp   = @hp[0]
    @sprites["opponentwindow"].hp = @hp[1]
    pbWait(Graphics.frame_rate / 4)
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
    pbGetMessageFromHash(MessageTypes::TrainerNames, trainer_name), trainer_id
  )
  speech_texts = []
  12.times do |i|
    speech_texts.push(_I(speeches[i]))
  end
  duel.pbDuel(opponent, event, speech_texts)
end
