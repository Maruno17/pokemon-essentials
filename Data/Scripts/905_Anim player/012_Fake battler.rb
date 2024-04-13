#===============================================================================
#
#===============================================================================
class AnimationPlayer::FakeBattler
  attr_reader :index
  attr_reader :pokemon

  def initialize(index, species, form = 0, gender = 0)
    @index = index
    @pokemon = AnimationPlayer::FakePokemon.new(species, form, gender)
  end
end

#===============================================================================
#
#===============================================================================
class AnimationPlayer::FakePokemon
  attr_reader :species, :form, :gender

  def initialize(species, form = 0, gender = 0)
    # NOTE: species will be a string, but it doesn't need to be a symbol.
    @species = species
    @form = form
    @gender = gender
  end
end
