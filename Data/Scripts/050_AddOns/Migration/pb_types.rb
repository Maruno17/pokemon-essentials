#pour pas avoir a changer les evenements qui callent PBTypes.getName dans les gyms
class PBTypes
  def PBTypes.getName(index)
    return GameData::Type.get(index).real_name
  end

end