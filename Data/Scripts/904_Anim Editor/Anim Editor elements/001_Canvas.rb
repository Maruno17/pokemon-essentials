#===============================================================================
# TODO
#===============================================================================
class AnimationEditor::Canvas < Sprite
  attr_reader :bg_name

  def initialize(viewport)
    super
    @bg_val = ""
    # TODO: Add a second bg sprite for screen shake purposes.
    player_base_pos = Battle::Scene.pbBattlerPosition(0)
    @player_base = IconSprite.new(*player_base_pos, viewport)
    @player_base.z = 1
    foe_base_pos = Battle::Scene.pbBattlerPosition(1)
    @foe_base = IconSprite.new(*foe_base_pos, viewport)
    @foe_base.z = 1
    @message_bar_sprite = Sprite.new(viewport)
    @message_bar_sprite.z = 999
  end

  def dispose
    @message_bar_sprite.dispose
    @player_base.dispose
    @foe_base.dispose
    super
  end

  def bg_name=(val)
    return if @bg_name == val
    @bg_name = val
    # TODO: Come up with a better way to define the base filenames, based on
    #       which files actually exist.
    self.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_bg")
    @player_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base0")
    @player_base.ox = @player_base.bitmap.width / 2
    @player_base.oy = @player_base.bitmap.height
    @foe_base.setBitmap("Graphics/Battlebacks/" + @bg_name + "_base1")
    @foe_base.ox = @foe_base.bitmap.width / 2
    @foe_base.oy = @foe_base.bitmap.height / 2
    @message_bar_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", @bg_name + "_message")
    @message_bar_sprite.y = Settings::SCREEN_HEIGHT - @message_bar_sprite.height
  end

  #-----------------------------------------------------------------------------

  def busy?
    return false
  end

  def changed?
    return false
  end

  #-----------------------------------------------------------------------------

  def repaint
  end

  def refresh
  end
end
