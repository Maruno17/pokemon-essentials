class PBFusion
  Unknown        = 0 # Do not use
  Happiness      = 1
  HappinessDay   = 2
  HappinessNight = 3
  Level          = 4
  Trade          = 5
  TradeItem      = 6
  Item           = 7
  AttackGreater  = 8
  AtkDefEqual    = 9
  DefenseGreater = 10
  Silcoon        = 11
  Cascoon        = 12
  Ninjask        = 13
  Shedinja       = 14
  Beauty         = 15
  ItemMale       = 16
  ItemFemale     = 17
  DayHoldItem    = 18
  NightHoldItem  = 19
  HasMove        = 20
  HasInParty     = 21
  LevelMale      = 22
  LevelFemale    = 23
  Location       = 24
  TradeSpecies   = 25
  Custom1        = 26
  Custom2        = 27
  Custom3        = 28
  Custom4        = 29
  Custom5        = 30
  Custom6        = 31
  Custom7        = 32

  EVONAMES=["Unknown",
     "Happiness","HappinessDay","HappinessNight","Level","Trade",
     "TradeItem","Item","AttackGreater","AtkDefEqual","DefenseGreater",
     "Silcoon","Cascoon","Ninjask","Shedinja","Beauty",
     "ItemMale","ItemFemale","DayHoldItem","NightHoldItem","HasMove",
     "HasInParty","LevelMale","LevelFemale","Location","TradeSpecies",
     "Custom1","Custom2","Custom3","Custom4","Custom5","Custom6","Custom7"
  ]

  # 0 = no parameter
  # 1 = Positive integer
  # 2 = Item internal name
  # 3 = Move internal name
  # 4 = Species internal name
  # 5 = Type internal name
  EVOPARAM=[0,     # Unknown (do not use)
     0,0,0,1,0,    # Happiness, HappinessDay, HappinessNight, Level, Trade
     2,2,1,1,1,    # TradeItem, Item, AttackGreater, AtkDefEqual, DefenseGreater
     1,1,1,1,1,    # Silcoon, Cascoon, Ninjask, Shedinja, Beauty
     2,2,2,2,3,    # ItemMale, ItemFemale, DayHoldItem, NightHoldItem, HasMove
     4,1,1,1,4,    # HasInParty, LevelMale, LevelFemale, Location, TradeSpecies
     1,1,1,1,1,1,1 # Custom 1-7
  ]
end



