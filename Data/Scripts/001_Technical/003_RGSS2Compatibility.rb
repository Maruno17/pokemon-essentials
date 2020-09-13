$TEST               = true if $DEBUG
$DEBUG              = true if $TEST
$scene              = nil
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40

#===============================================================================
#
#===============================================================================
=begin
class Win32API
  class << self
    unless defined?(debug_new)
      alias debug_new new
    end

    def new(*args)
      File.open("winapi.txt", "ab") { |f| f.write("new(#{args[0]},#{args[1]})\r\n") }
      b = debug_new(*args)
      b.setDllName(args[0], args[1])
      return b
    end
  end

  unless defined?(debug_call)
    alias debug_call call
  end

  def setDllName(a,b)
    @w32dll = a
    @w32name = b
  end

  def call(*args)
    if @w32name != "GetAsyncKeyState"
      File.open("winapi.txt", "ab") { |f|
        f.write("call(#{@w32dll},#{@w32name},#{args.inspect})\r\n")
      }
    end
    debug_call(*args)
  end
end

class Bitmap
  class << self
    unless defined?(debug_new)
      alias debug_new new
    end

    def new(*args)
      if args.length == 1
        File.open("winapib.txt", "ab") { |f| f.write("new(#{args[0]})\r\n") }
      end
      debug_new(*args)
    end
  end
end

alias debug_load_data load_data

def load_data(*args)
  File.open("winapif.txt", "ab") { |f| f.write("load(#{args[0]})\r\n") }
  debug_load_data(*args)
end
=end

class Hangup < Exception; end

