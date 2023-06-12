#===============================================================================
#
#===============================================================================
MenuHandlers.add(:debug_menu, :test_random_dungeon, {
  "name"        => "Test Random Dungeon Generation",
  "parent"      => :main,
  "description" => "Generates a random dungeon and echoes it to the console.",
  "effect"      => proc {
#    $PokemonGlobal.dungeon_rng_seed = 12345
    tileset = :cave   # :forest   # :cave
    tileset_data = GameData::DungeonTileset.try_get((tileset == :forest) ? 23 : 7)
    params = GameData::DungeonParameters.try_get(tileset)
    dungeon = RandomDungeon::Dungeon.new(params.cell_count_x, params.cell_count_y, tileset_data, params)
    dungeon.generate
    echoln dungeon.rng_seed
    echoln dungeon.write
  }
})
