#===============================================================================
#
#===============================================================================
class Battle::DamageState
  attr_accessor :typeMod         # Type effectiveness
  attr_accessor :unaffected
  attr_accessor :protected
  attr_accessor :magicCoat
  attr_accessor :magicBounce
  attr_accessor :totalHPLost     # Like hpLost, but cumulative over all hits
  attr_accessor :fainted         # Whether battler was knocked out by the move

  attr_accessor :missed          # Whether the move failed the accuracy check
  attr_accessor :affection_missed
  attr_accessor :invulnerable    # If the move missed due to two turn move invulnerability
  attr_accessor :calcDamage      # Calculated damage
  attr_accessor :hpLost          # HP lost by opponent, inc. HP lost by a substitute
  attr_accessor :critical        # Critical hit flag
  attr_accessor :affection_critical
  attr_accessor :substitute      # Whether a substitute took the damage
  attr_accessor :focusBand       # Focus Band used
  attr_accessor :focusSash       # Focus Sash used
  attr_accessor :sturdy          # Sturdy ability used
  attr_accessor :disguise        # Disguise ability used
  attr_accessor :iceFace         # Ice Face ability used
  attr_accessor :endured         # Damage was endured
  attr_accessor :affection_endured
  attr_accessor :berryWeakened   # Whether a type-resisting berry was used

  def initialize; reset; end

  def reset
    @typeMod          = Effectiveness::INEFFECTIVE
    @unaffected       = false
    @protected        = false
    @missed           = false
    @affection_missed = false
    @invulnerable     = false
    @magicCoat        = false
    @magicBounce      = false
    @totalHPLost      = 0
    @fainted          = false
    resetPerHit
  end

  def resetPerHit
    @calcDamage         = 0
    @hpLost             = 0
    @critical           = false
    @affection_critical = false
    @substitute         = false
    @focusBand          = false
    @focusSash          = false
    @sturdy             = false
    @disguise           = false
    @iceFace            = false
    @endured            = false
    @affection_endured  = false
    @berryWeakened      = false
  end
end
