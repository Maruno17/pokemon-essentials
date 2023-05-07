#===============================================================================
#
#===============================================================================
class Battle::AI
  # Decide whether the opponent should Mega Evolve.
  def pbEnemyShouldMegaEvolve?
    if @battle.pbCanMegaEvolve?(@user.index)   # Simple "always should if possible"
      PBDebug.log_ai("#{@user.name} will Mega Evolve")
      return true
    end
    return false
  end
end
