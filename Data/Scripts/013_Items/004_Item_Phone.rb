#===============================================================================
#
#===============================================================================
class Phone
  attr_accessor :contacts
  attr_accessor :rematch_variant, :rematches_enabled
  attr_accessor :time_to_next_call, :last_refresh_time

  def initialize
    @contacts = []
    @rematch_variant = 0   # Original battle is 0, first rematch is 1, etc.
    @rematches_enabled = Settings::PHONE_REMATCHES_POSSIBLE_FROM_BEGINNING
    @time_to_next_call = 0.0
    @last_refresh_time = 0
  end

  # Returns a visible contact only.
  def get(trainer, *args)
    @contacts.each do |contact|
      next if !contact.visible?
      next if contact.trainer? != trainer
      if trainer
        next if contact.trainer_type != args[0] ||
                contact.name != args[1] || contact.start_version != (args[2] || 0)
      else
        next if contact.name != args[0]
      end
      return contact
    end
    return nil
  end

  def get_version(trainer_type, name, start_version = 0)
    return 0 if !GameData::TrainerType.exists?(trainer_type)
    trainer_type = GameData::TrainerType.get(trainer_type).id
    contact = get(true, trainer_type, name, start_version)
    return (contact) ? contact.version : 0
  end

  # Trainer type, name[, start_version]
  # Name
  def can_add?(*args)
    return false if !$player.has_pokegear
    if args.length == 1
      # Non-trainer (name only)
      return false if get(false, args[0])
    else
      # Trainer (has at least trainer type and name)
      return false if !GameData::TrainerType.exists?(args[0])
      trainer_type = GameData::TrainerType.get(args[0]).id
      return false if get(true, trainer_type, args[1], args[2] || 0)
    end
    return true
  end

  # Event, trainer type, name, versions_count = 1, start_version = 0, common event ID = 0
  # Map ID, event ID, trainer type, name, versions_count = 1, start_version = 0, common event ID = 0
  # Map ID, name, common event ID
  def add(*args)
    if args[0].is_a?(Game_Event)
      # Trainer
      return false if !GameData::TrainerType.exists?(args[1])
      trainer_type = GameData::TrainerType.get(args[1]).id
      name = args[2]
      contact = get(true, trainer_type, name, args[3] || 0)
      if contact
        contact.visible = true
        @contacts.delete(contact)
      else
        contact = Contact.new(true, args[0].map_id, args[0].id,
                              trainer_type, name, args[3], args[4], args[5])
      end
    elsif args[1].is_a?(Numeric)
      # Trainer
      return false if !GameData::TrainerType.exists?(args[2])
      trainer_type = GameData::TrainerType.get(args[2]).id
      name = args[3]
      contact = get(true, trainer_type, name, args[4] || 0)
      if contact
        contact.visible = true
        @contacts.delete(contact)
      else
        contact = Contact.new(true, args[0], args[1],
                              trainer_type, name, args[4], args[5], args[6])
      end
    else
      # Non-trainer
      name = args[1]
      contact = get(false, name)
      if contact
        contact.visible = true
        @contacts.delete(contact)
      else
        contact = Contact.new(false, *args)
      end
    end
    @contacts.push(contact)
    sort_contacts
    return true
  end

  # Rearranges the list of phone contacts to put all visible contacts first,
  # followed by all invisible contacts.
  def sort_contacts
    new_contacts = []
    2.times do |i|
      @contacts.each do |con|
        next if (i == 0 && !con.visible?) || (i == 1 && con.visible?)
        new_contacts.push(con)
      end
    end
    @contacts = new_contacts
  end

  #=============================================================================

  # Checks once every second.
  def refresh_ready_trainers
    return if !@rematches_enabled
    time = pbGetTimeNow.to_i
    return if @last_refresh_time == time
    @last_refresh_time = time
    @contacts.each do |contact|
      next if !contact.trainer? || !contact.visible?
      next if contact.rematch_flag > 0   # Already ready for rematch
      if contact.time_to_ready <= 0
        contact.time_to_ready = rand(20...40) * 60   # 20-40 minutes
      end
      contact.time_to_ready -= 1
      next if contact.time_to_ready > 0
      contact.rematch_flag = 1   # Ready for rematch
      contact.set_trainer_event_ready_for_rematch
    end
  end

  def reset_after_win(trainer_type, name, start_version = 0)
    return if !GameData::TrainerType.exists?(trainer_type)
    trainer_type = GameData::TrainerType.get(trainer_type).id
    contact = get(true, trainer_type, name, start_version)
    return if !contact
    contact.increment_version
    contact.rematch_flag = 0
    contact.time_to_ready = 0
  end

  #=============================================================================

  def self.rematch_variant
    return $PokemonGlobal.phone.rematch_variant
  end

  def self.rematch_variant=(value)
    $PokemonGlobal.phone.rematch_variant = value
  end

  def self.rematches_enabled
    return $PokemonGlobal.phone.rematches_enabled
  end

  def self.rematches_enabled=(value)
    $PokemonGlobal.phone.rematches_enabled = value
  end

  def self.get_trainer(*args)
    return $PokemonGlobal.phone.get(true, *args)
  end

  def self.can_add?(*args)
    return $PokemonGlobal.phone.can_add?(*args)
  end

  def self.add(*args)
    ret = $PokemonGlobal.phone.add(*args)
    if ret
      if args[0].is_a?(Game_Event)
        contact = $PokemonGlobal.phone.get(true, args[1], args[2], (args[4] || 0))
      elsif args[1].is_a?(Numeric)
        contact = $PokemonGlobal.phone.get(true, args[2], args[3], (args[5] || 0))
      else
        contact = $PokemonGlobal.phone.get(false, args[1])
      end
      pbMessage(_INTL("\\me[Register phone]Registered {1} in the Pokégear!", contact.display_name) + "\\wtnp[60]")
    end
    return ret
  end

  def self.add_silent(*args)
    return $PokemonGlobal.phone.add(*args)
  end

  def self.variant(trainer_type, name, start_version = 0)
    contact = $PokemonGlobal.phone.get(trainer_type, name, start_version)
    return (contact) ? contact.variant : 0
  end

  def self.increment_version(trainer_type, name, start_version = 0)
    contact = $PokemonGlobal.phone.get(trainer_type, name, start_version)
    contact.increment_version if contact
  end

  def self.battle(trainer_type, name, start_version = 0)
    contact = $PokemonGlobal.phone.get(true, trainer_type, name, start_version)
    return false if !contact
    return TrainerBattle.start(trainer_type, name, contact.next_version)
  end

  def self.reset_after_win(trainer_type, name, start_version = 0)
    $PokemonGlobal.phone.reset_after_win(trainer_type, name, start_version)
  end
