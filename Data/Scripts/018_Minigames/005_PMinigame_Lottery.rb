################################################################################
# "Lottery" mini-game
# By Maruno
################################################################################
def pbSetLotteryNumber(variable=1)
  t = pbGetTimeNow
  hash = t.day + (t.month << 5) + (t.year << 9)
  srand(hash)                      # seed RNG with fixed value depending on date
  lottery = rand(65536)            # get a number
  srand                            # reseed RNG
  pbSet(variable,sprintf("%05d",lottery))
end

def pbLottery(winnum,nameVar=2,positionVar=3,matchedVar=4)
  winnum=winnum.to_i
  winpoke=nil
  winpos=0
  winmatched=0
  for i in $Trainer.party
    thismatched=0
    id=i.publicID
    for j in 0...5
      if (id/(10**j))%10 == (winnum/(10**j))%10
        thismatched+=1
      else
        break
      end
    end
    if thismatched>winmatched
      winpoke=i.name
      winpos=1 # Party
      winmatched=thismatched
    end
  end
  pbEachPokemon { |poke,_box|
    thismatched=0
    id=poke.publicID
    for j in 0...5
      if (id/(10**j))%10 == (winnum/(10**j))%10
        thismatched+=1
      else
        break
      end
    end
    if thismatched>winmatched
      winpoke=poke.name
      winpos=2 # Storage
      winmatched=thismatched
    end
  }
  $game_variables[nameVar]=winpoke
  $game_variables[positionVar]=winpos
  $game_variables[matchedVar]=winmatched
end
