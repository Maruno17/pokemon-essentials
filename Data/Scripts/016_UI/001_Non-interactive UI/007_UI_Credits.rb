#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre. Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5. Music can
# now be defined. Credits can't be skipped during their first play.
#
## New Edit 25/3/2020 by Maruno.
# Scroll speed is now independent of frame rate. Now supports non-integer values
# for SCROLL_SPEED.
#
## New Edit 21/8/2020 by Marin.
# Now automatically inserts the credits from the plugins that have been
# registered through the PluginManager module.
#==============================================================================
class Scene_Credits
  # Backgrounds to show in credits. Found in Graphics/Titles/ folder
  BACKGROUNDS_LIST       = ["credits1", "credits2", "credits3", "credits4", "credits5"]
  BGM                    = "Credits"
  SCROLL_SPEED           = 60   # Pixels per second
  SECONDS_PER_BACKGROUND = 11
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR      = Color.new(0, 0, 0, 100)

  # This next piece of code is the credits.
  # Start Editing
  CREDIT = <<_END_

Pokémon Infinite Fusion
By Frogman

General graphics / Music / Intellectual property
Nintendo
GameFreak

Programming / Eventing:
Frogman

Fused Pokemon Sprites  :
Japeal - Pokefusion 2
http://japeal.com/pkm

Special thanks to Aegide for helping to 
rip the sprites and to the owners of Japeal 
for accepting to share their generated sprites.

Maps:
Frogman
Some of the maps were based on work by:
BenGames, Zeak6464

Gameplay / Story:
Frogman 
The story and dialogues were based 
off Pokémon Red and Blue, as well as
Pokémon Gold and Silver.
Both games are made by Game Freak.

ALl of the custom fused Pokémon sprites 
were madeby various members of the sp
Pokémon Infinite Fusion Discord

Including massive contributions from these users:

Toad 900#1617, Kiwi#4199, Aquatic#7954, 
Knuckles3&Knuckles#7559, Katten#7455, Blaquaza#1347, 
Blackboots#7369, Milchik#6233, Gdei#2810, 
Universez#0767, Scarecrow_924#8531, mammuth use ursaluna#3114, 
Kulgun#3323, Retrogamer#9934, Scrapi#6319, 
PinkYoshi#2350, Tomate#6670, Stan#3932, 
Xiapher#4244, Howls#4468, xoto#0766, 
xigzagoon#9354, Beespoon#2222, NeoSoup#6526, 
Sjoba_sheep#1111, Maelmc#9965, Thornsoflight#3245, 
Xillo#5236, pengu#6874, Mope7#1139, 
Gorky#1761, All-Seeing#9253, IGot50lbsOfTanneritelnMyAnus#4093, 
Emisys#4024, JamoJauhis#4971, Cheepoof#8815, 
Moon_Tah#2688, BButton#8097, Punko#1235, 
NakaMagic#0774, Tabarnak#2210, M4rcus#0928, 
Bubba-Rottweiler#7322, Keksgesicht#7133, Teamama#4369, 
BTT#3408, calicorn#6994, Pain T#3334, 
Taylor Mai#0134, Underuser#5401, AkumaDelta#2364, 
Scotsman#6299, GenoRhye#3335, (✿◠‿◠)Kanger#3997, 
JoshuLips#5010, GREEN#2016, SpiDrone#6590, 
Bizmythe#4062, Silver#4784, gnose_#6945, 
D'Octobre#2420, Tenedranox#5660


Other custom graphics:
calicorn, Doctor Miawoo, Frogman, Kiwi,
Knuckles, magnuzone, ,mammuth89, Miawoo, 
Milchik, Rick1234, Universez, UnworthyPie,


The following free ressources were also used 
with their respective authors' consent:

Pokémon Sprites:
The Smogon XY Sprite Project:
Smogon Sun/Moon Sprite Project:

Other sprites:
Hankiro, luckygirl88, Nalty, 
OceansLugiaSpirit,Pokemon-Diamond,
rekman, Rick1234, SailorVicious,WolfPP

Tileset graphics:
Alucus BoOmxBiG, chimcharsfireworkd, 
EpicDay, EternalTakai, Gallanty Heavy-Metal-Lover, 
Hek-el-grande,DirtyWiggles, iametrine, Jorginho, 
kizemaru-kurunosuke, KKKaito, kyle-dove, Minorthreat0987,
 Phyromatical, Pokemon-Diamond, rayd12smitty, Rossay, 
