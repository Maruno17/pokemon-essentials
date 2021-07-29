

HIDDEN_MAPS_STEPS = 1500
HIDDEN_MAP_ALWAYS = [178,655,570,356]
RANDOM_HIDDEN_MAP_LIST =  [8,109,431,446,402,403,467,468,10,23,167,16,19,78,185,86,
                           491,90,40,342,490,102,103,104,105,106,1,12,413,445,484,485,486,140,350,146,
                           149,304,356,307,409,351,495,154,349,322,323,544,198,144,155,444,58,59,229,52,53,54,
                           55,98,173,174,181,187,95,159,162,437,220,440,438,57,171,172,528,265,288,364,329,
                           335,254,261,262,266,230,145,147,258,284,283,267,586,285,286,287,300,311,47,580,529,
                           635,638,646,560,559,526,600,564,594,566,562,619,563,603,561,597,633,640,641,621,312,
                           670,692,643,523,698,
                           602,642,623,569,588,573,362,645,651,376
]

Events.onMapUpdate+=proc {|sender,e|
  #next if !$game_switches[HIDDENMAPSWITCH]
  if $PokemonGlobal.stepcount % HIDDEN_MAPS_STEPS == 0
    changeHiddenMap()
  end
}
def changeHiddenMap()
  i = rand(RANDOM_HIDDEN_MAP_LIST.length-1)
  pbSet(226,RANDOM_HIDDEN_MAP_LIST[i])
end

def Kernel.getMapName(id)
  mapinfos = pbLoadMapInfos
  return mapinfos[id].name
end