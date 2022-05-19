#===============================================================================
# Represents a planted berry. Stored in $PokemonGlobal.eventvars.
#===============================================================================
class BerryPlantData
  attr_accessor :new_mechanics        # false for Gen 3, true for Gen 4
  attr_accessor :berry_id
  attr_accessor :mulch_id             # Gen 4 mechanics
  attr_accessor :time_alive
  attr_accessor :time_last_updated
  attr_accessor :growth_stage
  attr_accessor :replant_count
  attr_accessor :watered_this_stage   # Gen 3 mechanics
  attr_accessor :watering_count       # Gen 3 mechanics
  attr_accessor :moisture_level       # Gen 4 mechanics
  attr_accessor :yield_penalty        # Gen 4 mechanics

  def initialize
    reset
  end

  def reset(planting = false)
    @new_mechanics      = Settings::NEW_BERRY_PLANTS
    @berry_id           = nil
    @mulch_id           = nil if !planting
    @time_alive         = 0
    @time_last_updated  = 0
    @growth_stage       = 0
    @replant_count      = 0
    @watered_this_stage = false
    @watering_count     = 0
    @moisture_level     = 100
    @yield_penalty      = 0
  end

  def plant(berry_id)
    reset(true)
    @berry_id          = berry_id
    @growth_stage      = 1
    @time_last_updated = pbGetTimeNow.to_i
  end

  def replant
    @time_alive         = 0
    @growth_stage       = 2
    @replant_count      += 1
    @watered_this_stage = false
    @watering_count     = 0
    @moisture_level     = 100
    @yield_penalty      = 0
  end

  def planted?
    return @growth_stage > 0
  end

  def growing?
    return @growth_stage > 0 && @growth_stage < 5
  end

  def grown?
    return @growth_stage >= 5
  end

  def replanted?
    return @replant_count > 0
  end

  def moisture_stage
    return 0 if !@new_mechanics
    return 2 if @moisture_level > 50
    return 1 if @moisture_level > 0
    return 0
  end

  def water
    @moisture_level = 100
    if !@watered_this_stage
      @watered_this_stage = true
      @watering_count += 1
    end
  end

  def berry_yield
    data = GameData::BerryPlant.get(@berry_id)
    if @new_mechanics
      return [data.maximum_yield * (5 - @yield_penalty) / 5, data.minimum_yield].max
    elsif @watering_count > 0
      ret = (data.maximum_yield - data.minimum_yield) * (@watering_count - 1)
      ret += rand(1 + data.maximum_yield - data.minimum_yield)
      return (ret / 4) + data.minimum_yield
    end
    return data.minimum_yield
  end

  # Old mechanics only update a plant when its map is loaded. New mechanics
  # update it every frame while its map is loaded.
  def update
    return if !planted?
    time_now = pbGetTimeNow
    time_delta = time_now.to_i - @time_last_updated
    return if time_delta <= 0
    new_time_alive = @time_alive + time_delta
    # Get all growth data
    plant_data = GameData::BerryPlant.get(@berry_id)
    time_per_stage = plant_data.hours_per_stage * 3600   # In seconds
    drying_per_hour = plant_data.drying_per_hour
    max_replants = GameData::BerryPlant::NUMBER_OF_REPLANTS
    stages_growing = GameData::BerryPlant::NUMBER_OF_GROWTH_STAGES
    stages_fully_grown = GameData::BerryPlant::NUMBER_OF_FULLY_GROWN_STAGES
    case @mulch_id
    when :GROWTHMULCH
      time_per_stage = (time_per_stage * 0.75).to_i
      drying_per_hour = (drying_per_hour * 1.5).ceil
    when :DAMPMULCH
      time_per_stage = (time_per_stage * 1.25).to_i
      drying_per_hour /= 2
    when :GOOEYMULCH
      max_replants = (max_replants * 1.5).ceil
    when :STABLEMULCH
      stages_fully_grown = (stages_fully_grown * 1.5).ceil
    end
    # Do replants
    done_replant = false
    loop do
      stages_this_life = stages_growing + stages_fully_grown - (replanted? ? 1 : 0)
      break if new_time_alive < stages_this_life * time_per_stage
      if @replant_count >= max_replants
        reset
        return
      end
      replant
      done_replant = true
      new_time_alive -= stages_this_life * time_per_stage
    end
    # Update how long plant has been alive for
    old_growth_stage = @growth_stage
    @time_alive = new_time_alive
    @growth_stage = 1 + (@time_alive / time_per_stage)
    @growth_stage += 1 if replanted?   # Replants start at stage 2
    @time_last_updated = time_now.to_i
    # Record watering (old mechanics), and apply drying out per hour (new mechanics)
    if @new_mechanics
      old_growth_hour = (done_replant) ? 0 : (@time_alive - time_delta) / 3600
      new_growth_hour = @time_alive / 3600
      if new_growth_hour > old_growth_hour
        (new_growth_hour - old_growth_hour).times do
          if @moisture_level > 0
            @moisture_level -= drying_per_hour
          else
            @yield_penalty += 1
          end
        end
      end
    else
      old_growth_stage = 0 if done_replant
      new_growth_stage = [@growth_stage, stages_growing + 1].min
      @watered_this_stage = false if new_growth_stage > old_growth_stage
      water if $game_screen && GameData::Weather.get($game_screen.weather_type).category == :Rain
    end
  end
