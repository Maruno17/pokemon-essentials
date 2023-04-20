#===============================================================================
#
#===============================================================================
def pbPCItemStorage
  command = 0
  loop do
    command = pbShowCommandsWithHelp(nil,
                                     [_INTL("Withdraw Item"),
                                      _INTL("Deposit Item"),
                                      _INTL("Toss Item"),
                                      _INTL("Exit")],
                                     [_INTL("Take out items from the PC."),
                                      _INTL("Store items in the PC."),
                                      _INTL("Throw away items stored in the PC."),
                                      _INTL("Go back to the previous menu.")], -1, command)
    case command
    when 0   # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn do
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbWithdrawItemScreen
        end
      end
    when 1   # Deposit Item
      pbFadeOutIn do
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        screen.pbDepositItemScreen
      end
    when 2   # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn do
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbTossItemScreen
        end
      end
    else
      break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length == 0
    pbMessage(_INTL("There's no Mail here."))
  else
    loop do
      command = 0
      commands = []
      $PokemonGlobal.mailbox.each do |mail|
        commands.push(mail.sender)
      end
      commands.push(_INTL("Cancel"))
      command = pbShowCommands(nil, commands, -1, command)
      if command >= 0 && command < $PokemonGlobal.mailbox.length
        mailIndex = command
        commandMail = pbMessage(
          _INTL("What do you want to do with {1}'s Mail?", $PokemonGlobal.mailbox[mailIndex].sender),
          [_INTL("Read"),
           _INTL("Move to Bag"),
           _INTL("Give"),
           _INTL("Cancel")], -1
        )
        case commandMail
        when 0   # Read
          pbFadeOutIn do
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          end
        when 1   # Move to Bag
          if pbConfirmMessage(_INTL("The message will be lost. Is that OK?"))
            if $bag.add($PokemonGlobal.mailbox[mailIndex].item)
              pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              pbMessage(_INTL("The Bag is full."))
            end
          end
        when 2   # Give
          pbFadeOutIn do
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene, $player.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          end
        end
      else
        break
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbTrainerPC
  pbMessage("\\se[PC open]" + _INTL("{1} booted up the PC.", $player.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("What do you want to do?"),
                        [_INTL("Item Storage"),
                         _INTL("Mailbox"),
                         _INTL("Turn Off")], -1, nil, command)
    case command
    when 0 then pbPCItemStorage
    when 1 then pbPCMailbox
    else        break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPokeCenterPC
  pbMessage("\\se[PC open]" + _INTL("{1} booted up the PC.", $player.name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:pc_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("Which PC should be accessed?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
  pbSEPlay("PC close")
end

def pbGetStorageCreator
  return GameData::Metadata.get.storage_creator
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"      => proc {
    next ($player.seen_storage_creator) ? _INTL("{1}'s PC", pbGetStorageCreator) : _INTL("Someone's PC")
  },
  "order"     => 10,
  "effect"    => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("The Pokémon Storage System was opened."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
                                       [_INTL("Organize Boxes"),
                                        _INTL("Withdraw Pokémon"),
                                        _INTL("Deposit Pokémon"),
                                        _INTL("See ya!")],
                                       [_INTL("Organize the Pokémon in Boxes and in your party."),
                                        _INTL("Move Pokémon stored in Boxes to your party."),
                                        _INTL("Store Pokémon in your party in Boxes."),
                                        _INTL("Return to the previous menu.")], -1, command)
      break if command < 0
      case command
      when 0   # Organize
        pbFadeOutIn do
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
        end
      when 1   # Withdraw
        if $PokemonStorage.party_full?
          pbMessage(_INTL("Your party is full!"))
          next
        end
        pbFadeOutIn do
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(1)
        end
      when 2   # Deposit
        count = 0
        $PokemonStorage.party.each do |p|
          count += 1 if p && !p.egg? && p.hp > 0
        end
        if count <= 1
          pbMessage(_INTL("Can't deposit the last Pokémon!"))
          next
        end
        pbFadeOutIn do
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(2)
        end
      else
        break
      end
    end
    next false
  }
})

MenuHandlers.add(:pc_menu, :player_pc, {
  "name"      => proc { next _INTL("{1}'s PC", $player.name) },
  "order"     => 20,
  "effect"    => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("Accessed {1}'s PC.", $player.name))
    pbTrainerPCMenu
    next false
  }
})

MenuHandlers.add(:pc_menu, :close, {
  "name"      => _INTL("Log off"),
  "order"     => 100,
  "effect"    => proc { |menu|
    next true
  }
})
