class Battle::AI
  #=============================================================================
  # Decide whether the opponent should Mega Evolve.
  #=============================================================================
  # TODO: Where relevant, pretend the user is Mega Evolved if it isn't but can
  #       be.
  def pbEnemyShouldMegaEvolve?
    if @battle.pbCanMegaEvolve?(@user.index)   # Simple "always should if possible"
      PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) will Mega Evolve")
      return true
    end
    return false
  end
end
