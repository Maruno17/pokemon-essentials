#méthodes utilitaires ajoutées qui étaient éparpillées partout
# on va essayer de les regrouper ici

def getBodyID(species)
  return (species / NB_POKEMON).round
end

def getHeadID(species, bodyId)
  return (species - (bodyId * NB_POKEMON)).round
end

#-------------------------------------------------------------------------------
#  Misc scripting utilities
#-------------------------------------------------------------------------------
class Bitmap
  attr_accessor :storedPath
end

def pbBitmap(name)
  if !pbResolveBitmap(name).nil?
    bmp = RPG::Cache.load_bitmap(name)
    bmp.storedPath = name
  else
    p "Image located at '#{name}' was not found!" if $DEBUG
    bmp = Bitmap.new(1, 1)
  end
  return bmp
end
