module GameData
  class Animation
    attr_reader :name
    attr_reader :move, :type   # Type is move's type; useful for filtering; move==nil means common animation
    attr_reader :version   # Hit number
    # TODO: Boolean for whether user is on player's side or foe's side.
    # TODO: Boolean for not played if target is on user's side.
    attr_reader :particles
    attr_reader :flags
    # TODO: PBS filename.
#    attr_reader :pbs_filename

    DATA = {}
    # TODO: Make sure the existence of animations.dat is optional. Currently
    #       it's required.
#    DATA_FILENAME = "animations.dat"
#    PBS_BASE_FILENAME = "animations"

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def register(hash)
      DATA[DATA.keys.length] = self.new(hash)
    end

    # TODO: Rewrite this to query animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate exists? methods for move and common animations?
#    def exists?(other)
#    end

    # TODO: Rewrite this to get animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate get methods for move and common animations?
#    def get(other)
#    end

    # TODO: Rewrite this to get animations from other criteria. Remember that
    #       multiple animations could have the same move/version. Odds are this
    #       method won't be used much at all.
    # TODO: Separate try_get methods for move and common animations?
#    def try_get(other)
#    end

    def initialize(hash)
      @name = hash[:name]
      @move = hash[:move]
      @type = hash[:type]
      @version = hash[:version] || 0
      @particles = []
      # TODO: Copy particles info from hash somehow.
      @flags = hash[:flags] || []
      # TODO: Come up with a decent default PBS filename; likely the move's name
      #       (for move anims) or @name (for common anims).
    end

    def move_animation?
      return !@move.nil?
    end
  end
end
