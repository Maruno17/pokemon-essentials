#===============================================================================
#
#===============================================================================
class TrainerPC
  def shouldShow?
    return true
  end

  def name
    return _INTL("{1}'s PC",$Trainer.name)
  end

  def access
    pbMessage(_INTL("\\se[PC access]Accessed {1}'s PC.",$Trainer.name))
    pbTrainerPCMenu
  end
end

#===============================================================================
#
#===============================================================================
class StorageSystemPC
  def shouldShow?
    return true
  end

  def name
    if $Trainer.seen_storage_creator
      return _INTL("{1}'s PC",pbGetStorageCreator)
    else
      return _INTL("Someone's PC")
    end
  end

  def access
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
         _INTL("Return to the previous menu.")],-1,command
      )
      if command>=0 && command<3
        if command==1   # Withdraw
          if $PokemonStorage.party_full?
            pbMessage(_INTL("Your party is full!"))
            next
          end
        elsif command==2   # Deposit
          count=0
          for p in $PokemonStorage.party
            count += 1 if p && !p.egg? && p.hp>0
          end
          if count<=1
            pbMessage(_INTL("Can't deposit the last Pokémon!"))
            next
          end
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene,$PokemonStorage)
          screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
module PokemonPCList
  @@pclist = []

  def self.registerPC(pc)
    @@pclist.push(pc)
  end

  def self.getCommandList
    commands = []
    for pc in @@pclist
      commands.push(pc.name) if pc.shouldShow?
    end
    commands.push(_INTL("Log Off"))
    return commands
  end

  def self.callCommand(cmd)
    return false if cmd<0 || cmd>=@@pclist.length
    i = 0
    for pc in @@pclist
      next if !pc.shouldShow?
      if i==cmd
        pc.access
        return true
      end
      i += 1
    end
    return false
  end
end

#===============================================================================
# PC menus
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
       _INTL("Go back to the previous menu.")],-1,command
    )
    case command
    when 0   # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn {
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          screen.pbWithdrawItemScreen
        }
      end
    when 1   # Deposit Item
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        screen.pbDepositItemScreen
      }
    when 2   # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn {
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length==0
    pbMessage(_INTL("There's no Mail here."))
  else
    loop do
      command = 0
      commands=[]
      for mail in $PokemonGlobal.mailbox
        commands.push(mail.sender)
      end
      commands.push(_INTL("Cancel"))
      command = pbShowCommands(nil,commands,-1,command)
      if command>=0 && command<$PokemonGlobal.mailbox.length
        mailIndex = command
        commandMail = pbMessage(_INTL("What do you want to do with {1}'s Mail?",
           $PokemonGlobal.mailbox[mailIndex].sender),[
           _INTL("Read"),
           _INTL("Move to Bag"),
           _INTL("Give"),
           _INTL("Cancel")
           ],-1)
        case commandMail
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
        when 1   # Move to Bag
          if pbConfirmMessage(_INTL("The message will be lost. Is that OK?"))
            if $PokemonBag.pbStoreItem($PokemonGlobal.mailbox[mailIndex].item)
              pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              pbMessage(_INTL("The Bag is full."))
            end
          end
        when 2   # Give
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("What do you want to do?"),[
       _INTL("Item Storage"),
       _INTL("Mailbox"),
       _INTL("Turn Off")
       ],-1,nil,command)
    case command
    when 0 then pbPCItemStorage
    when 1 then pbPCMailbox
    else        break
    end
  end
end

def pbTrainerPC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

def pbPokeCenterPC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
  command = 0
  loop do
    commands = PokemonPCList.getCommandList
    command = pbMessage(_INTL("Which PC should be accessed?"),commands,
       commands.length,nil,command)
    break if !PokemonPCList.callCommand(command)
  end
  pbSEPlay("PC close")
end

def pbGetStorageCreator
  creator = Settings.storage_creator_name
  creator = _INTL("Bill") if nil_or_empty?(creator)
  return creator
end

#===============================================================================
#
#===============================================================================
PokemonPCList.registerPC(StorageSystemPC.new)
PokemonPCList.registerPC(TrainerPC.new)
