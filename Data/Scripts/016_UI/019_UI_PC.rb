#===============================================================================
#
#===============================================================================
module UI::PC
  module_function

  #-----------------------------------------------------------------------------

  def menu(menu_type, message)
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(menu_type) do |option, hash, name|
      command_list.push(name)
      commands.push(hash)
    end
    # Main loop
    command = 0
    loop do
      choice = pbMessage(message, command_list, -1, nil, command)
      break if choice < 0
      break if commands[choice]["effect"].call
    end
  end

  def trainer_pc_menu
    menu(:player_pc_menu, _INTL("What do you want to do?"))
  end

  def poke_center_pc_menu
    menu(:pc_menu, _INTL("Which PC should be accessed?"))
  end

  #-----------------------------------------------------------------------------

  def item_storage
    $PokemonGlobal.pcItemStorage ||= PCItemStorage.new
    commands = {
      :withdraw => [_INTL("Withdraw Item"), _INTL("Take out items from the PC.")],
      :deposit  => [_INTL("Deposit Item"),  _INTL("Store items in the PC.")],
      :toss     => [_INTL("Toss Item"),     _INTL("Throw away items stored in the PC.")],
      :exit     => [_INTL("Exit"),          _INTL("Go back to the previous menu.")]
    }
    command = 0
    loop do
      commands.values.map { |val| val[0] }
      command = pbShowCommandsWithHelp(nil, commands.values.map { |val| val[0] },
                                       commands.values.map { |val| val[1] }, -1, command)
      break if command < 0
      case commands.keys[command]
      when :withdraw
        if $PokemonGlobal.pcItemStorage.empty?
          pbMessage(_INTL("There are no items."))
          next
        end
        pbPlayDecisionSE
        pbFadeOutIn do
          scene = WithdrawItemScene.new
          screen = ItemStorageScreen.new(scene, $bag)
          screen.pbWithdrawItemScreen
        end
      when :deposit
        pbPlayDecisionSE
        item_storage = $PokemonGlobal.pcItemStorage
        pbFadeOutIn do
          bag_screen = UI::Bag.new($bag, mode: :choose_item)
          bag_screen.choose_item do |item|
            item_data = GameData::Item.get(item)
            if (Settings::DISABLE_STORING_IMPORTANT_ITEMS && item_data.is_important?) ||
               item_data.has_flag?("CannotDeposit")
              bag_screen.show_message(_INTL("You couldn't deposit such an important item!"))
              next false
            end
            qty = $bag.quantity(item)
            if qty > 1 && !item_data.is_important?
              qty = bag_screen.choose_number(_INTL("How many do you want to deposit?"), qty)
            end
            next false if qty == 0
            if !item_storage.can_add?(item, qty)
              bag_screen.show_message(_INTL("There's no room to store items."))
              next false
            end
            raise "Can't delete items from Bag" if !$bag.remove(item, qty)
            raise "Can't deposit items to storage" if !item_storage.add(item, qty)
            bag_screen.refresh
            disp_qty  = (item_data.is_important?) ? 1 : qty
            item_name = (disp_qty > 1) ? item_data.portion_name_plural : item_data.portion_name
            bag_screen.show_message(_INTL("Deposited {1} {2}.", disp_qty, item_name))
            next false
          end
        end
      when :toss
        if $PokemonGlobal.pcItemStorage.empty?
          pbMessage(_INTL("There are no items."))
          next
        end
        pbPlayDecisionSE
        pbFadeOutIn do
          scene = TossItemScene.new
          screen = ItemStorageScreen.new(scene, $bag)
          screen.pbTossItemScreen
        end
      else
        break
      end
    end
  end

  #-----------------------------------------------------------------------------

  def mailbox
    command = 0
    loop do
      # Choose a mail or cancel
      commands = []
      $PokemonGlobal.mailbox.each { |mail| commands.push(mail.sender) }
      commands.push(_INTL("Cancel"))
      mail_index = pbShowCommands(nil, commands, -1, command)
      break if mail_index < 0 || mail_index >= $PokemonGlobal.mailbox.length
      # Interact with mail
      interact_commands = {
        :read        => _INTL("Read"),
        :move_to_bag => _INTL("Move to Bag"),
        :give        => _INTL("Give"),
        :cancel      => _INTL("Cancel")
      }
      command_mail = pbMessage(
        _INTL("What do you want to do with {1}'s Mail?", $PokemonGlobal.mailbox[mail_index].sender),
        interact_commands.values, -1
      )
      case interact_commands.keys[command_mail]
      when :read
        pbPlayDecisionSE
        pbFadeOutIn { pbDisplayMail($PokemonGlobal.mailbox[mail_index]) }
      when :move_to_bag
        if pbConfirmMessage(_INTL("The message will be lost. Is that OK?"))
          if $bag.add($PokemonGlobal.mailbox[mail_index].item)
            pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
            $PokemonGlobal.mailbox.delete_at(mail_index)
          else
            pbMessage(_INTL("The Bag is full."))
          end
        end
      when :give
        pbPlayDecisionSE
        pbFadeOutIn do
          screen = UI::Party.new($player.party, mode: :choose_pokemon)
          screen.choose_pokemon do |pkmn, party_index|
            next true if party_index < 0
            if pkmn.egg?
              screen.show_message(_INTL("Eggs can't hold mail."))
            elsif pkmn.hasItem? || pkmn.mail
              screen.show_message(_INTL("This Pokémon is holding an item. It can't hold mail."))
            else
              pkmn.mail = $PokemonGlobal.mailbox[mail_index]
              $PokemonGlobal.mailbox.delete_at(mail_index)
              screen.refresh
              screen.show_message(_INTL("Mail was transferred from the Mailbox."))
              next true
            end
            next false
          end
        end
      else
        pbPlayDecisionSE
      end
    end
  end

  #-----------------------------------------------------------------------------

  def storage_creator_name
    return GameData::Metadata.get.storage_creator
  end

  def pokemon_storage
    commands = {
      :organize => [_INTL("Organize Boxes"),   _INTL("Organize the Pokémon in Boxes and in your party.")],
      :withdraw => [_INTL("Withdraw Pokémon"), _INTL("Move Pokémon stored in Boxes to your party.")],
      :deposit  => [_INTL("Deposit Pokémon"),  _INTL("Store Pokémon in your party in Boxes.")],
      :quit     => [_INTL("See ya!"),          _INTL("Return to the previous menu.")]
    }
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil, commands.values.map { |val| val[0] },
                                       commands.values.map { |val| val[1] }, -1, command)
      break if command < 0
      case commands.keys[command]
      when :organize
        # Can always organize boxes
      when :withdraw
        if $PokemonStorage.party_full?
          pbMessage(_INTL("Your party is full!"))
          next
        end
      when :deposit
        if $player.able_pokemon_count <= 1
          pbMessage(_INTL("Can't deposit the last Pokémon!"))
          next
        end
      else
        break
      end
      pbPlayDecisionSE
      pbFadeOutIn { UI::PokemonStorage.new($PokemonStorage, mode: commands.keys[command]).main }
    end
  end