Shiney570, Spacemotion, Speedialga, ThatsSoWitty Thurpok, 
TyranitarDark, UltimoSpriter, WesleyFG,

Music:    
Pokeli, TailDoll666100
Kazune Sawatari, sentsinkantéun,
Nanashima, CharizardTheMaster, The Zame Jack 

RPG Maker Scripts:
Luka S.J, shiney570, Erasus, Umbreon
FL, KleinStudio, carmaniac, Wootius,
andracass
{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}


Data sources:  
Bulbapedia

PBS files:
Generation 6 for Pokémon Essentials
WorldSlayer
mej71,karstictrainer, WorldSlayer, 
TheDeKay, viperk1, SunakazeKun,
Radical Raptr, RPD490, 
Takyon!, Pokegod7020, Drakath569,
Florio, MrDeepDarkMind, snooper117


"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>MiDas Mike
Boushy<s>Near Fantastica
Brother1440<s>PinkMan
FL.<s>Popper
Genzai Kawakami<s>Rataime
Harshboy<s>SoundSpawn
help-14<s>the__end
IceGod64<s>Venom12
Jacob O. Wobbrock<s>Wachunga
KitsuneKouta<s>xLeD
Lisa Anthony<s>
and everyone else who helped out

"mkxp-z" by:
Roza
Based on MKXP by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

This game was inspired by the original
fusion generator: 
alexonsager.alexonsager.net

All generated fusion sprites in this game
come from the Pokémon Fusion Generator:
https://japeal.com/pkm/

Playtesting and Custom Sprites were made by 
various members of the Discord channel. 
Special thanks to all of you and to 
everyone who has been involved in the 
development of the game!

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak

This is a non-profit fan-made game.
No copyright infringements intended.
_END_
# Stop Editing

  def main
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    @counter = 0.0   # Counts time elapsed since the background image changed
    @bg_index = 0
    @bitmap_height = Graphics.height   # For a single credits text bitmap
    @trim = Graphics.height / 10
    # Number of game frames per background frame
    @realOY = -(Graphics.height - @trim)
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << pcred[0] + "\n"
        i = 1
        until i >= pcred.size
          plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << name + "\n" }
      end
      plugin_credits << "\n"
    end
    CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credit_lines = CREDIT.split(/\n/)
    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    text_viewport.z = 99999
    @background_sprite = IconSprite.new(0, 0)
    @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[0])
    @credit_sprites = []
    @total_height = credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
    for i in 0...num_bitmaps
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height)
      pbSetSystemFont(credit_bitmap)
      for j in 0...lines_per_bitmap
        line = credit_lines[i * lines_per_bitmap + j]
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1   # Centre align
        linewidth = Graphics.width
        for k in 0...line.length
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + Graphics.width / 2
            align = (k == 0) ? 2 : 0   # Right align : left align
            linewidth = Graphics.width / 2 - 20
          end
          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos,     j * 32 + 8, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_OUTLINE_COLOR
          credit_bitmap.draw_text(xpos + 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_BASE_COLOR
          credit_bitmap.draw_text(xpos,     j * 32,     linewidth, 32, line[k], align)
        end
      end
      credit_sprite = Sprite.new(text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z      = 9998
      credit_sprite.oy     = @realOY - @bitmap_height * i
      @credit_sprites[i] = credit_sprite
    end
    #-------------------------------
    # Setup
    #-------------------------------
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition(20)
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    pbBGMFade(2.0)
    Graphics.freeze
    viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(20, "fadetoblack")
    @background_sprite.dispose
    @credit_sprites.each { |s| s.dispose if s }
    text_viewport.dispose
    viewport.dispose
    $PokemonGlobal.creditsPlayed = true
    pbBGMPlay(previousBGM)
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::USE) && $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      pbBGMFade(1.0)
      return true
    end
    return false
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

  def update
    delta = Graphics.delta_s
    @counter += delta
    @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[@bg_index])

    # # Go to next slide
    # if @counter >= SECONDS_PER_BACKGROUND
    #   @counter -= SECONDS_PER_BACKGROUND
    #   @bg_index += 1
    #   @bg_index = 0 if @bg_index >= BACKGROUNDS_LIST.length
    #   @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[@bg_index])
    # end
    return if cancel?
    return if last?
    @realOY += SCROLL_SPEED * delta
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - @bitmap_height * i }
  end
end
