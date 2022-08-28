def pbSpecialTutor(pokemon)
  retval = true
  tutorUtil = FusionTutorService.new(pokemon)
  pbFadeOutIn {
    scene = MoveRelearner_Scene.new
    scene.set_moves(tutorUtil.getCompatibleMove)

    screen = MoveRelearnerScreen.new(scene)
    retval = screen.pbStartScreen(pkmn)
  }
  return retval
end

class FusionTutorService

  def initialize(pokemon)
    @pokemon = pokemon
  end

  def getCompatibleMoves(pokemon)
    compatibleMoves = []
    #normal moves
    compatibleMoves << :ATTACKORDER if is_fusion_of([:BEEDRILL])
    compatibleMoves << :FIRSTIMPRESSION if is_fusion_of([:SCYTHER, :SCIZOR, :PINSIR, :FARFETCHD, :TRAPINCH, :VIBRAVA, :FLYGON, :KABUTOPS, :ARMALDO])
    compatibleMoves << :POLLENPUFF if is_fusion_of([:BUTTERFREE, :CELEBI, :VILEPLUME, :PARASECT, :BRELOOM])
    compatibleMoves << :LUNGE if is_fusion_of([:SPINARAK, :ARIADOS, :JOLTIK, :GALVANTULA, :VENOMOTH, :VOLCARONA, :PINSIR, :PARASECT, :LEDIAN, :DODUO, :DODRIO, :STANTLER])
    compatibleMoves << :DEFENDORDER if is_fusion_of([:BEEDRILL])
    compatibleMoves << :HEALORDER if is_fusion_of([:BEEDRILL])
    compatibleMoves << :POWDER if is_fusion_of([:BUTTERFREE, :VENOMOTH, :VOLCARONA, :PARASECT, :BRELOOM])
    compatibleMoves << :TAILGLOW if is_fusion_of([:MAREEP, :FLAFFY, :AMPHAROS, :LANTURN, :ZEKROM, :RESHIRAM])
    compatibleMoves << :DARKESTLARIAT if is_fusion_of([:SNORLAX, :REGIGIGAS, :POLIWRATH, :MACHAMP, :ELECTIVIRE, :DUSKNOIR, :SWAMPERT, :KROOKODILE, :GOLURK])
    compatibleMoves << :PARTINGSHOT if is_fusion_of([:MEOWTH, :PERSIAN, :SANDILE, :KROKOROK, :KROOKODILE, :UMBREON])
    compatibleMoves << :TOPSYTURVY if is_fusion_of([:HITMONTOP, :WOBBUFFET])
    compatibleMoves << :CLANGINGSCALES if is_fusion_of([:EKANS, :ARBOK, :GARCHOMP, :FLYGON, :HAXORUS])

    compatibleMoves << :ZINGZAP if is_fusion_of([:PICHU, :PIKACHU, :RAICHU, :VOLTORB, :ELECTRODE]) || (is_fusion_of([:SANDSLASH, :GOLEM]) && hasType(:ELECTRIC))
    compatibleMoves << :PARABOLICCHARGE if is_fusion_of([:PICHU, :PIKACHU, :RAICHU, :MAGNEMITE, :MAGNETON, :MAGNEZONE, :MAREEP, :FLAAFY, :AMPHAROS, :ELEKID, :ELECTABUZZ, :ELECTIVIRE, :ZAPDOS,
                                                         :CHINCHOU, :LANTERN, :RAIKOU, :KLINK, :KLANK, :KLINKLANG, :ROTOM, :STUNFISK])

    compatibleMoves << :ELECTRIFY if is_fusion_of([:KLINK, :KLANK, :KLINKLANG]) || hasType(:ELECTRIC)
    compatibleMoves << :AROMATICMIST if is_fusion_of([:WEEZING, :BULBASAUR, :IVYSAUR, :VENUSAUR, :CHIKORITA, :BAYLEEF, :MEGANIUM, :GLOOM, :VILEPLUME, :BELLOSSOM, :ROSELIA, :ROSERADE])
    compatibleMoves << :FLORALHEALING if is_fusion_of([:SUNFLORA, :BELLOSSOM, :ROSELIA, :ROSERADE])
    compatibleMoves << :FLYINGPRESS if is_fusion_of([:TORCHIC, :COMBUSKEN, :BLAZIKEN, :FARFETCHD, :HERACROSS]) || (hasType(:FLYING) && hasType(:FIGHTING))
    compatibleMoves << :SECRETSWORD if is_fusion_of([:HONEDGE, :DOUBLADE, :AEGISLASH, :GALLADE, :FARFETCHD, :ABSOL, :BISHARP])
    compatibleMoves << :MATBLOCK if is_fusion_of([:MACHOP, :MACHOKE, :MACHAMP, :TYROGUE, :HITMONLEE, :HITMONCHAMP, :HITMONTOP])
    compatibleMoves << :MINDBLOWN if is_fusion_of([:VOLTORB, :ELECTRODE, :EXEGGUTOR])
    compatibleMoves << :SHELLTRAP if is_fusion_of([:MAGCARGO, :FORRETRESS])
    compatibleMoves << :HEATCRASH if is_fusion_of([:BLAZIKEN, :RESHIRAM, :GROUDON, :CHARIZARD, :GOLURK, :REGIGIGAS, :RHYDON, :RHYPERIOR, :SNORLAX])
    compatibleMoves << :SHADOWBONE if is_fusion_of([:MAROWAK]) && hasType(:GHOST)
    compatibleMoves << :SPIRITSHACKLE if is_fusion_of([:BANETTE, :SPIRITOMB, :DUSKNOIR, :SHEDINJA, :COFAGRIGUS])
    compatibleMoves << :TRICKORTREAT if (hasType(:GRASS) && hasType(:GHOST)) || is_fusion_of([:GASTLY, :HAUNTER, :GENGAR, :MIMIKYU, :ZORUA, :ZOROARK])
    compatibleMoves << :TROPKICK if is_fusion_of([:HITMONLEE, :HITMONTOP, :ROSERADE]) || (hasType(:GRASS) && hasType(:FIGHTING))
    compatibleMoves << :NEEDLEARM if is_fusion_of([:FERROTHORN])
    compatibleMoves << :FORESTSCURSE if (hasType(:GRASS) && hasType(:GHOST))
    compatibleMoves << :SPIKYSHIELD if is_fusion_of([:FERROSEED, :FERROTHORN]) || (is_fusion_of([:SANDSLASH, :JOLTEON, :CLOYSTER]) && hasType(:GRASS))
    compatibleMoves << :STRENGTHSAP if is_fusion_of([:ODDISH, :GLOOM, :VILEPLUME, :BELLOSSOM, :HOPPIP, :SKIPLOOM, :JUMPLUFF, :BELLSPROUT, :WEEPINBELL, :VICTREEBEL, :PARAS, :PARASECT, :DRIFTBLIM, :BRELOOM])
    compatibleMoves << :SHOREUP if is_fusion_of([:GRIMER, :MUK]) && hasType(:GROUND)
    compatibleMoves << :ICEHAMMER if (canLearnMove(:CRABHAMMER) || canLearnMove(:GRASSHAMMER)) && hasType(:ICE)
    compatibleMoves << :MULTIATTACK if is_fusion_of([:ARCEUS, :MEW, :GENESECT])
    compatibleMoves << :REVELATIONDANCE if is_fusion_of([:KECLEON, :BELLOSSOM, :CLEFAIRY, :CLEFABLE, :CLEFFA])
    compatibleMoves << :BANEFULBUNKER if is_fusion_of([:TENTACOOL, :TENTACRUEL, :NIDORINA, :NIDORINO, :NIDOQUEEN, :NIDOKING, :GRIMER, :MUK, :QWILFISH])
    compatibleMoves << :INSTRUCT if is_fusion_of([:CHIMCHAR, :MONFERNO, :INFERNAPE, :KADABRA, :ALAKAZAM, :SLOWKING])
    compatibleMoves << :PSYCHICTERRAIN if hasType(:PSYCHIC)
    compatibleMoves << :GRASSYTERRAIN if hasType(:GRASS)
    compatibleMoves << :MISTYTERRAIN if hasType(:FAIRY)
    compatibleMoves << :SPEEDSWAP if is_fusion_of([:PIKACHU, :RAICHU, :ABRA, :KADABRA, :ALAKAZAM, :PORYGON, :PORYGON2, :PORYGONZ, :MEWTWO, :MEW, :JOLTIK, :GALVANTULA])
    compatibleMoves << :ACCELEROCK if is_fusion_of([:AERODACTYL, :KABUTOPS, :ANORITH, :ARMALDO])
    compatibleMoves << :ANCHORSHOT if (is_fusion_of([:EMPOLEON, :STEELIX, :BELDUM, :METANG, :METAGROSS,:KLINK,:KLINKLANG,:KLANK,:ARON,:LAIRON,:AGGRON]) && hasType(:WATER)) || (is_fusion_of([:LAPRAS,:WAILORD,:KYOGRE]) && hasType(:STEEL))
    compatibleMoves << :SPARKLINGARIA if (is_fusion_of([:JYNX, :JIGGLYPUFF, :WIGGLYTUFF]) && hasType(:WATER)) || is_fusion_of(:LAPRAS)
    compatibleMoves << :WATERSHURIKEN if is_fusion_of([:NINJASK, :LUCARIO, :ZOROARK, :BISHARP]) && hasType(:WATER)

    #legendary moves (only available after a certain trigger, maybe a different npc)
    compatibleMoves << :HYPERSPACEFURY if is_fusion_of([:GIRATINA, :PALKIA, :DIALGA, :ARCEUS])
    compatibleMoves << :COREENFORCER if is_fusion_of([:GIRATINA, :PALKIA, :DIALGA, :RAYQUAZA])

    compatibleMoves << :PLASMAFISTS if is_fusion_of([:ELECTABUZZ, :ELECTIVIRE, :ZEKROM]) || (is_fusion_of([:ROTOM]) && canLearnMove(:THUNDERPUNCH))

    compatibleMoves << :LIGHTOFRUIN if is_fusion_of([:ARCEUS, :MEW, :CELEBI, :JIRACHI])
    compatibleMoves << :FLEURCANNON if is_fusion_of([:GARDEVOIR, :GALLADE, :SYLVEON, :WIGGLYTUFF])
    compatibleMoves << :NATURESMADNESS if is_fusion_of([:CELEBI, :KYOGRE, :GROUDON, :ABSOL])
    compatibleMoves << :GEOMANCY if is_fusion_of([:CELEBI])
    compatibleMoves << :VCREATE if is_fusion_of([:ENTEI, :HOOH, :TYPHLOSION])
    compatibleMoves << :MAGMASTORM if is_fusion_of([:MAGCARGO, :TYPHLOSION, :MAGMORTAR, :MAGMAR, :ENTEI, :GROUDON]) || canLearnMove(:ERUPTION)
    compatibleMoves << :SEARINGSHOT if is_fusion_of([:MAGMORTAR])
    compatibleMoves << :OBLIVIONWING if is_fusion_of([:MURKROW, :HONCHKROW]) || (hasType(:DARK) && hasType(:FLYING))
    compatibleMoves << :MOONGEISTBEAM if (is_fusion_of([:CLEFFA, :CLEFAIRY, :CLEFABLE]) && hasType(:DARK)) || is_fusion_of([:DARKRAI, :MISDREAVUS, :MISMAGIUS])
    compatibleMoves << :SPECTRALTHIEF if is_fusion_of([:HAUNTER, :GENGAR, :BANETTE, :GIRATINA, :HONEDGE, :DOUBLADE, :AEGISLASH])
    compatibleMoves << :SEEDFLARE if is_fusion_of([:JUMPLUFF, :SUNFLORA])
    compatibleMoves << :LANDSWRATH if is_fusion_of([:GROUDON])
    compatibleMoves << :THOUSANDARROWS if is_fusion_of([:SANDSLASH, :JOLTEON, :FERROTHORN] && hasType(:GROUND))
    compatibleMoves << :THOUSANDWAVES if is_fusion_of([:STUNFISK, :QUAGSIRE, :SWAMPERT])
    compatibleMoves << :FREEZESHOCK if is_fusion_of([:KYUREM, :ARTICUNO]) && hasType(:ELECTRIC)
    compatibleMoves << :ICEBURN if is_fusion_of([:KYUREM, :ARTICUNO]) && hasType(:FIRE)
    compatibleMoves << :RELICSONG if is_fusion_of([:JYNX, :LAPRAS, :JIGGLYPUFF, :WIGGLYTUFF, :MISDREAVUS, :MISMAGIUS])
    compatibleMoves << :HAPPYHOUR if is_fusion_of([:MEOWTH, :JIRACHI, :DELIBIRD, :MUNCHLAX, :SNORLAX, :PIKACHU, :RAICHU])
    compatibleMoves << :HOLDHANDS if is_fusion_of([:CHARMANDER, :BULBASAUR, :SQUIRTLE, :PIKACHU, :TOGEPI])
    compatibleMoves << :PRISMATICLASER if is_fusion_of([:LANTURN, :AMPHAROS, :HOOH, :DEOXYS, :MEWTWO, :MEW]) && hasType(:PSYCHIC)
    compatibleMoves << :PHOTONGEYSER if is_fusion_of([:LANTURN, :AMPHAROS, :HOOH, :MEW, :MEWTWO, :DEOXYS]) && hasType(:PSYCHIC)
    compatibleMoves << :LUNARDANCE if is_fusion_of([:CLEFAIRY, :CLEFABLE, :STARYU, :STARMIE])
    compatibleMoves << :DIAMONDSTORM if ((hasType(:FAIRY) && hasType(:ROCK)) || (hasType(:ROCK) && hasType(:STEEL))) || is_fusion_of([:DIALGA, :STEELIX])
    compatibleMoves << :SUNSTEELSTRIKE if is_fusion_of([:CHARIZARD, :VOLCARONA, :FLAREON, :NINETALES, :ENTEI, :HOOH, :RAPIDASH]) && hasType(:STEEL)
    compatibleMoves << :DOUBLEIRONBASH if canLearnMove(:DOUBLESLAP) && hasType(:STEEL)
    compatibleMoves << :STEAMERUPTION if canLearnMove(:ERUPTION) && hasType(:WATER)

  end

  def is_fusion_of(pokemonList)
    is_species = false
    for fusionPokemon in pokemonList
      @pokemon.isFusionOf(fusionPokemon)
    end
    return is_species
  end

  def hasType(type)
    return @pokemon.hasType?(type)
  end

  def canLearnMove(move)
    return @pokemon.compatible_with_move?(move)
  end

end



