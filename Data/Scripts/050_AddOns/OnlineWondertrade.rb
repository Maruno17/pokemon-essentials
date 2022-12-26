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
    else
      pbMessage("Could not find a trading partner...")
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

    is_head_shiny = receivedData["head_shiny"]
    is_body_shiny = receivedData["body_shiny"]
    is_debug_shiny = receivedData["debug_shiny"]

    newpoke = pbStartTrade(pbGet(1), receivedPokemonSpecies, receivedPokemonName, receivedPokemonTrainerName, receivedPokemonTrainerGender, true) # Starts the trade
    newpoke.owner=Pokemon::Owner.new(receivedPokemonTrainerId.to_i,receivedPokemonOT,2,2)
    newpoke.level=receivedPokemonLevel

    if is_head_shiny || is_body_shiny
      newpoke.shiny=true
      newpoke.head_shiny=is_head_shiny
      newpoke.body_shiny = is_body_shiny
      if is_debug_shiny
        newpoke.debug_shiny=false
        newpoke.natural_shiny=true
      else
        newpoke.debug_shiny=true
        newpoke.natural_shiny=false
      end
    end
    newpoke.calc_stats
  end

  def selectPokemonToGive
    pbChoosePokemon(1, 2, # Choose eligable pokemon
                    proc {
                      |poke| !poke.egg? &&
                        !(poke.isShadow?) &&
                        poke.isFusion? &&
                      customSpriteExists(poke.species) #&&
                      #  !poke.debug_shiny
                    })
    poke = $Trainer.party[pbGet(1)]

    if pbConfirmMessage(_INTL("Trade {1} away?", poke.name))
      return poke
    end
    return nil
  end


  # @param [Pokemon] givenPokemon
  def buildWondertradeQueryJson(givenPokemon)
    isDebugShiny = givenPokemon.debug_shiny || !givenPokemon.natural_shiny
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
      "body_shiny" => givenPokemon.body_shiny == nil ? false : givenPokemon.body_shiny,
      "head_shiny" => givenPokemon.head_shiny == nil ? false : givenPokemon.head_shiny,
      "debug_shiny" => isDebugShiny,
      "original_trainer_id" => givenPokemon.owner.id.to_s,

    }
    return HTTPLite::JSON.stringify(postData)
  end

end
