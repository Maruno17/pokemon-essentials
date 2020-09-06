# Credit to Jonas930
# Ex: pbMrHyper(:STARDUST,:STARPIECE)
def pbMrHyper(item1,item2)
  item1=getConst(PBItems,item1)
  item2=getConst(PBItems,item2)
  @nameitem1=PBItems.getName(item1)
  @nameitem2=PBItems.getName(item2)
  @hasitem1=$PokemonBag.pbHasItem?(item1)
  @hasitem2=$PokemonBag.pbHasItem?(item2)
  Kernel.pbMessage(_INTL("The name's Mr. Hyper!\nI can help Pokémon do Hyper Training!"))
  if Kernel.pbConfirmMessage(_INTL("Want to try some of my Hyper Training to boost your Pokémon's stats?"))
    if @hasitem1 || @hasitem2
      item = 0 if @hasitem1 && !@hasitem2
      item = 1 if !@hasitem1 && @hasitem2
      item = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),[@nameitem1,@nameitem2]) if @hasitem1 && @hasitem2
      itemuse = (item == 0 ? @nameitem1 : @nameitem2)
      Kernel.pbMessage(_INTL("Which one of your Pokémon do you want to do some Hyper Training on?"))
      pbChoosePokemon(1,2)
      cancel = pbGet(1)
      pokemon = $Trainer.pokemonParty[pbGet(1)]
      if cancel < 0
      elsif $Trainer.party[pbGet(1)].egg?
        Kernel.pbMessage(_INTL("An Egg?! I understand why you're hyped to have one, but I can't train that thing yet!"))
      elsif pokemon.level<100
        Kernel.pbMessage(_INTL("Oh no... No, no, no! That Pokémon hasn't leveled up enough to be ready for my amazing Hyper Training! Only Lv. 100 Pokémon can handle the hype!"))
      else
        if Kernel.pbConfirmMessage(_INTL("Are you gonna use one {1} for Hyper Training?",itemuse))
          if item==0
            stat = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),
            [_INTL("HP"),_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Sp. Atk"),_INTL("Sp. Def")])
            if pokemon.iv[stat]==31
              Kernel.pbMessage(_INTL("But that Pokémon is already so awesome that it doesn't need any training!"))
            else
              pokemon.iv[stat]=31
              itemuse = (item == 0 ? item1 : item2)
              $PokemonBag.pbDeleteItem(itemuse)
              Kernel.pbMessage(_INTL("Then get hype! Because I'm about to do some real Hyper Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("All right! {1} got even stronger thanks to my Hyper Training!",pokemon.name))
            end
          elsif item==1
            if (pokemon.iv[0]==31 && pokemon.iv[1]==31 && pokemon.iv[2]==31 && pokemon.iv[3]==31 && pokemon.iv[4]==31 && pokemon.iv[5]==31)
              Kernel.pbMessage(_INTL("But that Pokémon is already so awesome that it doesn't need any training!"))
            else
              for i in 0..5
                pokemon.iv[i]=31
              end
              itemuse = (item == 0 ? item1 : item2)
              $PokemonBag.pbDeleteItem(itemuse)
              Kernel.pbMessage(_INTL("Then get hype! Because I'm about to do some real Hyper Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("All right! {1} got even stronger thanks to my Hyper Training!",pokemon.name))
            end
          end
        end
      end
    else
      Kernel.pbMessage(_INTL("Oh no... No, no, no! You don't have any {1} or {2}! Not even one!",@nameitem1,@nameitem2))
    end
  end
  Kernel.pbMessage(_INTL("Then come back anytime! Mr. Hyper will always be hyped up to see you!"))
end