class SpriteMetafile
  VIEWPORT      = 0
  TONE          = 1
  SRC_RECT      = 2
  VISIBLE       = 3
  X             = 4
  Y             = 5
  Z             = 6
  OX            = 7
  OY            = 8
  ZOOM_X        = 9
  ZOOM_Y        = 10
  ANGLE         = 11
  MIRROR        = 12
  BUSH_DEPTH    = 13
  OPACITY       = 14
  BLEND_TYPE    = 15
  COLOR         = 16
  FLASHCOLOR    = 17
  FLASHDURATION = 18
  BITMAP        = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport=nil)
    @metafile=[]
    @values=[
       viewport,
       Tone.new(0,0,0,0),Rect.new(0,0,0,0),
       true,
       0,0,0,0,0,100,100,
       0,false,0,255,0,
       Color.new(0,0,0,0),Color.new(0,0,0,0),
       0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color,duration)
    if duration>0
      @values[FLASHCOLOR]=color.clone
      @values[FLASHDURATION]=duration
      @metafile.push([FLASHCOLOR,color])
      @metafile.push([FLASHDURATION,duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X]=value
    @metafile.push([X,value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y]=value
    @metafile.push([Y,value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0,0,value.width,value.height)
      @metafile.push([SRC_RECT,@values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT]=value
   @metafile.push([SRC_RECT,value])
 end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE]=value
    @metafile.push([VISIBLE,value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z]=value
    @metafile.push([Z,value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX]=value
    @metafile.push([OX,value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY]=value
    @metafile.push([OY,value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X]=value
    @metafile.push([ZOOM_X,value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y]=value
    @metafile.push([ZOOM_Y,value])
  end

  def angle
    return @values[ANGLE]
  end

  def angle=(value)
    @values[ANGLE]=value
    @metafile.push([ANGLE,value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR]=value
    @metafile.push([MIRROR,value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH]=value
    @metafile.push([BUSH_DEPTH,value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY]=value
    @metafile.push([OPACITY,value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE]=value
    @metafile.push([BLEND_TYPE,value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR]=value.clone
    @metafile.push([COLOR,@values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE]=value.clone
    @metafile.push([TONE,@values[TONE]])
  end

  def update
    @metafile.push([-1,nil])
  end
end



class SpriteMetafilePlayer
  def initialize(metafile,sprite=nil)
    @metafile=metafile
    @sprites=[]
    @playing=false
    @index=0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing=true
    @index=0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index=j+1
        break if @metafile[j][0]<0
        code=@metafile[j][0]
        value=@metafile[j][1]
        for sprite in @sprites
          case code
            when SpriteMetafile::X
              sprite.x=value
            when SpriteMetafile::Y
              sprite.y=value
            when SpriteMetafile::OX
              sprite.ox=value
            when SpriteMetafile::OY
              sprite.oy=value
            when SpriteMetafile::ZOOM_X
              sprite.zoom_x=value
            when SpriteMetafile::ZOOM_Y
              sprite.zoom_y=value
            when SpriteMetafile::SRC_RECT
              sprite.src_rect=value
            when SpriteMetafile::VISIBLE
              sprite.visible=value
            when SpriteMetafile::Z
              sprite.z=value
            # prevent crashes
            when SpriteMetafile::ANGLE
              sprite.angle=(value==180) ? 179.9 : value
            when SpriteMetafile::MIRROR
              sprite.mirror=value
            when SpriteMetafile::BUSH_DEPTH
              sprite.bush_depth=value
            when SpriteMetafile::OPACITY
              sprite.opacity=value
            when SpriteMetafile::BLEND_TYPE
              sprite.blend_type=value
            when SpriteMetafile::COLOR
              sprite.color=value
            when SpriteMetafile::TONE
              sprite.tone=value
          end
        end
      end
      @playing=false if @index==@metafile.length
    end
  end
end



def pbSaveSpriteState(sprite)
  state=[]
  return state if !sprite || sprite.disposed?
  state[SpriteMetafile::BITMAP]     = sprite.x
  state[SpriteMetafile::X]          = sprite.x
  state[SpriteMetafile::Y]          = sprite.y
  state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
  state[SpriteMetafile::VISIBLE]    = sprite.visible
  state[SpriteMetafile::Z]          = sprite.z
  state[SpriteMetafile::OX]         = sprite.ox
  state[SpriteMetafile::OY]         = sprite.oy
  state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
  state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
  state[SpriteMetafile::ANGLE]      = sprite.angle
  state[SpriteMetafile::MIRROR]     = sprite.mirror
  state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
  state[SpriteMetafile::OPACITY]    = sprite.opacity
  state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
  state[SpriteMetafile::COLOR]      = sprite.color.clone
  state[SpriteMetafile::TONE]       = sprite.tone.clone
  return state
end

def pbRestoreSpriteState(sprite,state)
  return if !state || !sprite || sprite.disposed?
  sprite.x          = state[SpriteMetafile::X]
  sprite.y          = state[SpriteMetafile::Y]
  sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
  sprite.visible    = state[SpriteMetafile::VISIBLE]
  sprite.z          = state[SpriteMetafile::Z]
  sprite.ox         = state[SpriteMetafile::OX]
  sprite.oy         = state[SpriteMetafile::OY]
  sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
  sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
  sprite.angle      = state[SpriteMetafile::ANGLE]
  sprite.mirror     = state[SpriteMetafile::MIRROR]
  sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
  sprite.opacity    = state[SpriteMetafile::OPACITY]
  sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
  sprite.color      = state[SpriteMetafile::COLOR]
  sprite.tone       = state[SpriteMetafile::TONE]
end

def pbSaveSpriteStateAndBitmap(sprite)
  return [] if !sprite || sprite.disposed?
  state=pbSaveSpriteState(sprite)
  state[SpriteMetafile::BITMAP]=sprite.bitmap
  return state
end

def pbRestoreSpriteStateAndBitmap(sprite,state)
  return if !state || !sprite || sprite.disposed?
  sprite.bitmap=state[SpriteMetafile::BITMAP]
  pbRestoreSpriteState(sprite,state)
  return state
end



#####################

class PokemonFusionScene
  private
  def pbGenerateMetafiles(s1x,s1y,s2x,s2y,s3x,s3y,sxx,s3xx)
    sprite=SpriteMetafile.new
    sprite3=SpriteMetafile.new
    sprite2=SpriteMetafile.new
    
    sprite.opacity=255
    sprite3.opacity=255
    sprite2.opacity=0
    
    
    sprite.ox=s1x
    sprite.oy=s1y
    sprite2.ox=s2x
    sprite2.oy=s2y
    sprite3.ox=s3x
    sprite3.oy=s3y 
    
    
    sprite.x = sxx
    sprite3.x=s3xx
    
    red=10
    green=5
    blue=90
    
    for j in 0...26
      sprite.color.red= red
      sprite.color.green=green
      sprite.color.blue=blue
      sprite.color.alpha=j*10
      sprite.color=sprite.color
      
      sprite3.color.red= red
      sprite3.color.green=green
      sprite3.color.blue=blue
      sprite3.color.alpha=j*10
      sprite3.color=sprite3.color      
   

      
      sprite2.color=sprite.color
      sprite.update
      sprite3.update      
      sprite2.update
    end
    anglechange=0
    sevenseconds=Graphics.frame_rate*3  #actually 3 seconds
    for j in 0...sevenseconds
      sprite.angle+=anglechange
      sprite.angle%=360
      
      sprite3.angle+=anglechange
      sprite3.angle%=360
      
      
      anglechange+=5 if j%2==0
      if j>=sevenseconds-50
        sprite2.angle=sprite.angle
        sprite2.opacity+=6
      end
      
      if sprite.x < sprite3.x && j >=20
         sprite.x +=2
         sprite3.x -= 2
       else      
       #sprite.ox+=1
       #sprite3.ox+=1
       end
       
      sprite.update
      sprite3.update      
      sprite2.update
    end
    sprite.angle=360-sprite.angle
    sprite3.angle=360-sprite.angle    
    sprite2.angle=360-sprite2.angle
    for j in 0...sevenseconds
      sprite2.angle+=anglechange
      sprite2.angle%=360
      anglechange-=5 if j%2==0
      if j<50
        sprite.angle=sprite2.angle
        sprite.opacity-=6                
        
        sprite3.angle=sprite2.angle
        sprite3.opacity-=6
      end
    
      
      
      sprite3.update      
      sprite.update
      sprite2.update
      
      
    end
    for j in 0...26
      sprite2.color.red=30
      sprite2.color.green=230 
      sprite2.color.blue=55
      sprite2.color.alpha=(26-j)*10
      sprite2.color=sprite2.color
      sprite.color=sprite2.color
      sprite.update
      sprite2.update
    end
    @metafile1=sprite
    @metafile2=sprite2
    @metafile3=sprite3
    
  end

# Starts the evolution screen with the given Pokemon and new Pokemon species.
  public

  def pbStartScreen(pokemon1,pokemon2,newspecies)    
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon1=pokemon1
    @pokemon2=pokemon2

    @newspecies=newspecies
    addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
       Color.new(248,248,248),@viewport)
       

    rsprite1=PokemonSprite.new(@viewport)
    rsprite2=PokemonSprite.new(@viewport)
    rsprite3 =PokemonSprite.new(@viewport)
    
    rsprite1.setPokemonBitmap(@pokemon1,false)
    rsprite3.setPokemonBitmap(@pokemon2,false)

    rsprite2.setPokemonBitmapSpecies(@pokemon1,@newspecies,false)
    
    rsprite1.ox=rsprite1.bitmap.width/2
    rsprite1.oy=rsprite1.bitmap.height/2
    
    rsprite3.ox=rsprite3.bitmap.width/2
    rsprite3.oy=rsprite3.bitmap.height/2
    
    rsprite2.ox=rsprite2.bitmap.width/2
    rsprite2.oy=rsprite2.bitmap.height/2
    
    
    
    rsprite2.x=Graphics.width/2
    rsprite1.y=(Graphics.height-96)/2
    rsprite3.y=(Graphics.height-96)/2

    rsprite1.x=(Graphics.width/2)-100
    rsprite3.x=(Graphics.width/2)+100
   
    
    rsprite2.y=(Graphics.height-96)/2
    rsprite2.opacity=0
    @sprites["rsprite1"]=rsprite1
    @sprites["rsprite2"]=rsprite2
    @sprites["rsprite3"]=rsprite3
    
    pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy,rsprite3.ox,rsprite3.oy,rsprite1.x,rsprite3.x)

    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
    
    ####FUSION MULTIPLIER
    
    #####LEVELS
    level1 = pokemon1.level
    level2 = pokemon2.level
  
    ####LEVEL DIFFERENCE
    if (level1 >= level2) then
      avgLevel =  (2*level1 + level2)/3
    else
      avgLevel =  (2*level2 + level1)/3
    end
    
    ####CAPTURE RATES
    ####Check success Poke 1
   # if (fusionCheckSuccess (30, leveldiff, level1,fusionmultiplier)) then
   #   return 1
   # else
    #  return 0
    #end

    ####Check success Poke 2
   # if (fusionCheckSuccess (30, leveldiff, level1,fusionmultiplier)) then
   #   return 1
   # else
   #   return 0
   # end   
  return 1
  end

  def averageFusionIvs()
    for i in 0..@pokemon1.iv.length-1
      poke1Iv = @pokemon1.iv[i]
      poke2Iv = @pokemon2.iv[i]
      @pokemon1.iv[i] = ((poke1Iv+poke2Iv)/2).floor
    end
  end
  
  #unused. was meant for super splicers, but too broken
  def setHighestFusionIvs()
    for i in 0..@pokemon1.iv.length-1
      iv1 = @pokemon1.iv[i]
      iv2 = @pokemon2.iv[i]
      @pokemon1.iv[i] = iv1 >= iv2 ? iv1 : iv2
    end
  end
  
# Closes the evolution screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

# Opens the fusion screen
   def pbFusionScreen(cancancel=false,superSplicer=false)
    metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
    metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
    metaplayer3=SpriteMetafilePlayer.new(@metafile3,@sprites["rsprite3"])
    
    
    metaplayer1.play
    metaplayer2.play
    metaplayer3.play
    
    pbBGMStop()
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
    _INTL("The Pokémon are being fused!",@pokemon1.name))

   
   
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
    pbPlayDecisionSE()
    oldstate=pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
    oldstate3=pbSaveSpriteState(@sprites["rsprite3"])
    
    pbBGMPlay("fusion")
    
    canceled = false
    noMoves=false
    begin
      metaplayer1.update
      metaplayer2.update
      metaplayer3.update
      
      Graphics.update
      Input.update
      if Input.trigger?(Input::B) && Input.trigger?(Input::C)# && Input.trigger?(Input::A)# && cancancel
        noMoves=true
        pbSEPlay("buzzer")
        Graphics.update 
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    if canceled
      pbBGMStop()
      pbPlayCancelSE()
     # Kernel.pbMessageDisplay(@sprites["msgwindow"],
     @pbEndScreen
         _INTL("Huh? The fusion was cancelled!")         
    else
      frames=pbCryFrameLength(@newspecies)
      pbBGMStop()
      pbPlayCry(@newspecies)
      frames.times do
        Graphics.update
      end
      pbMEPlay("Voltorb Flip Win")
      newspeciesname=PBSpecies.getName(@newspecies)
      oldspeciesname=PBSpecies.getName(@pokemon1.species)
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("\\se[]Congratulations! Your Pokémon were fused into {2}!\\wt[80]",@pokemon1.name,newspeciesname))
 
      averageFusionIvs()
      #add to pokedex 
      if ! $Trainer.owned[@newspecies]
        $Trainer.seen[@newspecies]=true
        $Trainer.owned[@newspecies]=true
        pbSeenForm(@pokemon)
        Kernel.pbMessageDisplay(@sprites["msgwindow"],
        _INTL("{1}'s data was added to the Pokédex",newspeciesname))         
        @scene.pbShowPokedex(@newspecies)     
      end
      #first check if hidden ability
      hiddenAbility1 = @pokemon1.ability ==  @pokemon1.getAbilityList[0][-1]
      hiddenAbility2 = @pokemon2.ability ==  @pokemon2.getAbilityList[0][-1]

      #change species
      @pokemon1.species=@newspecies

      #Check moves for new species
      movelist=@pokemon1.getMoveList
      for i in movelist
        if i[0]==@pokemon1.level          
          pbLearnMove(@pokemon1,i[1]) if !noMoves #(pokemon,move,ignoreifknown=true, byTM=false , quick =true)
       end
     end   
       #@pokemon1.ability = pbChooseAbility(@pokemon1,@pokemon2)  
      removeItem=false
      if @pokemon2.isShiny? || @pokemon1.isShiny?
        @pokemon1.makeShiny
      end
    
     #make it untraded, pour qu'on puisse le unfused après, même si un des 2 était traded
      @pokemon1.obtainMode = 0

      @pokemon1.setAbility(pbChooseAbility(@pokemon1,hiddenAbility1,hiddenAbility2))
       if superSplicer
        @pokemon1.setNature(pbChooseNature(@pokemon1.nature,@pokemon2.nature))
      end
      
       movelist=@pokemon2.moves
       for k in movelist
        if k.id != 0
          pbLearnMove(@pokemon1,k.id,true,false,true) if !noMoves
        end
       end
      

      
      pbSEPlay("Voltorb Flip Point")

      @pokemon1.firstmoves=[]
      @pokemon1.name=newspeciesname if @pokemon1.name==oldspeciesname
      
      @pokemon1.level = setPokemonLevel(@pokemon1.level, @pokemon2.level,superSplicer)
      @pokemon1.calcStats
      @pokemon1.obtainMode = 0
      
    end
  end
end

def setPokemonLevel(pokemon1,pokemon2,superSplicers)
  lv1 = @pokemon1.level
  lv2 =  @pokemon2.level
   if superSplicers  
        if lv1 > lv2
          return lv1
        else
          return lv2
        end
    else
        if (lv1 >= lv2) then
          return  (2*lv1 + lv2)/3
        else
          return  (2*lv2 + lv1)/3
        end
    end
    return lv1
end

def pbShowPokedex(species)
  pbFadeOutIn {
    scene = PokemonPokedexInfo_Scene.new
    screen = PokemonPokedexInfoScreen.new(scene)
    screen.pbDexEntry(species)
  }
end




def pbChooseAbility(poke,hidden1=false,hidden2=false)
    abilityList = poke.getAbilityList
    #pas sur de l'ordre pour les hidden (3 et 4) peut-être a inverser
    #Mais les fusions ont tjrs 4 hidden abilities
    #2. l'autre ability du poke 1
    #3. l'autre ability du poke 2
    #4. hidden du poke 1
    #5. hidden du poke2
    
    
    abID1 = hidden1 ? abilityList[0][4]  : abilityList[0][0]   
    abID2 = hidden2 ? abilityList[0][5]  : abilityList[0][1]

   if (Kernel.pbMessage("Choose an ability.",[_INTL("{1}",PBAbilities.getName(abID1)),_INTL("{1}",PBAbilities.getName(abID2))],2))==0
     return hidden1 ? 4 : 0
   end
   return hidden2 ? 5 : 1
end


#pas au point. renvoie tjrs la mm nature
def pbChooseNature(species1,species2)
  nature1 = PBNatures.getName(species1)
  nature2 = PBNatures.getName(species2)
   if (Kernel.pbMessage("Choose a nature.",[_INTL("{1}",nature1),_INTL("{1}",nature2)],2))==0
     return PBNatures.getNum(nature1)
   else
     return PBNatures.getNum(nature2)
   end  
end  

#edit pour ajouter le bypass
def pbMiniCheckEvolution(pokemon,evonib,level,poke,bypass=false)
  return poke if bypass
  case evonib
    when PBEvolution::Happiness
      return poke if pokemon.happiness>=220
    when PBEvolution::HappinessDay
      return poke if pokemon.happiness>=220 && PBDayNight.isDay?(pbGetTimeNow)
    when PBEvolution::HappinessNight
      return poke if pokemon.happiness>=220 && PBDayNight.isNight?(pbGetTimeNow)
    when PBEvolution::Level
      return poke if pokemon.level >= level || checkEarlyEvolution(level,pokemon)
    when PBEvolution::Trade, PBEvolution::TradeItem
      return -1
    when PBEvolution::AttackGreater # Hitmonlee
      return poke if pokemon.level>=level && pokemon.attack>pokemon.defense
    when PBEvolution::AtkDefEqual # Hitmontop
      return poke if pokemon.level>=level && pokemon.attack==pokemon.defense
    when PBEvolution::DefenseGreater # Hitmonchan
      return poke if pokemon.level>=level && pokemon.attack<pokemon.defense
    when PBEvolution::Silcoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)<5
    when PBEvolution::Cascoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)>=5
    when PBEvolution::Ninjask
      return poke if pokemon.level>=level
    when PBEvolution::Shedinja
      return -1
    when PBEvolution::Beauty # Feebas
      return poke if pokemon.beauty>=level
    when PBEvolution::DayHoldItem
      return poke if pokemon.item==level && PBDayNight.isDay?(pbGetTimeNow)
    when PBEvolution::NightHoldItem
      return poke if pokemon.item==level && PBDayNight.isNight?(pbGetTimeNow)
    when PBEvolution::HasMove
      for i in 0...4
        return poke if pokemon.moves[i].id==level
      end
    when PBEvolution::HasInParty
      for i in $Trainer.party
        return poke if !i.isEgg? && i.species==level
      end
    when PBEvolution::LevelMale
      return poke if pokemon.level>=level && pokemon.isMale?
    when PBEvolution::LevelFemale
      return poke if pokemon.level>=level && pokemon.isFemale?
    when PBEvolution::Location
      return poke if $game_map.map_id==level
    when PBEvolution::TradeSpecies
      return -1
    when PBEvolution::Custom1
      # Add code for custom evolution type 1
    when PBEvolution::Custom2
      # Add code for custom evolution type 2
    when PBEvolution::Custom3
      # Add code for custom evolution type 3
    when PBEvolution::Custom4
      # Add code for custom evolution type 4
    when PBEvolution::Custom5
      # Add code for custom evolution type 5
    when PBEvolution::Custom6
      # Add code for custom evolution type 6
    when PBEvolution::Custom7
      # Add code for custom evolution type 7
  end
  return -1
end

def pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
  # Checks for when an item is used on the Pokémon (e.g. an evolution stone)
  case evonib
    when PBEvolution::Item
      return poke if level==item
    when PBEvolution::ItemMale
      return poke if level==item && pokemon.isMale?
    when PBEvolution::ItemFemale
      return poke if level==item && pokemon.isFemale?
  end
  return -1
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
#  Pokemon to check; evolution type; level or other parameter; ID of the new Pokemon species
def pbCheckEvolutionEx(pokemon,noRestr=false)
  if !noRestr
    return -1 if pokemon.species<=0 || pokemon.isEgg?
    return -1 if isConst?(pokemon.species,PBSpecies,:PICHU) && pokemon.form==1
    return -1 if isConst?(pokemon.item,PBItems,:EVERSTONE) || isConst?(pokemon.item,PBItems,:EVIOLITE)
  end
  ret=-1
  for form in pbGetEvolvedFormData(pokemon.species)
    ret=yield pokemon,form[0],form[1],form[2]
    break if ret>0
  end
  
  #EDITED FOR GEN2
  return -1 if pokemon.species >= ZAPMOLCUNO_NB
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species,false)
    
    ret1=-1
    ret2=-1
    
    for form in pbGetEvolvedFormData(body)
      retB=yield pokemon,form[0],form[1],form[2]
      break if retB>0
    end
    for form in pbGetEvolvedFormData(head)
      retH=yield pokemon,form[0],form[1],form[2]
      break if retH>0
    end
    
    return ret if ret == retB && ret == retH
    return  fixEvolutionOverflow(retB,retH,pokemon.species)
  end
  
  return ret
end





#EDITED FOR GEN2
def fixEvolutionOverflow(retB,retH,oldSpecies)
  #raise Exception.new("retB: " + retB.to_s + " retH: " + retH.to_s)

    oldBody = getBasePokemonID(oldSpecies)
    oldHead = getBasePokemonID(oldSpecies,false)
    return -1 if isNegativeOrNull(retB) && isNegativeOrNull(retH)
    return oldBody*NB_POKEMON+retH if isNegativeOrNull(retB)   #only head evolves
    return retB*NB_POKEMON + oldHead if isNegativeOrNull(retH)  #only body evolves
    return retB*NB_POKEMON+retH                   #both evolve
end

def isNegativeOrNull(value)
  return value == -1 || value == nil
end


# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pokemon,item=0)
  if item==0
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolution(pokemon,evonib,level,poke)
    }
  else
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
    }
  end
end


def pbFusionFail
  metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
    metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
    metaplayer3=SpriteMetafilePlayer.new(@metafile3,@sprites["rsprite3"])
    
    
    metaplayer1.play
    metaplayer2.play
    metaplayer3.play
    
    pbBGMStop()
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
    _INTL("The Pokémon are being fused!",@pokemon1.name))

   
   
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
    pbPlayDecisionSE()
    oldstate=pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
    oldstate3=pbSaveSpriteState(@sprites["rsprite3"])
    
    pbBGMPlay("fusion")
    canceled=false
    begin
      metaplayer1.update
      metaplayer2.update
      metaplayer3.update
      
      Graphics.update
      Input.update
    
    end while metaplayer1.playing? && metaplayer2.playing?

      pbBGMStop()
      pbPlayCancelSE()
      
        pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
        pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
        pbRestoreSpriteState(@sprites["rsprite3"],oldstate3)        
        Graphics.update       
      
     # frames.times do
    #    Graphics.update

      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("Uh? The fusion has failed!"))
             Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
            pbPlayDecisionSE()
        

       
    #  end
    end



def fusionCheckSuccess (catchrate, levdif, level, multiplier)
  return false
end





####################################################
############################
###  PokemonTime
########################################

################################################################################
# * Day and night system
################################################################################
def pbGetTimeNow
  return Time.now
end



module PBDayNight
HourlyTones=[
     Tone.new(-80,     -75,     -20,    45),     #0
     Tone.new(-80,     -75,     -20,    45),      #1
     Tone.new(-80,     -75,     -20,    45),      #2
     Tone.new(-80,     -75,     -20,    45),      #3
     Tone.new(-35,     -35,     -20,    10),      #4
     Tone.new(-5,     -20,     -15,    50),       # 5
     Tone.new(-10,     -15,     -20,    0),       # 6
     Tone.new(-10,     -5,     0,    0),       # 7
     Tone.new(5,     -5,     -10,    0),       # 8
     Tone.new(0,     0,     0,    0),       # 9
     Tone.new(0,     0,     0,    0),       # 10
     Tone.new(0,     0,     0,    0),       # 11
     Tone.new(5,     5,     5,    0),       # Noon
     Tone.new(5,     5,     0,    0),       # 13
     Tone.new(0,     0,     0,    0),       # 14
     Tone.new(0,     0,     0,    0),       # 15
     Tone.new(0,     0,     0,    0),       # 15

     Tone.new(5,     -5,     -5,    0),       # 16
     Tone.new(10,     5,     -5,    0),       # 17
     Tone.new(-6,     -12,     -3,    0),       # 18
     Tone.new(-8,     -25,     -23,    0),       # 19
     Tone.new(-48,     -80,     -23,    0),       # 20
     Tone.new(-80,     -75,     -20,    45),       # 21
     Tone.new(-80,     -75,     -20,    45),   # 22
  ]  
    
  
  @cachedTone=nil
  @dayNightToneLastUpdate=nil

# Returns true if it's day.
  def self.isDay?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=6 && time.hour<20)
  end

# Returns true if it's night.
  def self.isNight?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=20 || time.hour<6)
  end

# Returns true if it's morning.
  def self.isMorning?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=5 && time.hour<10)
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=12 && time.hour<17)
  end


