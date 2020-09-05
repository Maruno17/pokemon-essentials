module PBRibbons
  HOENNCOOL          = 1
  HOENNCOOLSUPER     = 2
  HOENNCOOLHYPER     = 3
  HOENNCOOLMASTER    = 4
  HOENNBEAUTY        = 5
  HOENNBEAUTYSUPER   = 6
  HOENNBEAUTYHYPER   = 7
  HOENNBEAUTYMASTER  = 8
  HOENNCUTE          = 9
  HOENNCUTESUPER     = 10
  HOENNCUTEHYPER     = 11
  HOENNCUTEMASTER    = 12
  HOENNSMART         = 13
  HOENNSMARTSUPER    = 14
  HOENNSMARTHYPER    = 15
  HOENNSMARTMASTER   = 16
  HOENNTOUGH         = 17
  HOENNTOUGHSUPER    = 18
  HOENNTOUGHHYPER    = 19
  HOENNTOUGHMASTER   = 20
  SINNOHCOOL         = 21
  SINNOHCOOLSUPER    = 22
  SINNOHCOOLHYPER    = 23
  SINNOHCOOLMASTER   = 24
  SINNOHBEAUTY       = 25
  SINNOHBEAUTYSUPER  = 26
  SINNOHBEAUTYHYPER  = 27
  SINNOHBEAUTYMASTER = 28
  SINNOHCUTE         = 29
  SINNOHCUTESUPER    = 30
  SINNOHCUTEHYPER    = 31
  SINNOHCUTEMASTER   = 32
  SINNOHSMART        = 33
  SINNOHSMARTSUPER   = 34
  SINNOHSMARTHYPER   = 35
  SINNOHSMARTMASTER  = 36
  SINNOHTOUGH        = 37
  SINNOHTOUGHSUPER   = 38
  SINNOHTOUGHHYPER   = 39
  SINNOHTOUGHMASTER  = 40
  WINNING            = 41
  VICTORY            = 42
  ABILITY            = 43
  GREATABILITY       = 44
  DOUBLEABILITY      = 45
  MULTIABILITY       = 46
  PAIRABILITY        = 47
  WORLDABILITY       = 48
  CHAMPION           = 49
  SINNOHCHAMP        = 50
  RECORD             = 51
  EVENT              = 52
  LEGEND             = 53
  GORGEOUS           = 54
  ROYAL              = 55
  GORGEOUSROYAL      = 56
  ALERT              = 57
  SHOCK              = 58
  DOWNCAST           = 59
  CARELESS           = 60
  RELAX              = 61
  SNOOZE             = 62
  SMILE              = 63
  FOOTPRINT          = 64
  ARTIST             = 65
  EFFORT             = 66
  BIRTHDAY           = 67
  SPECIAL            = 68
  CLASSIC            = 69
  PREMIER            = 70
  SOUVENIR           = 71
  WISHING            = 72
  NATIONAL           = 73
  COUNTRY            = 74
  BATTLECHAMPION     = 75
  REGIONALCHAMPION   = 76
  EARTH              = 77
  WORLD              = 78
  NATIONALCHAMPION   = 79
  WORLDCHAMPION      = 80

  def self.maxValue; 80; end
  def self.getCount; 80; end

  def self.getName(id)
    id = getID(PBRibbons,id)
    names = ["",
       _INTL("Cool Ribbon"),
       _INTL("Cool Ribbon Super"),
       _INTL("Cool Ribbon Hyper"),
       _INTL("Cool Ribbon Master"),
       _INTL("Beauty Ribbon"),
       _INTL("Beauty Ribbon Super"),
       _INTL("Beauty Ribbon Hyper"),
       _INTL("Beauty Ribbon Master"),
       _INTL("Cute Ribbon"),
       _INTL("Cute Ribbon Super"),
       _INTL("Cute Ribbon Hyper"),
       _INTL("Cute Ribbon Master"),
       _INTL("Smart Ribbon"),
       _INTL("Smart Ribbon Super"),
       _INTL("Smart Ribbon Hyper"),
       _INTL("Smart Ribbon Master"),
       _INTL("Tough Ribbon"),
       _INTL("Tough Ribbon Super"),
       _INTL("Tough Ribbon Hyper"),
       _INTL("Tough Ribbon Master"),
       _INTL("Cool Ribbon"),
       _INTL("Cool Ribbon Great"),
       _INTL("Cool Ribbon Ultra"),
       _INTL("Cool Ribbon Master"),
       _INTL("Beauty Ribbon"),
       _INTL("Beauty Ribbon Great"),
       _INTL("Beauty Ribbon Ultra"),
       _INTL("Beauty Ribbon Master"),
       _INTL("Cute Ribbon"),
       _INTL("Cute Ribbon Great"),
       _INTL("Cute Ribbon Ultra"),
       _INTL("Cute Ribbon Master"),
       _INTL("Smart Ribbon"),
       _INTL("Smart Ribbon Great"),
       _INTL("Smart Ribbon Ultra"),
       _INTL("Smart Ribbon Master"),
       _INTL("Tough Ribbon"),
       _INTL("Tough Ribbon Great"),
       _INTL("Tough Ribbon Ultra"),
       _INTL("Tough Ribbon Master"),
       _INTL("Winning Ribbon"),
       _INTL("Victory Ribbon"),
       _INTL("Ability Ribbon"),
       _INTL("Great Ability Ribbon"),
       _INTL("Double Ability Ribbon"),
       _INTL("Multi Ability Ribbon"),
       _INTL("Pair Ability Ribbon"),
       _INTL("World Ability Ribbon"),
       _INTL("Champion Ribbon"),
       _INTL("Sinnoh Champ Ribbon"),
       _INTL("Record Ribbon"),
       _INTL("Event Ribbon"),
       _INTL("Legend Ribbon"),
       _INTL("Gorgeous Ribbon"),
       _INTL("Royal Ribbon"),
       _INTL("Gorgeous Royal Ribbon"),
       _INTL("Alert Ribbon"),
       _INTL("Shock Ribbon"),
       _INTL("Downcast Ribbon"),
       _INTL("Careless Ribbon"),
       _INTL("Relax Ribbon"),
       _INTL("Snooze Ribbon"),
       _INTL("Smile Ribbon"),
       _INTL("Footprint Ribbon"),
       _INTL("Artist Ribbon"),
       _INTL("Effort Ribbon"),
       _INTL("Birthday Ribbon"),
       _INTL("Special Ribbon"),
       _INTL("Classic Ribbon"),
       _INTL("Premier Ribbon"),
       _INTL("Souvenir Ribbon"),
       _INTL("Wishing Ribbon"),
       _INTL("National Ribbon"),
       _INTL("Country Ribbon"),
       _INTL("Battle Champion Ribbon"),
       _INTL("Regional Champion Ribbon"),
       _INTL("Earth Ribbon"),
       _INTL("World Ribbon"),
       _INTL("National Champion Ribbon"),
       _INTL("World Champion Ribbon")
    ]
    return names[id]
  end

  def self.getDescription(id)
    id = getID(PBRibbons,id)
    desc = ["",
       _INTL("Hoenn Cool Contest Normal Rank winner!"),
       _INTL("Hoenn Cool Contest Super Rank winner!"),
       _INTL("Hoenn Cool Contest Hyper Rank winner!"),
       _INTL("Hoenn Cool Contest Master Rank winner!"),
       _INTL("Hoenn Beauty Contest Normal Rank winner!"),
       _INTL("Hoenn Beauty Contest Super Rank winner!"),
       _INTL("Hoenn Beauty Contest Hyper Rank winner!"),
       _INTL("Hoenn Beauty Contest Master Rank winner!"),
       _INTL("Hoenn Cute Contest Normal Rank winner!"),
       _INTL("Hoenn Cute Contest Super Rank winner!"),
       _INTL("Hoenn Cute Contest Hyper Rank winner!"),
       _INTL("Hoenn Cute Contest Master Rank winner!"),
       _INTL("Hoenn Smart Contest Normal Rank winner!"),
       _INTL("Hoenn Smart Contest Super Rank winner!"),
       _INTL("Hoenn Smart Contest Hyper Rank winner!"),
       _INTL("Hoenn Smart Contest Master Rank winner!"),
       _INTL("Hoenn Tough Contest Normal Rank winner!"),
       _INTL("Hoenn Tough Contest Super Rank winner!"),
       _INTL("Hoenn Tough Contest Hyper Rank winner!"),
       _INTL("Hoenn Tough Contest Master Rank winner!"),
       _INTL("Super Contest Cool Category Normal Rank winner!"),
       _INTL("Super Contest Cool Category Great Rank winner!"),
       _INTL("Super Contest Cool Category Ultra Rank winner!"),
       _INTL("Super Contest Cool Category Master Rank winner!"),
       _INTL("Super Contest Beauty Category Normal Rank winner!"),
       _INTL("Super Contest Beauty Category Great Rank winner!"),
       _INTL("Super Contest Beauty Category Ultra Rank winner!"),
       _INTL("Super Contest Beauty Category Master Rank winner!"),
       _INTL("Super Contest Cute Category Normal Rank winner!"),
       _INTL("Super Contest Cute Category Great Rank winner!"),
       _INTL("Super Contest Cute Category Ultra Rank winner!"),
       _INTL("Super Contest Cute Category Master Rank winner!"),
       _INTL("Super Contest Smart Category Normal Rank winner!"),
       _INTL("Super Contest Smart Category Great Rank winner!"),
       _INTL("Super Contest Smart Category Ultra Rank winner!"),
       _INTL("Super Contest Smart Category Master Rank winner!"),
       _INTL("Super Contest Tough Category Normal Rank winner!"),
       _INTL("Super Contest Tough Category Great Rank winner!"),
       _INTL("Super Contest Tough Category Ultra Rank winner!"),
       _INTL("Super Contest Tough Category Master Rank winner!"),
       _INTL("Ribbon awarded for clearing Hoenn's Battle Tower's Lv. 50 challenge."),
       _INTL("Ribbon awarded for clearing Hoenn's Battle Tower's Lv. 100 challenge."),
       _INTL("A Ribbon awarded for defeating the Tower Tycoon at the Battle Tower."),
       _INTL("A Ribbon awarded for defeating the Tower Tycoon at the Battle Tower."),
       _INTL("A Ribbon awarded for completing the Battle Tower Double challenge."),
       _INTL("A Ribbon awarded for completing the Battle Tower Multi challenge."),
       _INTL("A Ribbon awarded for completing the Battle Tower Link Multi challenge."),
       _INTL("A Ribbon awarded for completing the Wi-Fi Battle Tower challenge."),
       _INTL("Ribbon for clearing the Pokémon League and entering the Hall of Fame in another region. "),
       _INTL("Ribbon awarded for beating the Sinnoh Champion and entering the Hall of Fame."),
       _INTL("A Ribbon awarded for setting an incredible record."),
       _INTL("Pokémon Event Participation Ribbon."),
       _INTL("A Ribbon awarded for setting a legendary record."),
       _INTL("An extraordinarily gorgeous and extravagant Ribbon."),
       _INTL("An incredibly regal Ribbon with an air of nobility."),
       _INTL("A gorgeous and regal Ribbon that is the peak of fabulous."),
       _INTL("A Ribbon for recalling an invigorating event that created life energy."),
       _INTL("A Ribbon for recalling a thrilling event that made life more exciting."),
       _INTL("A Ribbon for recalling feelings of sadness that added spice to life."),
       _INTL("A Ribbon for recalling a careless error that helped steer life decisions."),
       _INTL("A Ribbon for recalling a refreshing event that added sparkle to life."),
       _INTL("A Ribbon for recalling a deep slumber that made life soothing."),
       _INTL("A Ribbon for recalling that smiles enrich the quality of life."),
       _INTL("A Ribbon awarded to a Pokémon deemed to have a top-quality footprint."),
       _INTL("Ribbon awarded for being chosen as a super sketch model in Hoenn."),
       _INTL("Ribbon awarded for being an exceptionally hard worker."),
       _INTL("A Ribbon to celebrate a birthday."),
       _INTL("A special Ribbon for a special day."),
       _INTL("A Ribbon that proclaims love for Pokémon."),
       _INTL("Special Holiday Ribbon."),
       _INTL("A Ribbon to cherish a special memory."),
       _INTL("A Ribbon said to make your wish come true."),
       _INTL("A Ribbon awarded for overcoming all difficult challenges."),
       _INTL("Pokémon League Champion Ribbon."),
       _INTL("Battle Competition Champion Ribbon."),
       _INTL("Pokémon World Championships Regional Champion Ribbon."),
       _INTL("A Ribbon awarded for winning 100 matches in a row."),
       _INTL("Pokémon League Champion Ribbon."),
       _INTL("Pokémon World Championships National Champion Ribbon."),
       _INTL("Pokémon World Championships World Champion Ribbon.")
    ]
    return desc[id]
  end
end