if false
  p (Tilemap.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
  # no changes
  p (Plane.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
  # no changes
  p (Viewport.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
  p (Bitmap.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
  # openness(=)
  p (Window.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
  p (Sprite.instance_methods - Kernel.instance_methods - Object.instance_methods).sort
end

#===============================================================================
#
#===============================================================================
module RPG
  class Animation
    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation_name
    attr_accessor :animation_hue
    attr_accessor :position
    attr_accessor :frame_max
    attr_accessor :frames
    attr_accessor :timings

    def initialize
      @id = 0
      @name = ""
      @animation_name = ""
      @animation_hue = 0
      @position = 1
      @frame_max = 1
      @frames = [RPG::Animation::Frame.new]
      @timings = []
    end
  end
end

module RPG
  class Animation
    class Frame
      attr_accessor :cell_max
      attr_accessor :cell_data

      def initialize
        @cell_max = 0
        @cell_data = Table.new(0, 0)
      end
    end
  end
end

module RPG
  class Animation
    class Timing
      attr_accessor :frame
      attr_accessor :se
      attr_accessor :flash_scope
      attr_accessor :flash_color
      attr_accessor :flash_duration
      attr_accessor :condition

      def initialize
        @frame = 0
        @se = RPG::AudioFile.new("", 80)
        @flash_scope = 0
        @flash_color = Color.new(255, 255, 255, 255)
        @flash_duration = 5
        @condition = 0
      end
    end
  end
end

module RPG
  class System
    attr_accessor :magic_number
    attr_accessor :party_members
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :windowskin_name
    attr_accessor :title_name
    attr_accessor :gameover_name
    attr_accessor :battle_transition
    attr_accessor :title_bgm
    attr_accessor :battle_bgm
    attr_accessor :battle_end_me
    attr_accessor :gameover_me
    attr_accessor :cursor_se
    attr_accessor :decision_se
    attr_accessor :cancel_se
    attr_accessor :buzzer_se
    attr_accessor :equip_se
    attr_accessor :shop_se
    attr_accessor :save_se
    attr_accessor :load_se
    attr_accessor :battle_start_se
    attr_accessor :escape_se
    attr_accessor :actor_collapse_se
    attr_accessor :enemy_collapse_se
    attr_accessor :words
    attr_accessor :test_battlers
    attr_accessor :test_troop_id
    attr_accessor :start_map_id
    attr_accessor :start_x
    attr_accessor :start_y
    attr_accessor :battleback_name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id

    def initialize
      @magic_number = 0
      @party_members = [1]
      @elements = [nil, ""]
      @switches = [nil, ""]
      @variables = [nil, ""]
      @windowskin_name = ""
      @title_name = ""
      @gameover_name = ""
      @battle_transition = ""
      @title_bgm = RPG::AudioFile.new
      @battle_bgm = RPG::AudioFile.new
      @battle_end_me = RPG::AudioFile.new
      @gameover_me = RPG::AudioFile.new
      @cursor_se = RPG::AudioFile.new("", 80)
      @decision_se = RPG::AudioFile.new("", 80)
      @cancel_se = RPG::AudioFile.new("", 80)
      @buzzer_se = RPG::AudioFile.new("", 80)
      @equip_se = RPG::AudioFile.new("", 80)
      @shop_se = RPG::AudioFile.new("", 80)
      @save_se = RPG::AudioFile.new("", 80)
      @load_se = RPG::AudioFile.new("", 80)
      @battle_start_se = RPG::AudioFile.new("", 80)
      @escape_se = RPG::AudioFile.new("", 80)
      @actor_collapse_se = RPG::AudioFile.new("", 80)
      @enemy_collapse_se = RPG::AudioFile.new("", 80)
      @words = RPG::System::Words.new
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @battleback_name = ""
      @battler_name = ""
      @battler_hue = 0
      @edit_map_id = 1
    end
  end
end

module RPG
  class Tileset
    attr_accessor :id
    attr_accessor :name
    attr_accessor :tileset_name
    attr_accessor :autotile_names
    attr_accessor :panorama_name
    attr_accessor :panorama_hue
    attr_accessor :fog_name
    attr_accessor :fog_hue
    attr_accessor :fog_opacity
    attr_accessor :fog_blend_type
    attr_accessor :fog_zoom
    attr_accessor :fog_sx
    attr_accessor :fog_sy
    attr_accessor :battleback_name
    attr_accessor :passages
    attr_accessor :priorities
    attr_accessor :terrain_tags

    def initialize
      @id = 0
      @name = ""
      @tileset_name = ""
      @autotile_names = [""] * 7
      @panorama_name = ""
      @panorama_hue = 0
      @fog_name = ""
      @fog_hue = 0
      @fog_opacity = 64
      @fog_blend_type = 0
      @fog_zoom = 200
      @fog_sx = 0
      @fog_sy = 0
      @battleback_name = ""
      @passages = Table.new(384)
      @priorities = Table.new(384)
      @priorities[0] = 5
      @terrain_tags = Table.new(384)
    end
  end
end

module RPG
  class CommonEvent
    attr_accessor :id
    attr_accessor :name
    attr_accessor :trigger
    attr_accessor :switch_id
    attr_accessor :list

    def initialize
      @id = 0
      @name = ""
      @trigger = 0
      @switch_id = 1
      @list = [RPG::EventCommand.new]
    end
  end
end

module RPG
  class Map
    attr_accessor :tileset_id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :autoplay_bgm
    attr_accessor :bgm
    attr_accessor :autoplay_bgs
    attr_accessor :bgs
    attr_accessor :encounter_list
    attr_accessor :encounter_step
    attr_accessor :data
    attr_accessor :events

    def initialize(width, height)
      @tileset_id = 1
      @width = width
      @height = height
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @encounter_list = []
      @encounter_step = 30
      @data = Table.new(width, height, 3)
      @events = {}
    end
  end
end

module RPG
  class MapInfo
    attr_accessor :name
    attr_accessor :parent_id
    attr_accessor :order
    attr_accessor :expanded
    attr_accessor :scroll_x
    attr_accessor :scroll_y

    def initialize
      @name = ""
      @parent_id = 0
      @order = 0
      @expanded = false
      @scroll_x = 0
      @scroll_y = 0
    end
  end
end

module RPG
  class Event
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages

    def initialize(x, y)
      @id = 0
      @name = ""
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end
  end
end

module RPG
  class Event
    class Page
      attr_accessor :condition
      attr_accessor :graphic
      attr_accessor :move_type
      attr_accessor :move_speed
      attr_accessor :move_frequency
      attr_accessor :move_route
      attr_accessor :walk_anime
      attr_accessor :step_anime
      attr_accessor :direction_fix
      attr_accessor :through
      attr_accessor :always_on_top
      attr_accessor :trigger
      attr_accessor :list

      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @always_on_top = false
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end
    end
  end
end

module RPG
  class Event
    class Page
      class Condition
        attr_accessor :switch1_valid
        attr_accessor :switch2_valid
        attr_accessor :variable_valid
        attr_accessor :self_switch_valid
        attr_accessor :switch1_id
        attr_accessor :switch2_id
        attr_accessor :variable_id
        attr_accessor :variable_value
        attr_accessor :self_switch_ch

        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = "A"
        end
      end
    end
  end
end

module RPG
  class Event
    class Page
      class Graphic
        attr_accessor :tile_id
        attr_accessor :character_name
        attr_accessor :character_hue
        attr_accessor :direction
        attr_accessor :pattern
        attr_accessor :opacity
        attr_accessor :blend_type

        def initialize
          @tile_id = 0
          @character_name = ""
          @character_hue = 0
          @direction = 2
          @pattern = 0
          @opacity = 255
          @blend_type = 0
        end
      end
    end
  end
end

module RPG
  class EventCommand
    attr_accessor :code
    attr_accessor :indent
    attr_accessor :parameters

    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
  end
end

module RPG
  class MoveRoute
    attr_accessor :repeat
    attr_accessor :skippable
    attr_accessor :list

    def initialize
      @repeat = true
      @skippable = false
      @list = [RPG::MoveCommand.new]
    end
  end
end

module RPG
  class MoveCommand
    attr_accessor :code
    attr_accessor :parameters

    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
  end
end

module RPG
  class System
    class Words
      attr_accessor :gold
      attr_accessor :hp
      attr_accessor :sp
      attr_accessor :str
      attr_accessor :dex
      attr_accessor :agi
      attr_accessor :int
      attr_accessor :atk
      attr_accessor :pdef
      attr_accessor :mdef
      attr_accessor :weapon
      attr_accessor :armor1
      attr_accessor :armor2
      attr_accessor :armor3
      attr_accessor :armor4
      attr_accessor :attack
      attr_accessor :skill
      attr_accessor :guard
      attr_accessor :item
      attr_accessor :equip

      def initialize
        @gold = ""
        @hp = ""
        @sp = ""
        @str = ""
        @dex = ""
        @agi = ""
        @int = ""
        @atk = ""
        @pdef = ""
        @mdef = ""
        @weapon = ""
        @armor1 = ""
        @armor2 = ""
        @armor3 = ""
        @armor4 = ""
        @attack = ""
        @skill = ""
        @guard = ""
        @item = ""
        @equip = ""
      end
    end
  end
end

module RPG
  class System
    class TestBattler
      attr_accessor :actor_id
      attr_accessor :level
      attr_accessor :weapon_id
      attr_accessor :armor1_id
      attr_accessor :armor2_id
      attr_accessor :armor3_id
      attr_accessor :armor4_id

      def initialize
        @actor_id = 1
        @level = 1
        @weapon_id = 0
        @armor1_id = 0
        @armor2_id = 0
        @armor3_id = 0
        @armor4_id = 0
      end
    end
  end
end

module RPG
  class AudioFile
    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch

    def initialize(name = "", volume = 100, pitch = 100)
      @name   = name
      @volume = volume
      @pitch  = pitch
    end

#    def play
#    end
  end
end