end

#===============================================================================
# Menu options for the player's PC found in their home.
#===============================================================================
MenuHandlers.add(:player_pc_menu, :item_storage, {
  "name"   => proc { next _INTL("Item Storage") },
  "order"  => 10,
  "effect" => proc { |menu|
    pbPlayDecisionSE
    UI::PC.item_storage
    next false
  }
})

MenuHandlers.add(:player_pc_menu, :mailbox, {
  "name"   => proc { next _INTL("Mailbox") },
  "order"  => 20,
  "effect" => proc { |menu|
    if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length == 0
      pbMessage(_INTL("There's no Mail here."))
      next false
    end
    pbPlayDecisionSE
    UI::PC.mailbox
    next false
  }
})

MenuHandlers.add(:player_pc_menu, :close, {
  "name"   => _INTL("Turn off"),
  "order"  => 999,
  "effect" => proc { |menu|
    next true
  }
})

#===============================================================================
# Menu options for the main PC found in Poké Centers. There are more options
# elsewhere in the scripts, e.g. for the Hall of Fame and Purify Chamber.
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"   => proc {
    next ($player.seen_storage_creator) ? _INTL("{1}'s PC", UI::PC.storage_creator_name) : _INTL("Someone's PC")
  },
  "order"  => 10,
  "effect" => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("The Pokémon Storage System was opened."))
    UI::PC.pokemon_storage
    next false
  }
})

MenuHandlers.add(:pc_menu, :player_pc, {
  "name"   => proc { next _INTL("{1}'s PC", $player.name) },
  "order"  => 20,
  "effect" => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("Accessed {1}'s PC.", $player.name))
    UI::PC.trainer_pc_menu
    next false
  }
})

MenuHandlers.add(:pc_menu, :close, {
  "name"   => _INTL("Log off"),
  "order"  => 999,
  "effect" => proc { |menu|
    next true
  }
})

#===============================================================================
# Methods for interacting with PCs in the overworld.
#===============================================================================
def pbTrainerPC
  pbMessage("\\se[PC open]" + _INTL("{1} booted up the PC.", $player.name))
  UI::PC.trainer_pc_menu
  pbSEPlay("PC close")
end

def pbPokeCenterPC
  pbMessage("\\se[PC open]" + _INTL("{1} booted up the PC.", $player.name))
  UI::PC.poke_center_pc_menu
  pbSEPlay("PC close")
end

def pbGetStorageCreator
  return UI::PC.storage_creator_name
end