end

#===============================================================================
#
#===============================================================================
class Phone
  class Contact
    attr_accessor :map_id, :event_id
    attr_accessor :name
    attr_accessor :trainer_type
    attr_accessor :start_version, :versions_count, :version   # :version is the last trainer version that was beaten
    attr_accessor :time_to_ready, :rematch_flag
    attr_accessor :common_event_id
    attr_reader   :visible

    # Map ID, event ID, trainer type, name, versions count = 1, start version = 0
    # Map ID, name, common event ID
    def initialize(trainer, *args)
      @trainer = trainer
      @map_id = args[0]
      if @trainer
        # Trainer
        @event_id        = args[1]
        @trainer_type    = args[2]
        @name            = args[3]
        @versions_count  = [args[4] || 1, 1].max   # Includes the original version
        @start_version   = args[5] || 0
        @version         = @start_version
        @time_to_ready   = 0
        @rematch_flag    = 0   # 0=counting down, 1=ready for rematch, 2=ready and told player
        @common_event_id = args[6] || 0
      else
        # Non-trainer
        @name            = args[1]
        @common_event_id = args[2] || 0
      end
      @visible = true
    end

    def trainer?
      return @trainer
    end

    def visible?
      return @visible
    end

    def visible=(value)
      return if @visible == value
      @visible = value
      if !value && trainer?
        @time_to_ready = 0
        @rematch_flag = 0
        $game_self_switches[[@map_id, @event_id, "A"]] = true
        $game_map.need_refresh = true
      end
    end

    def can_hide?
      return trainer?
    end

    def common_event_call?
      return @common_event_id > 0
    end

    def can_rematch?
      return trainer? && @rematch_flag >= 1
    end

    def display_name
      if trainer?
        return sprintf("%s %s", GameData::TrainerType.get(@trainer_type).name,
                       pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, @name))
      end
      return _INTL(@name)
    end

    # Original battle is 0, first rematch is 1, etc.
    def variant
      return 0 if !trainer?
      return @version - @start_version
    end

    # Returns the version of this trainer to be battled next.
    def next_version
      var = variant + 1
      var = [var, $PokemonGlobal.phone.rematch_variant, @versions_count - 1].min
      return @start_version + var
    end

    def increment_version
      return if !trainer?
      @version = next_version
    end

    def set_trainer_event_ready_for_rematch
      return if !@trainer
      $game_self_switches[[@map_id, @event_id, "A"]] = false
      $game_self_switches[[@map_id, @event_id, "B"]] = true
      $game_map.need_refresh = true
    end
  end
