module PokeBattle_SceneConstants
  USE_ABILITY_SPLASH = true
  # Text colors
  MESSAGE_BASE_COLOR   = Color.new(80,80,88)
  MESSAGE_SHADOW_COLOR = Color.new(160,160,168)

  # The number of party balls to show in each side's lineup.
  NUM_BALLS = 6

  # Centre bottom of the player's side base graphic
  PLAYER_BASE_X = 128
  PLAYER_BASE_Y = Graphics.height - 80

  # Centre middle of the foe's side base graphic
  FOE_BASE_X    = Graphics.width - 128
  FOE_BASE_Y    = (Graphics.height * 3/4) - 112

  # Returns where the centre bottom of a battler's sprite should be, given its
  # index and the number of battlers on its side, assuming the battler has
  # metrics of 0 (those are added later).
  def self.pbBattlerPosition(index,sideSize=1)
    # Start at the centre of the base for the appropriate side
    if (index&1)==0; ret = [PLAYER_BASE_X,PLAYER_BASE_Y]
    else;            ret = [FOE_BASE_X,FOE_BASE_Y]
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
    when 2
      ret[0] += [-48, 48, 32, -32][index]
      ret[1] += [  0,  0, 16, -16][index]
    when 3
      ret[0] += [-80, 80,  0,  0, 80, -80][index]
      ret[1] += [  0,  0,  8, -8, 16, -16][index]
    end
    return ret
  end

  # Returns where the centre bottom of a trainer's sprite should be, given its
  # side (0/1), index and the number of trainers on its side.
  def self.pbTrainerPosition(side,index=0,sideSize=1)
    # Start at the centre of the base for the appropriate side
    if side==0; ret = [PLAYER_BASE_X,PLAYER_BASE_Y-16]
    else;       ret = [FOE_BASE_X,FOE_BASE_Y+6]
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
    when 2
      ret[0] += [-48, 48, 32, -32][2*index+side]
      ret[1] += [  0,  0,  0, -16][2*index+side]
    when 3
      ret[0] += [-80, 80,  0,  0, 80, -80][2*index+side]
      ret[1] += [  0,  0,  0, -8,  0, -16][2*index+side]
    end
    return ret
  end

  # Default focal points of user and target in animations - do not change!
  # Is the centre middle of each sprite
  FOCUSUSER_X   = 128   # 144
  FOCUSUSER_Y   = 224   # 188
  FOCUSTARGET_X = 384   # 352
  FOCUSTARGET_Y = 96    # 108, 98
end