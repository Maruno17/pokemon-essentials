# TODO: Hardcoded animations have incorrect z values because of the change to
#       other sprites' z values.

#===============================================================================
#
#===============================================================================
class Battle::Scene
  alias __newanims__pbInitSprites pbInitSprites unless method_defined?(:__newanims__pbInitSprites)
  def pbInitSprites
    __newanims__pbInitSprites
    ["battle_bg", "battle_bg2"].each { |spr| @sprites[spr].z = -200 }
    2.times do |side|
      @sprites["base_#{side}"].z = -199
    end
    @sprites["cmdBar_bg"].z += 9999
    @sprites["messageBox"].z += 9999
    @sprites["messageWindow"].z += 9999
    @sprites["commandWindow"].z += 9999
    @sprites["fightWindow"].z += 9999
    @sprites["targetWindow"].z += 9999
    2.times do |side|
      @sprites["partyBar_#{side}"].z += 9999
      NUM_BALLS.times do |i|
        @sprites["partyBall_#{side}_#{i}"].z += 9999
      end
      # Ability splash bars
      @sprites["abilityBar_#{side}"].z += 9999 if USE_ABILITY_SPLASH
    end
    @battle.battlers.each_with_index do |b, i|
      @sprites["dataBox_#{i}"].z += 9999 if b
    end
  end
end

#===============================================================================
# Pokémon sprite (used in battle)
#===============================================================================
class Battle::Scene::BattlerSprite < RPG::Sprite
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    if @index.even?
      self.z = 1100 + (100 * @index / 2)
    else
      self.z = 1000 - (100 * (@index + 1) / 2)
    end
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index)
  end
end

#===============================================================================
# Shadow sprite for Pokémon (used in battle)
#===============================================================================
class Battle::Scene::BattlerShadowSprite < RPG::Sprite
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    self.z = -198
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    self.x = p[0]
    self.y = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, true)
  end
end
