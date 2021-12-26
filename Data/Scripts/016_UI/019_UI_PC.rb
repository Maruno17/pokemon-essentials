#===============================================================================
# Various PC menus
#===============================================================================
# Item Storage -----------------------------------------------------------------
def pbPCItemStorage
  command = 0
  $PokemonGlobal.pcItemStorage = PCItemStorage.new if !$PokemonGlobal.pcItemStorage
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
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn {
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbWithdrawItemScreen
        }
      end
    when 1   # Deposit Item
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        screen.pbDepositItemScreen
      }
    when 2   # Toss Item
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn {
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

# Mailbox ----------------------------------------------------------------------
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
          pbFadeOutIn {
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
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
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene, $player.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

# Trainer PC Menu --------------------------------------------------------------
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

# Pokecenter PC  script command ------------------------------------------------
def pbPokeCenterPC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.", $player.name))
  command  = 0
  commands    = []
  display_cmd = []
  MenuHandlers.each_available(:pokemon_pc) do |option, hash|
    commands.push(option)
    name = MenuHandlers.get_string_option(:pokemon_pc, "name", option)
    display_cmd.push(name)
  end
  display_cmd.push(_INTL("Cancel"))
  loop do
    command = pbMessage(_INTL("Which PC should be accessed?"), display_cmd, commands.length, nil, command)
    break if command >= commands.length
    cmd      = commands[command]
    endscene = MenuHandlers.call(:pokemon_pc, "effect", cmd)
    break if endscene
  end
  pbSEPlay("PC close")
end

# Trainer PC script command ----------------------------------------------------
def pbTrainerPC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.", $player.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

# Get name of Storage System creator -------------------------------------------
def pbGetStorageCreator
  return GameData::Metadata.get.storage_creator
end


#===============================================================================
# Individual commands for the PC
#===============================================================================
# Pokemon Storage --------------------------------------------------------------
 MenuHandlers.register(:pokemon_pc, :pokemon_storage, {
  "name"        => proc {
    next $player.seen_storage_creator ? _INTL("{1}'s PC", pbGetStorageCreator) : _INTL("Someone's PC")
  },
  "condition"   => proc { next true },
  "priority"    => 40,
  "effect"      => proc {
    pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
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
      if command >= 0 && command < 3
        case command
        when 1   # Withdraw
          if $PokemonStorage.party_full?
            pbMessage(_INTL("Your party is full!"))
            next
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
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  }
})

# Trainer PC -------------------------------------------------------------------
 MenuHandlers.register(:pokemon_pc, :trainer_pc, {
  "name"        => proc { next _INTL("{1}'s PC", $player.name) },
  "condition"   => proc { next true },
  "priority"    => 30,
  "effect"      => proc {
    pbMessage(_INTL("\\se[PC access]Accessed {1}'s PC.", $player.name))
    pbTrainerPCMenu
  }
})-