end

#===============================================================================
#
#===============================================================================
class Phone
  module Call
    module_function

    def can_make?
      return false if $game_map.metadata.has_flag?("NoPhoneSignal")
      return true
    end

    # For the player initiating the call.
    def can_call_contact?(contact)
      return false if !contact
      if !can_make?
        pbMessage(_INTL("There is no phone signal here..."))
        return false
      end
      return true if !contact.trainer?
      if contact.map_id == $game_map.map_id
        pbMessage(_INTL("The Trainer is close by.\nTalk to the Trainer in person!"))
        return false
      end
      caller_map_metadata = GameData::MapMetadata.try_get(contact.map_id)
      this_map_metadata = $game_map.metadata
      if !caller_map_metadata || !caller_map_metadata.town_map_position ||
         !this_map_metadata || !this_map_metadata.town_map_position ||
         caller_map_metadata.town_map_position[0] != this_map_metadata.town_map_position[0]
        pbMessage(_INTL("The Trainer is out of range."))
        return false
      end
      return true
    end

    # Get a random trainer contact from the region the player is currently in,
    # but is not in the same map as the player.
    def get_random_trainer_for_incoming_call
      player_location = $game_map.metadata&.town_map_position
      return nil if !player_location
      player_region = player_location[0]
      valid_contacts = []
      $PokemonGlobal.phone.contacts.each do |contact|
        next if !contact.trainer? || !contact.visible?
        next if contact.map_id == $game_map.map_id ||
                pbGetMapNameFromId(contact.map_id) == $game_map.name
        caller_map_metadata = GameData::MapMetadata.try_get(contact.map_id)
        next if !caller_map_metadata || !caller_map_metadata.town_map_position
        next if caller_map_metadata.town_map_position[0] != player_region
        valid_contacts.push(contact)
      end
      return valid_contacts.sample
    end

    #===========================================================================

    def make_incoming
      return if !can_make?
      contact = get_random_trainer_for_incoming_call
      return if !contact
      if contact.common_event_call?
        if !pbCommonEvent(contact.common_event_id)
          pbMessage(_INTL("{1}'s messages not defined.\nCouldn't call common event {2}.",
                          contact.display_name, contact.common_event_id))
        end
      else
        call = generate_trainer_dialogue(contact)
        play(call, contact)
      end
    end

    # Phone::Contact
    # Trainer type, name[, start_version]
    # Name (for non-trainers)
    def make_outgoing(*args)
      if args[0].is_a?(Phone::Contact)
        contact = args[0]
      elsif args.length > 1
        contact = Phone.get(true, args[0], args[1], args[2] || 0)   # Trainer
      else
        contact = Phone.get(false, args[0])   # Non-trainer
      end
      raise _INTL("Couldn't find phone contact given: {1}.", args.inspect) if !contact
      return if !can_call_contact?(contact)
      if contact.common_event_call?
        if !pbCommonEvent(contact.common_event_id)
          pbMessage(_INTL("{1}'s messages not defined.\nCouldn't call common event {2}.",
                          contact.display_name, contact.common_event_id))
        end
      else
        call = generate_trainer_dialogue(contact)
        play(call, contact)
      end
    end

    def start_message(contact = nil)
      pbMessage(_INTL("......\\wt[5] ......") + "\1")
    end

    def play(dialogue, contact)
      start_message(contact)
      contact_pokemon_species  = get_random_contact_pokemon_species(contact)
      random_encounter_species = get_random_encounter_species(contact)
      contact_map_name         = get_map_name(contact)
      gender_colour_text       = ""
      if Settings::COLOR_PHONE_CALL_MESSAGES_BY_CONTACT_GENDER && contact.trainer?
        data = GameData::TrainerType.try_get(contact.trainer_type)
        if data
          case data.gender
          when 0 then gender_colour_text = "\\b"
          when 1 then gender_colour_text = "\\r"
          end
        end
      end
      messages = dialogue.split("\\m")
      messages.each_with_index do |message, i|
        message.gsub!(/\\TN/, _INTL(contact.name))
        message.gsub!(/\\TP/, contact_pokemon_species)
        message.gsub!(/\\TE/, random_encounter_species)
        message.gsub!(/\\TM/, contact_map_name)
        message += "\1" if i < messages.length - 1
        pbMessage(gender_colour_text + message)
      end
      end_message(contact)
    end

    def end_message(contact = nil)
      pbMessage(_INTL("Click!\\wt[10]\n......\\wt[5] ......") + "\1")
    end

    #===========================================================================

    def generate_trainer_dialogue(contact)
      validate contact => Phone::Contact
      # Get the set of messages to be used by the contact
      messages = GameData::PhoneMessage.try_get(contact.trainer_type, contact.name, contact.version)
      messages = GameData::PhoneMessage.try_get(contact.trainer_type, contact.name, contact.start_version) if !messages
      messages = GameData::PhoneMessage::DATA["default"] if !messages
      # Create lambda for choosing a random message and translating it
      get_random_message = lambda do |msgs|
        return "" if !msgs
        msg = msgs.sample
        return "" if !msg
        return pbGetMessageFromHash(MessageTypes::PHONE_MESSAGES, msg)
      end
      # Choose random greeting depending on time of day
      ret = get_random_message.call(messages.intro)
      time = pbGetTimeNow
      if PBDayNight.isMorning?(time)
        mod_call = get_random_message.call(messages.intro_morning)
        ret = mod_call if !nil_or_empty?(mod_call)
      elsif PBDayNight.isAfternoon?(time)
        mod_call = get_random_message.call(messages.intro_afternoon)
        ret = mod_call if !nil_or_empty?(mod_call)
      elsif PBDayNight.isEvening?(time)
        mod_call = get_random_message.call(messages.intro_evening)
        ret = mod_call if !nil_or_empty?(mod_call)
      end
      ret += "\\m"
      # Choose main message set
      if Phone.rematches_enabled && contact.rematch_flag > 0
        # Trainer is ready for a rematch, so tell/remind the player
        case contact.rematch_flag
        when 1   # Tell the player
          ret += get_random_message.call(messages.battle_request)
          contact.rematch_flag = 2   # Ready for rematch and told player
        when 2   # Remind the player
          if messages.battle_remind
            ret += get_random_message.call(messages.battle_remind)
          else
            ret += get_random_message.call(messages.battle_request)
          end
        end
      else
        # Standard messages
        if messages.body1 && messages.body2 && (!messages.body || rand(100) < 75)
          # Choose random pair of body messages
          ret += get_random_message.call(messages.body1)
          ret += "\\m"
          ret += get_random_message.call(messages.body2)
        else
          # Choose random full body message
          ret += get_random_message.call(messages.body)
        end
        # Choose end message
        mod_call = get_random_message.call(messages.end)
        ret += "\\m" + mod_call if !nil_or_empty?(mod_call)
      end
      return ret
    end

    def get_random_contact_pokemon_species(contact)
      return "" if !contact.trainer?
      version = [contact.version, contact.start_version].max
      trainer_data = GameData::Trainer.try_get(contact.trainer_type, contact.name, version)
      return "" if !trainer_data
      pkmn = trainer_data.pokemon.sample[:species]
      return GameData::Species.get(pkmn).name
    end

    def get_random_encounter_species(contact)
      return "" if !contact.trainer?
      encounter_data = GameData::Encounter.get(contact.map_id, $PokemonGlobal.encounter_version)
      return "" if !encounter_data
      get_species_from_table = lambda do |encounter_table|
        return nil if !encounter_table || encounter_table.length == 0
        len = [encounter_table.length, 4].min   # From first 4 slots only
        return encounter_table[rand(len)][1]
      end
      enc_tables = encounter_data.types
      species = get_species_from_table.call(enc_tables[:Land])
      if !species
        species = get_species_from_table.call(enc_tables[:Cave])
        species = get_species_from_table.call(enc_tables[:Water]) if !species
      end
      return "" if !species
      return GameData::Species.get(species).name
    end

    def get_map_name(contact)
      return pbGetMapNameFromId(contact.map_id)
    end
  end