end

#===============================================================================
#
#===============================================================================
class BerryPlantMoistureSprite
  def initialize(event, map, viewport = nil)
    @event          = event
    @map            = map
    @sprite         = IconSprite.new(0, 0, viewport)
    @sprite.ox      = 16
    @sprite.oy      = 24
    @moisture_stage = -1   # -1 = none, 0 = dry, 1 = damp, 2 = wet
    @disposed       = false
    update_graphic
  end

  def dispose
    @sprite.dispose
    @map      = nil
    @event    = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def update_graphic
    case @moisture_stage
    when -1 then @sprite.setBitmap("")
    when 0  then @sprite.setBitmap("Graphics/Characters/berrytreedry")
    when 1  then @sprite.setBitmap("Graphics/Characters/berrytreedamp")
    when 2  then @sprite.setBitmap("Graphics/Characters/berrytreewet")
    end
  end

  def update
    return if !@sprite || !@event
    new_moisture = -1
    berry_plant = @event.variable
    if berry_plant.is_a?(BerryPlantData) && berry_plant.planted?
      new_moisture = berry_plant.moisture_stage
    end
    if new_moisture != @moisture_stage
      @moisture_stage = new_moisture
      update_graphic
    end
    @sprite.update
    @sprite.x      = ScreenPosHelper.pbScreenX(@event)
    @sprite.y      = ScreenPosHelper.pbScreenY(@event)
    @sprite.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    @sprite.zoom_y = @sprite.zoom_x
    pbDayNightTint(@sprite)
  end
end

#===============================================================================
#
#===============================================================================
class BerryPlantSprite
  def initialize(event, map, _viewport)
    @event     = event
    @map       = map
    @old_stage = 0
    @disposed  = false
    berry_plant = event.variable
    return if !berry_plant
    @old_stage = berry_plant.growth_stage
    @event.character_name = ""
    update_plant(berry_plant)
    set_event_graphic(berry_plant, true)   # Set the event's graphic
  end

  def dispose
    @event    = nil
    @map      = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def set_event_graphic(berry_plant, full_check = false)
    return if !berry_plant || (berry_plant.growth_stage == @old_stage && !full_check)
    case berry_plant.growth_stage
    when 0
      @event.character_name = ""
    else
      if berry_plant.growth_stage == 1
        @event.character_name = "berrytreeplanted"   # Common to all berries
        @event.turn_down
      else
        filename = sprintf("berrytree_%s", GameData::Item.get(berry_plant.berry_id).id.to_s)
        if pbResolveBitmap("Graphics/Characters/" + filename)
          @event.character_name = filename
          case berry_plant.growth_stage
          when 2 then @event.turn_down    # X sprouted
          when 3 then @event.turn_left    # X taller
          when 4 then @event.turn_right   # X flowering
          when 5 then @event.turn_up      # X berries
          end
        else
          @event.character_name = "Object ball"
        end
      end
      if berry_plant.new_mechanics && @old_stage != berry_plant.growth_stage &&
         @old_stage > 0 && berry_plant.growth_stage <= GameData::BerryPlant::NUMBER_OF_GROWTH_STAGES + 1
        spriteset = $scene.spriteset(@map.map_id)
        spriteset&.addUserAnimation(Settings::PLANT_SPARKLE_ANIMATION_ID,
                                    @event.x, @event.y, false, 1)
      end
    end
    @old_stage = berry_plant.growth_stage
  end

  def update_plant(berry_plant, initial = false)
    berry_plant.update if berry_plant.planted? && (initial || berry_plant.new_mechanics)
  end

  def update
    berry_plant = @event.variable
    return if !berry_plant
    update_plant(berry_plant)
    set_event_graphic(berry_plant)
  end
end

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_new_spriteset_map, :add_berry_plant_graphics,
  proc { |spriteset, viewport|
    map = spriteset.map
    map.events.each do |event|
      next if !event[1].name[/berryplant/i]
      spriteset.addUserSprite(BerryPlantMoistureSprite.new(event[1], map, viewport))
      spriteset.addUserSprite(BerryPlantSprite.new(event[1], map, viewport))
    end
  }
)