# Returns true if it's the evening.
  def self.isEvening?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=17 && time.hour<20)
  end

# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time=pbGetDayNightMinutes
    time=(24*60)-time if time>(12*60)
    shade=255*time/(12*60)
  end

# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone()
    return Tone.new(0,0,0) if !ENABLESHADING
    if !@cachedTone
      @cachedTone=Tone.new(0,0,0)
    end
    if !@dayNightToneLastUpdate || @dayNightToneLastUpdate!=Graphics.frame_count       
      @cachedTone=getToneInternal()
      @dayNightToneLastUpdate=Graphics.frame_count
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now=pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal()
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes=pbGetDayNightMinutes
    hour=realMinutes/60
    minute=realMinutes%60
    tone=PBDayNight::HourlyTones[hour]
    nexthourtone=PBDayNight::HourlyTones[(hour+1)%24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    return Tone.new(
       ((nexthourtone.red-tone.red)*minute/60.0)+tone.red,
       ((nexthourtone.green-tone.green)*minute/60.0)+tone.green,
       ((nexthourtone.blue-tone.blue)*minute/60.0)+tone.blue,
       ((nexthourtone.gray-tone.gray)*minute/60.0)+tone.gray
    )
  end
end



def pbDayNightTint(object)
  if !$scene.is_a?(Scene_Map)
    return
  else
    if ENABLESHADING && $game_map && pbGetMetadata($game_map.map_id,MetadataOutdoor)
      tone=PBDayNight.getTone()
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    else
      object.tone.set(0,0,0,0)  
    end
  end  
end



################################################################################
# * Zodiac and day/month checks
################################################################################
# Calculates the phase of the moon.
# 0 - New Moon
# 1 - Waxing Crescent
# 2 - First Quarter
# 3 - Waxing Gibbous
# 4 - Full Moon
# 5 - Waning Gibbous
# 6 - Last Quarter
# 7 - Waning Crescent
def moonphase(time) # in UTC
  transitions=[
     1.8456618033125,
     5.5369854099375,
     9.2283090165625,
     12.9196326231875,
     16.6109562298125,
     20.3022798364375,
     23.9936034430625,
     27.6849270496875]
  yy=time.year-((12-time.mon)/10.0).floor
  j=(365.25*(4712+yy)).floor + (((time.mon+9)%12)*30.6+0.5).floor + time.day+59
  j-=(((yy/100.0)+49).floor*0.75).floor-38 if j>2299160
  j+=(((time.hour*60)+time.min*60)+time.sec)/86400.0
  v=(j-2451550.1)/29.530588853
  v=((v-v.floor)+(v<0 ? 1 : 0))
  ag=v*29.53
  for i in 0...transitions.length
    return i if ag<=transitions[i]
  end
  return 0
end

# Calculates the zodiac sign based on the given month and day:
# 0 is Aries, 11 is Pisces. Month is 1 if January, and so on.
def zodiac(month,day)
  time=[
     3,21,4,19,   # Aries
     4,20,5,20,   # Taurus
     5,21,6,20,   # Gemini
     6,21,7,20,   # Cancer
     7,23,8,22,   # Leo
     8,23,9,22,   # Virgo 
     9,23,10,22,  # Libra
     10,23,11,21, # Scorpio
     11,22,12,21, # Sagittarius
     12,22,1,19,  # Capricorn
     1,20,2,18,   # Aquarius
     2,19,3,20    # Pisces
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+2]
  end
  return 0
end
 
# Returns the opposite of the given zodiac sign.
# 0 is Aries, 11 is Pisces.
def zodiacOpposite(sign)
  return (sign+6)%12
end

# 0 is Aries, 11 is Pisces.
def zodiacPartners(sign)
  return [(sign+4)%12,(sign+8)%12]
end

# 0 is Aries, 11 is Pisces.
def zodiacComplements(sign)
  return [(sign+1)%12,(sign+11)%12]
end

def pbIsWeekday(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.wday
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")
    ][wday] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsMonth(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.mon
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("January"),
       _INTL("February"),
       _INTL("March"),
       _INTL("April"),
       _INTL("May"),
       _INTL("June"),
       _INTL("July"),
       _INTL("August"),
       _INTL("September"),
       _INTL("October"),
       _INTL("November"),
       _INTL("December")
    ][wday-1] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbGetAbbrevMonthName(month)
  return [_INTL(""),
          _INTL("Jan."),
          _INTL("Feb."),
          _INTL("Mar."),
          _INTL("Apr."),
          _INTL("May"),
          _INTL("Jun."),
          _INTL("Jul."),
          _INTL("Aug."),
          _INTL("Sep."),
          _INTL("Oct."),
          _INTL("Nov."),
          _INTL("Dec.")][month]
end