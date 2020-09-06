class PokeBattle_Pokemon
  attr_accessor :chatter
end



def pbChatter(pokemon)
  iconwindow=PictureWindow.new(pbLoadPokemonBitmap(pokemon))
  iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
  iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
  if pokemon.chatter
    pbMessage(_INTL("It will forget the song it knows.\1"))
    if !pbConfirmMessage(_INTL("Are you sure you want to change it?"))
      iconwindow.dispose
      return
    end
  end
  if pbConfirmMessage(_INTL("Do you want to change its song now?"))
    wave=pbRecord(nil,5)
    if wave
      pokemon.chatter=wave
      pbMessage(_INTL("{1} learned a new song!",pokemon.name))
    end
  end
  iconwindow.dispose
  return
end



HiddenMoveHandlers::CanUseMove.add(:CHATTER,proc { |move,pkmn,showmsg|
  next true
})

HiddenMoveHandlers::UseMove.add(:CHATTER,proc { |move,pokemon|
  pbChatter(pokemon)
  next true
})


class PokeBattle_Scene
  def pbChatter(user,_target)
    pbPlayCry(user.pokemon,90,100) if user.pokemon
    Graphics.frame_rate.times do
      Graphics.update
      Input.update
    end
  end
end
