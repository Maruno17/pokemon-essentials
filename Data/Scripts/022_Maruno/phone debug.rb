#===============================================================================
#
#===============================================================================
MenuHandlers.add(:debug_menu, :add_phone_contacts, {
  "name"        => "Add Phone Contacts",
  "parent"      => :main,
  "description" => "Add 10 different contacts to the phone.",
  "effect"      => proc {
    Phone.add_silent(31, 6, :PICNICKER, "Susie", 2)
    Phone.add_silent(52, 1, :POKEMANIAC, "Peter", 2, nil, 1)
    Phone.add_silent(26, 1, :POKEMONBREEDER, "Bob", 2)
    Phone.add_silent(7, 1, :SCIENTIST, "Cedric", 2)
    Phone.add_silent(69, 1, :SWIMMER_F, "Ariel", 2)
    Phone.add_silent(5, 1, :BIRDKEEPER, "Sylvie", 2)
    Phone.add_silent(72, 1, :BLACKBELT, "Jackie", 2)
    Phone.add_silent(28, 1, :BUGCATCHER, "Tommy", 2)
    Phone.add_silent(31, 5, :CAMPER, "Jeff", 2)
    Phone.add_silent(49, 1, :HIKER, "Ford", 2)
    pbMessage("Done.")
  }
})