end

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_frame_update, :phone_call_counter,
  proc {
    next if !$player&.has_pokegear
    # Don't count down various phone times if other things are happening
    next if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
    next if $game_player.move_route_forcing || pbMapInterpreterRunning?
    # Count down time to next can-battle for each trainer contact
    $PokemonGlobal.phone.refresh_ready_trainers
    # Count down time to next phone call
    if $PokemonGlobal.phone.time_to_next_call <= 0
      $PokemonGlobal.phone.time_to_next_call = rand(20...40) * 60.0   # 20-40 minutes
    end
    $PokemonGlobal.phone.time_to_next_call -= Graphics.delta
    next if $PokemonGlobal.phone.time_to_next_call > 0
    # Time for a random phone call; generate one
    Phone::Call.make_incoming
  }
)

#===============================================================================
# Deprecated.
#===============================================================================
# Called by events. Make your event look like this instead:
#
# @>Conditional Branch: Phone.can_add?(trainer_type, name, start_version)
#   @>Text: Let me register you.
#   @>Show Choices: Yes, No
#    : When [Yes]
#     @>Conditional Branch: Phone.add(get_self, trainer_type, name, start_version, versions_count)
#       @>Text: Thanks! (optional)
#       @>
#     : Branch End
#    : When [No]
#       @>Text: Oh, okay then. (optional)
#       @>
#    : Branch End
#  : Branch End
# @>
#
# @deprecated This method is slated to be removed in v22.
def pbPhoneRegisterBattle(message, event, trainer_type, name, versions_count)
  Deprecation.warn_method("pbPhoneRegisterBattle", "v22", "several scripts and event commands; see def pbPhoneRegisterBattle")
  return false if !Phone.can_add?(trainer_type, name, 0)
  message = _INTL("Let me register you.") if !message
  return false if !pbConfirmMessage(message)
  return Phone.add(event, trainer_type, name, 0, versions_count)
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneRegister(event, trainer_type, name)
  Deprecation.warn_method("pbPhoneRegister", "v22", "Phone.add_silent(event, trainer_type, name)")
  Phone.add_silent(event, trainer_type, name)
