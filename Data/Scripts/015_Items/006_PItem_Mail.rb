# Data structure representing mail that the Pokémon can hold
class PokemonMail
  attr_accessor :item,:message,:sender,:poke1,:poke2,:poke3

  def initialize(item,message,sender,poke1=nil,poke2=nil,poke3=nil)
    @item    = item      # Item represented by this mail
    @message = message   # Message text
    @sender  = sender    # Name of the message's sender
    @poke1   = poke1     # [species,gender,shininess,form,shadowness,is egg]
    @poke2   = poke2
    @poke3   = poke3
  end
end



def pbMoveToMailbox(pokemon)
  $PokemonGlobal.mailbox = [] if !$PokemonGlobal.mailbox
  return false if $PokemonGlobal.mailbox.length>=10
  return false if !pokemon.mail
  $PokemonGlobal.mailbox.push(pokemon.mail)
  pokemon.mail = nil
  return true
end

def pbStoreMail(pkmn,item,message,poke1=nil,poke2=nil,poke3=nil)
  raise _INTL("Pokémon already has mail") if pkmn.mail
  pkmn.mail = PokemonMail.new(item,message,$Trainer.name,poke1,poke2,poke3)
end

def pbDisplayMail(mail,_bearer=nil)
  sprites = {}
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  addBackgroundPlane(sprites,"background","mailbg",viewport)
  sprites["card"] = IconSprite.new(0,0,viewport)
  sprites["card"].setBitmap(pbMailBackFile(mail.item))
  sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
  overlay = sprites["overlay"].bitmap
  pbSetSystemFont(overlay)
  if pbIsMailWithPokemonIcons?(mail.item)
    if mail.poke1
      sprites["bearer"] = IconSprite.new(64,288,viewport)
      bitmapFileName = pbCheckPokemonIconFiles(mail.poke1,mail.poke1[5])
      sprites["bearer"].setBitmap(bitmapFileName)
      sprites["bearer"].src_rect.set(0,0,64,64)
    end
    if mail.poke2
      sprites["bearer2"] = IconSprite.new(144,288,viewport)
      bitmapFileName = pbCheckPokemonIconFiles(mail.poke2,mail.poke2[5])
      sprites["bearer2"].setBitmap(bitmapFileName)
      sprites["bearer2"].src_rect.set(0,0,64,64)
    end
    if mail.poke3
      sprites["bearer3"] = IconSprite.new(224,288,viewport)
      bitmapFileName = pbCheckPokemonIconFiles(mail.poke3,mail.poke3[5])
      sprites["bearer3"].setBitmap(bitmapFileName)
      sprites["bearer3"].src_rect.set(0,0,64,64)
    end
  end
  baseForDarkBG    = Color.new(248,248,248)
  shadowForDarkBG  = Color.new(72,80,88)
  baseForLightBG   = Color.new(80,80,88)
  shadowForLightBG = Color.new(168,168,176)
  if mail.message && mail.message!=""
    isDark = isDarkBackground(sprites["card"].bitmap,Rect.new(48,48,Graphics.width-96,32*7))
    drawTextEx(overlay,48,48,Graphics.width-(48*2),7,mail.message,
       (isDark) ? baseForDarkBG : baseForLightBG,
       (isDark) ? shadowForDarkBG : shadowForLightBG)
  end
  if mail.sender && mail.sender!=""
    isDark = isDarkBackground(sprites["card"].bitmap,Rect.new(336,322,144,32*1))
    drawTextEx(overlay,336,322,144,1,mail.sender,
       (isDark) ? baseForDarkBG : baseForLightBG,
       (isDark) ? shadowForDarkBG : shadowForLightBG)
  end
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      break
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

def pbWriteMail(item,pkmn,pkmnid,scene)
  message = ""
  loop do
    message = pbMessageFreeText(_INTL("Please enter a message (max. 250 characters)."),
       "",false,250,Graphics.width) { scene.pbUpdate }
    if message!=""
      # Store mail if a message was written
      poke1 = poke2 = nil
      if $Trainer.party[pkmnid+2]
        p = $Trainer.party[pkmnid+2]
        poke1 = [p.species,p.gender,p.shiny?,(p.form rescue 0),p.shadowPokemon?]
        poke1.push(true) if p.egg?
      end
      if $Trainer.party[pkmnid+1]
        p = $Trainer.party[pkmnid+1]
        poke2 = [p.species,p.gender,p.shiny?,(p.form rescue 0),p.shadowPokemon?]
        poke2.push(true) if p.egg?
      end
      poke3 = [pkmn.species,pkmn.gender,pkmn.shiny?,(pkmn.form rescue 0),pkmn.shadowPokemon?]
      poke3.push(true) if pkmn.egg?
      pbStoreMail(pkmn,item,message,poke1,poke2,poke3)
      return true
    end
    return false if scene.pbConfirm(_INTL("Stop giving the Pokémon Mail?"))
  end
end
