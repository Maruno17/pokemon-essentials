#===============================================================================
# Stores information about a Pokémon's owner.
#===============================================================================
class Pokemon
  class Owner
    # @return [Integer] the ID of the owner
    attr_reader :id
    # @return [String] the name of the owner
    attr_reader :name
    # @return [Integer] the gender of the owner (0 = male, 1 = female, 2 = unknown)
    attr_reader :gender
    # @return [Integer] the language of the owner (see pbGetLanguage for language IDs)
    attr_reader :language

    # @param id [Integer] the ID of the owner
    # @param name [String] the name of the owner
    # @param gender [Integer] the gender of the owner (0 = male, 1 = female, 2 = unknown)
    # @param language [Integer] the language of the owner (see pbGetLanguage for language IDs)
    def initialize(id, name, gender, language)
      validate id => Integer, name => String, gender => Integer, language => Integer
      @id = id
      @name = name
      @gender = gender
      @language = language
    end

    # Returns a new Owner object populated with values taken from +trainer+.
    # @param trainer [Player, NPCTrainer] trainer object to read data from
    # @return [Owner] new Owner object
    def self.new_from_trainer(trainer)
      validate trainer => [Player, NPCTrainer]
      return new(trainer.id, trainer.name, trainer.gender, trainer.language)
    end

    # Returns an Owner object with a foreign ID.
    # @param name [String] owner name
    # @param gender [Integer] owner gender
    # @param language [Integer] owner language
    # @return [Owner] foreign Owner object
    def self.new_foreign(name = "", gender = 2, language = 2)
      return new($player.make_foreign_ID, name, gender, language)
    end

    # @param new_id [Integer] new owner ID
    def id=(new_id)
      validate new_id => Integer
      @id = new_id
    end

    # @param new_name [String] new owner name
    def name=(new_name)
      validate new_name => String
      @name = new_name
    end

    # @param new_gender [Integer] new owner gender
    def gender=(new_gender)
      validate new_gender => Integer
      @gender = new_gender
    end

    # @param new_language [Integer] new owner language
    def language=(new_language)
      validate new_language => Integer
      @language = new_language
    end

    # @return [Integer] the public portion of the owner's ID
    def public_id
      return @id & 0xFFFF
    end
  end
end