end

# Called by events.
# @deprecated This method is slated to be removed in v22.
def pbPhoneRegisterNPC(common_event_id, name, map_id, show_message = true)
  Deprecation.warn_method("pbPhoneRegisterNPC", "v22", "Phone.add(map_id, name, common_event_id) or Phone.add_silent(map_id, name, common_event_id)")
  if show_message
    Phone.add(map_id, name, common_event_id)
  else
    Phone.add_silent(map_id, name, common_event_id)
  end
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneDeleteContact(index)
  Deprecation.warn_method("pbPhoneDeleteContact", "v22", "$PokemonGlobal.phone.contacts[index].visible = false")
  $PokemonGlobal.phone.contacts[index].visible = false
end

# @deprecated This method is slated to be removed in v22.
def pbFindPhoneTrainer(trainer_type, name)
  Deprecation.warn_method("pbFindPhoneTrainer", "v22", "Phone.get(trainer_type, name)")
  return Phone.get(trainer_type, name)
end

# @deprecated This method is slated to be removed in v22.
def pbHasPhoneTrainer?(trainer_type, name)
  Deprecation.warn_method("pbHasPhoneTrainer", "v22", "Phone.get(trainer_type, name) != nil")
  return Phone.get(trainer_type, name) != nil
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneReadyToBattle?(trainer_type, name)
  Deprecation.warn_method("pbPhoneReadyToBattle", "v22", "Phone.get(trainer_type, name).can_rematch?")
  contact = Phone.get(trainer_type, name)
  return contact && contact.can_rematch?
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneReset(tr_type, tr_name)
  Deprecation.warn_method("pbPhoneReadyToBattle", "v22", "Phone.get(trainer_type, name) and other things")
  contact = Phone.get(trainer_type, name)
  return false if !contact
  contact.time_to_ready = 0
  contact.rematch_flag = 0
  $game_self_switches[[contact.map_id, contact.event_id, "A"]] = true
  $game_map.need_refresh = true
  return true