#===============================================================================
#
#===============================================================================
def pbBerryPlant
  interp = pbMapInterpreter
  this_event = interp.get_self
  berry_plant = interp.getVariable
  if !berry_plant
    berry_plant = BerryPlantData.new
    interp.setVariable(berry_plant)
  end
  berry = berry_plant.berry_id
  # Interact with the event based on its growth
  if berry_plant.grown?
    this_event.turn_up   # Stop the event turning towards the player
    berry_plant.reset if pbPickBerry(berry, berry_plant.berry_yield)
    return
  elsif berry_plant.growing?
    berry_name = GameData::Item.get(berry).name
    case berry_plant.growth_stage
    when 1   # X planted
      this_event.turn_down   # Stop the event turning towards the player
      pbMessage(_INTL("A {1} was planted here.", berry_name))
    when 2   # X sprouted
      this_event.turn_down   # Stop the event turning towards the player
      pbMessage(_INTL("The {1} has sprouted.", berry_name))
    when 3   # X taller
      this_event.turn_left   # Stop the event turning towards the player
      pbMessage(_INTL("The {1} plant is growing bigger.", berry_name))
    else     # X flowering
      this_event.turn_right   # Stop the event turning towards the player
      if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
      else
        case berry_plant.watering_count
        when 4
          pbMessage(_INTL("This {1} plant is in fabulous bloom!", berry_name))
        when 3
          pbMessage(_INTL("This {1} plant is blooming very beautifully!", berry_name))
        when 2
          pbMessage(_INTL("This {1} plant is blooming prettily!", berry_name))
        when 1
          pbMessage(_INTL("This {1} plant is blooming cutely!", berry_name))
        else
          pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
        end
      end
    end
    # Water the growing plant
    GameData::BerryPlant::WATERING_CANS.each do |item|
      next if !$bag.has?(item)
      break if !pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?",
                                       GameData::Item.get(item).name))
      berry_plant.water
      pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $player.name))
      if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("There! All happy!"))
      else
        pbMessage(_INTL("The plant seemed to be delighted."))
      end
      break
    end
    return
  end
  # Nothing planted yet
  ask_to_plant = true
  if Settings::NEW_BERRY_PLANTS
    # New mechanics
    if berry_plant.mulch_id
      pbMessage(_INTL("{1} has been laid down.\1", GameData::Item.get(berry_plant.mulch_id).name))
    else
      case pbMessage(_INTL("It's soft, earthy soil."),
                     [_INTL("Fertilize"), _INTL("Plant Berry"), _INTL("Exit")], -1)
      when 0   # Fertilize
        mulch = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $bag)
          mulch = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_mulch? })
        }
        return if !mulch
        mulch_data = GameData::Item.get(mulch)
        if mulch_data.is_mulch?
          berry_plant.mulch_id = mulch
          $bag.remove(mulch)
          pbMessage(_INTL("The {1} was scattered on the soil.\1", mulch_data.name))
        else
          pbMessage(_INTL("That won't fertilize the soil!"))
          return
        end
      when 1   # Plant Berry
        ask_to_plant = false
      else   # Exit/cancel
        return
      end
    end
  else
    # Old mechanics
    return if !pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
    ask_to_plant = false
  end
  if !ask_to_plant || pbConfirmMessage(_INTL("Want to plant a Berry?"))
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      berry = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_berry? })
    }
    if berry
      $stats.berries_planted += 1
      berry_plant.plant(berry)
      $bag.remove(berry)
      if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                        GameData::Item.get(berry).name))
      else
        pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.",
                        $player.name, GameData::Item.get(berry).name))
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPickBerry(berry, qty = 1)
  berry = GameData::Item.get(berry)
  berry_name = (qty > 1) ? berry.name_plural : berry.name
  if qty > 1
    message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", qty, berry_name)
  else
    message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", berry_name)
  end
  return false if !pbConfirmMessage(message)
  if !$bag.can_add?(berry, qty)
    pbMessage(_INTL("Too bad...\nThe Bag is full..."))
    return false
  end
  $stats.berry_plants_picked += 1
  if qty >= GameData::BerryPlant.get(berry.id).maximum_yield
    $stats.max_yield_berry_plants += 1
  end
  $bag.add(berry, qty)
  if qty > 1
    pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0].\\wtnp[30]", qty, berry_name))
  else
    pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0].\\wtnp[30]", berry_name))
  end
  pocket = berry.pocket
  pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
                  $player.name, berry_name, pocket, PokemonBag.pocket_names[pocket - 1]))
  if Settings::NEW_BERRY_PLANTS
    pbMessage(_INTL("The soil returned to its soft and earthy state."))
  else
    pbMessage(_INTL("The soil returned to its soft and loamy state."))
  end
  this_event = pbMapInterpreter.get_self
  pbSetSelfSwitch(this_event.id, "A", true)
  return true
end
