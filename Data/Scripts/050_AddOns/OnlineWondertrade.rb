class OnlineWondertrade



  def pbWonderTrade()
    givenPokemon = selectPokemonToGive
    return if givenPokemon == nil
    queryBody = buildWondertradeQueryJson(givenPokemon)
    begin
    response = HTTPLite.post_body(Settings::WONDERTRADE_BASE_URL + "/wondertrade", queryBody, "application/json")
    if response[:status] == 200
      body = HTTPLite::JSON.parse(response[:body])
      doTrade(body)
    end
    rescue MKXPError
      pbMessage("There was an error while sending your Pokémon...")
    end
  end

  def doTrade(receivedData)
    receivedPokemonSpecies = receivedData["pokemon_species"].to_sym
    receivedPokemonLevel = receivedData["level"].to_i
    receivedPokemonName = receivedData["nickname"]
    receivedPokemonOT = receivedData["original_trainer_name"]
    receivedPokemonTrainerId = receivedData["trainer_id"]
    receivedPokemonTrainerName = receivedData["trainer_name"]
    receivedPokemonTrainerGender = receivedData["trainer_gender"].to_i

    newpoke = pbStartTrade(pbGet(1), receivedPokemonSpecies, receivedPokemonName, receivedPokemonTrainerName, receivedPokemonTrainerGender, true) # Starts the trade
    newpoke.owner=Pokemon::Owner.new(receivedPokemonTrainerId.to_i,receivedPokemonOT,2,2)
    newpoke.level=receivedPokemonLevel
    newpoke.calc_stats
  end

  def selectPokemonToGive
    pbChoosePokemon(1, 2, # Choose eligable pokemon
                    proc {
                      |poke| !poke.egg? && !(poke.isShadow?)
                    })
    poke = $Trainer.party[pbGet(1)]

    if pbConfirmMessage(_INTL("Trade {1} away?", poke.name))
      return poke
    end
    return nil
  end


  # @param [Pokemon] givenPokemon
  def buildWondertradeQueryJson(givenPokemon)
    postData = {
      "trainer_name" => $Trainer.name,
      "trainer_gender" => $Trainer.gender,
      "trainer_id" => $Trainer.id.to_s,
      "nb_badges" => $Trainer.badge_count,
      "given_pokemon" => givenPokemon.species.to_s,
      "level" => givenPokemon.level,
      "nickname" => givenPokemon.name,
      "original_trainer_name" => givenPokemon.owner.name,
      "original_trainer_id" => givenPokemon.owner.id.to_s,
    }
    return HTTPLite::JSON.stringify(postData)
  end

end