end

# Called by events.
# @deprecated This method is slated to be removed in v22.
def pbPhoneBattleCount(trainer_type, name)
  Deprecation.warn_method("pbPhoneBattleCount", "v22", "Phone.variant(trainer_type, name)")
  return Phone.variant(trainer_type, name)
end

# Called by events.
# @deprecated This method is slated to be removed in v22.
def pbPhoneIncrement(trainer_type, name, versions_count)
  Deprecation.warn_method("pbPhoneIncrement", "v22", "Phone.increment_version(trainer_type, name, start_version)")
  Phone.increment_version(trainer_type, name, 0)
end

# Used in phone calls that say they're ready for a rematch, used in Debug function.
# @deprecated This method is slated to be removed in v22.
def pbSetReadyToBattle(contact)
  Deprecation.warn_method("pbSetReadyToBattle", "v22", "contact.set_trainer_event_ready_for_rematch")
  contact.set_trainer_event_ready_for_rematch
end

# @deprecated This method is slated to be removed in v22.
def pbRandomPhoneTrainer
  Deprecation.warn_method("pbRandomPhoneTrainer", "v22", "Phone::Call.get_random_trainer_for_incoming_call")
  return Phone::Call.get_random_trainer_for_incoming_call
end

# @deprecated This method is slated to be removed in v22.
def pbCallTrainer(trainer_type, name)
  Deprecation.warn_method("pbCallTrainer", "v22", "Phone::Call.make_outgoing(trainer_type, name)")
  Phone::Call.make_outgoing(trainer_type, name)
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneGenerateCall(contact)
  Deprecation.warn_method("pbPhoneGenerateCall", "v22", "Phone::Call.generate_trainer_dialogue(contact)")
  return Phone::Call.generate_trainer_dialogue(contact)
end

# @deprecated This method is slated to be removed in v22.
def pbPhoneCall(dialogue, contact)
  Deprecation.warn_method("pbPhoneCall", "v22", "Phone::Call.play(dialogue, contact)")
  Phone::Call.play(dialogue, contact)
end

# @deprecated This method is slated to be removed in v22.
def pbEncounterSpecies(contact)
  Deprecation.warn_method("pbEncounterSpecies", "v22", "Phone::Call.get_random_encounter_species(contact)")
  return Phone::Call.get_random_encounter_species(contact)
end

# @deprecated This method is slated to be removed in v22.
def pbTrainerSpecies(contact)
  Deprecation.warn_method("pbTrainerSpecies", "v22", "Phone::Call.get_random_contact_pokemon_species(contact)")
  return Phone::Call.get_random_contact_pokemon_species(contact)
end

# @deprecated This method is slated to be removed in v22.
def pbTrainerMapName(contact)
  Deprecation.warn_method("pbTrainerMapName", "v22", "Phone::Call.get_map_name(contact)")
  return Phone::Call.get_map_name(contact)
end
