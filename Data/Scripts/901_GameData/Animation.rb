module GameData
  class Animation
    attr_reader :type       # :move, :opp_move, :common, :opp_common
    attr_reader :move       # Either the move's ID or the common animation's name
    attr_reader :version    # Hit number
    attr_reader :name       # Shown in the sublist; cosmetic only
    # TODO: Boolean for not played if target is on user's side.
    attr_reader :particles
    attr_reader :flags
    attr_reader :pbs_path   # Whole path minus "PBS/Animations/" at start and ".txt" at end

    DATA = {}
    DATA_FILENAME = "animations.dat"
    OPTIONAL = true

    SCHEMA = {
      # TODO: Add support for overworld animations.
      "SectionName" => [:id,        "esU", {"Move" => :move, "OppMove" => :opp_move,
                                            "Common" => :common, "OppCommon" => :opp_common}],
      "Name"        => [:name,      "s"],
      # TODO: Target (Screen, User, UserAndTarget, etc. Determines which focuses
      #       a particle can be given and whether "Target" particle exists). Or
      #       InvolvesTarget boolean (user and screen will always exist).
      # TODO: DamageFrame (keyframe at which the battle continues, i.e. damage
      #       animations start playing).
      "Flags"       => [:flags,     "*s"],
      "Particle"    => [:particles, "s"]
    }
    # For individual particles. All actions should have "^" in them.
    # TODO: If more "SetXYZ"/"MoveXYZ" properties are added, ensure the "SetXYZ"
    #       ones are given a duration of 0 in def validate_compiled_animation.
    #       Also add display names to def property_display_name.
    SUB_SCHEMA = {
      # These properties cannot be changed partway through the animation.
      # TODO: "Name" isn't actually used; the name comes from the subsection
      #       written between <these> and uses "Particle" above.
#      "Name"        => [:name,     "s"],
      "Focus"       => [:focus,    "e", {"User" => :user, "Target" => :target,
                                         "UserAndTarget" => :user_and_target, "Screen" => :screen}],
      # TODO FlipIfFoe, RotateIfFoe kinds of thing.

      # All properties below are "Set" or "Move". "Set" has the keyframe and the
      # value, and "Move" has the keyframe, duration and the value. All are "^".
      # "Set" is turned into "Move" with a duration (second value) of 0.
      # TODO: The "MoveXYZ" commands will have optional easing (an enum).
      "SetGraphic"  => [:graphic,  "^us"],
      "SetFrame"    => [:frame,    "^uu"],   # Frame within the graphic if it's a spritesheet
      "MoveFrame"   => [:frame,    "^uuu"],
      "SetBlending" => [:blending, "^uu"],   # 0, 1 or 2
      "SetFlip"     => [:flip,     "^ub"],
      "SetX"        => [:x,        "^ui"],
      "MoveX"       => [:x,        "^uui"],
      "SetY"        => [:y,        "^ui"],
      "MoveY"       => [:y,        "^uui"],
      "SetZoomX"    => [:zoom_x,   "^uu"],
      "MoveZoomX"   => [:zoom_x,   "^uuu"],
      "SetZoomY"    => [:zoom_y,   "^uu"],
      "MoveZoomY"   => [:zoom_y,   "^uuu"],
      "SetAngle"    => [:angle,    "^ui"],
      "MoveAngle"   => [:angle,    "^uui"],
      # TODO: Remember that :visible defaults to false at the beginning for a
      #       particle, and becomes true automatically when the first command
      #       happens for that particle. For "User" and "Target", it defaults to
      #       true at the beginning instead.
      "SetVisible"  => [:visible,  "^ub"],
      "SetOpacity"  => [:opacity,  "^uu"],
      "MoveOpacity" => [:opacity,  "^uuu"]
      # TODO: SetPriority should be an enum. There should also be a property
      #       (set and move) for the sub-priority within that priority bracket.
#      "SetPriority"
      # TODO: Color.
      # TODO: Tone.

      # TODO: Play, PlayUserCry, PlayTargetCry.
      # TODO: ScreenShake? Not sure how to work this yet. Edit def
      #       validate_compiled_animation like the "SE" particle does with the
      #       "Play"-type commands.
    }
    PARTICLE_DEFAULT_VALUES = {
#      :name  => "",
      :focus => :screen
    }
    PARTICLE_KEYFRAME_DEFAULT_VALUES = {
      :graphic  => nil,
      :frame    => 0,
      :blending => 0,
      :flip     => false,
      :x        => 0,
      :y        => 0,
      :zoom_x   => 100,
      :zoom_y   => 100,
      :angle    => 0,
      :visible  => false,
      :opacity  => 255
    }

    @@cmd_to_pbs_name = nil   # USed for writing animation PBS files

    extend ClassMethodsIDNumbers
    include InstanceMethods

    singleton_class.alias_method(:__new_anim__load, :load) unless singleton_class.method_defined?(:__new_anim__load)
    def self.load
      __new_anim__load if FileTest.exist?("Data/#{self::DATA_FILENAME}")
    end

    def self.sub_schema
      return SUB_SCHEMA
    end

    def self.register(hash, id_num = -1)
      DATA[(id_num >= 0) ? id_num : DATA.keys.length] = self.new(hash)
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
      # NOTE: hash has an :id entry, but it's unused here.
      @type      = hash[:type]
      @move      = hash[:move]
      @version   = hash[:version]   || 0
      @name      = hash[:name]
      @particles = hash[:particles] || []
      @flags     = hash[:flags]     || []
      @pbs_path  = hash[:pbs_path]  || "#{@type} - #{@move}"
    end

    # Returns a clone of the animation in a hash format, the same as created by
    # the Compiler. This hash can be passed into self.register.
    def clone_as_hash
      ret = {}
      ret[:type] = @type
      ret[:move] = @move
      ret[:version] = @version
      ret[:name] = @name
      ret[:particles] = []   # Clone the @particles array, which is nested hashes and arrays
      @particles.each do |particle|
        new_p = {}
        particle.each_pair do |key, val|
          if val.is_a?(Array)
            new_p[key] = []
            val.each { |cmd| new_p[key].push(cmd.clone) }
          else
            new_p[key] = val
          end
        end
        ret[:particles].push(new_p)
      end
      ret[:flags] = @flags.clone
      ret[:pbs_path] = @pbs_path
      return ret
    end

    def move_animation?
      return [:move, :opp_move].include?(@type)
    end

    def common_animation?
      return [:common, :opp_common].include?(@type)
    end

    alias __new_anim__get_property_for_PBS get_property_for_PBS unless method_defined?(:__new_anim__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __new_anim__get_property_for_PBS(key)
      case key
      when "SectionName"
        ret = [@type, @move]
        ret.push(@version) if @version > 0
      end
      return ret
    end

    def get_particle_property_for_PBS(key, index = 0)
      ret = nil
      ret = @particles[index][SUB_SCHEMA[key][0]] if SUB_SCHEMA[key]
      ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0) || ret == ""
      case key
      when "Focus"
        # The User and Target particles are hardcoded to only have their
        # corresponding foci, so they don't need writing to PBS
        if ["User", "Target"].include?(@particles[index][:name])
          ret = nil
        elsif ret
          ret = SUB_SCHEMA[key][2].key(ret)
        end
      when "AllCommands"
        # Get translations of all properties to their names as seen in PBS
        # animation files
        if !@@cmd_to_pbs_name
          @@cmd_to_pbs_name = {}
          SUB_SCHEMA.each_pair do |key, val|
            @@cmd_to_pbs_name[val[0]] ||= []
            @@cmd_to_pbs_name[val[0]].push([key, val[1].length])
          end
          # For each property translation, put "SetXYZ" before "MoveXYZ"
          @@cmd_to_pbs_name.each_value do |val|
            val.sort! { |a, b| a[1] <=> b[1] }
            val.map! { |a| a[0] }
          end
        end
        # Gather all commands into a single array
        ret = []
        @particles[index].each_pair do |key, val|
          next if !val.is_a?(Array)
          val.each do |cmd|
            new_cmd = cmd.clone
            if new_cmd[1] > 0
              ret.push([@@cmd_to_pbs_name[key][1]] + new_cmd)   # ["MoveXYZ", keyframe, duration, value]
            else
              ret.push([@@cmd_to_pbs_name[key][0]] + new_cmd)   # ["SetXYZ", keyframe, duration, value]
            end
          end
        end
        # Sort the array of commands by keyframe order, then by duration, then
        # by the order they're defined in SUB_SCHEMA
        ret.sort! do |a, b|
          if a[1] == b[1]
            if a[2] == b[2]
              next SUB_SCHEMA.keys.index(a[0]) <=> SUB_SCHEMA.keys.index(b[0])
            else
              next a[2] <=> b[2]   # Sort by duration
            end
          else
            next a[1] <=> b[1]   # Sort by keyframe
          end
        end
      end
      return ret
    end
  end
end
