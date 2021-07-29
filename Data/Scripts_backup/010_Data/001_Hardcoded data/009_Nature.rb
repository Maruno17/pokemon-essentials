module GameData
  class Nature
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :stat_changes

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id           = hash[:id]
      @id_number    = hash[:id_number]    || -1
      @real_name    = hash[:name]         || "Unnamed"
      @stat_changes = hash[:stat_changes] || []
    end

    # @return [String] the translated name of this nature
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Nature.register({
  :id           => :HARDY,
  :id_number    => 0,
  :name         => _INTL("Hardy")
})

GameData::Nature.register({
  :id           => :LONELY,
  :id_number    => 1,
  :name         => _INTL("Lonely"),
  :stat_changes => [[:ATTACK, 10], [:DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :BRAVE,
  :id_number    => 2,
  :name         => _INTL("Brave"),
  :stat_changes => [[:ATTACK, 10], [:SPEED, -10]]
})

GameData::Nature.register({
  :id           => :ADAMANT,
  :id_number    => 3,
  :name         => _INTL("Adamant"),
  :stat_changes => [[:ATTACK, 10], [:SPECIAL_ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :NAUGHTY,
  :id_number    => 4,
  :name         => _INTL("Naughty"),
  :stat_changes => [[:ATTACK, 10], [:SPECIAL_DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :BOLD,
  :id_number    => 5,
  :name         => _INTL("Bold"),
  :stat_changes => [[:DEFENSE, 10], [:ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :DOCILE,
  :id_number    => 6,
  :name         => _INTL("Docile")
})

GameData::Nature.register({
  :id           => :RELAXED,
  :id_number    => 7,
  :name         => _INTL("Relaxed"),
  :stat_changes => [[:DEFENSE, 10], [:SPEED, -10]]
})

GameData::Nature.register({
  :id           => :IMPISH,
  :id_number    => 8,
  :name         => _INTL("Impish"),
  :stat_changes => [[:DEFENSE, 10], [:SPECIAL_ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :LAX,
  :id_number    => 9,
  :name         => _INTL("Lax"),
  :stat_changes => [[:DEFENSE, 10], [:SPECIAL_DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :TIMID,
  :id_number    => 10,
  :name         => _INTL("Timid"),
  :stat_changes => [[:SPEED, 10], [:ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :HASTY,
  :id_number    => 11,
  :name         => _INTL("Hasty"),
  :stat_changes => [[:SPEED, 10], [:DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :SERIOUS,
  :id_number    => 12,
  :name         => _INTL("Serious")
})

GameData::Nature.register({
  :id           => :JOLLY,
  :id_number    => 13,
  :name         => _INTL("Jolly"),
  :stat_changes => [[:SPEED, 10], [:SPECIAL_ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :NAIVE,
  :id_number    => 14,
  :name         => _INTL("Naive"),
  :stat_changes => [[:SPEED, 10], [:SPECIAL_DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :MODEST,
  :id_number    => 15,
  :name         => _INTL("Modest"),
  :stat_changes => [[:SPECIAL_ATTACK, 10], [:ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :MILD,
  :id_number    => 16,
  :name         => _INTL("Mild"),
  :stat_changes => [[:SPECIAL_ATTACK, 10], [:DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :QUIET,
  :id_number    => 17,
  :name         => _INTL("Quiet"),
  :stat_changes => [[:SPECIAL_ATTACK, 10], [:SPEED, -10]]
})

GameData::Nature.register({
  :id           => :BASHFUL,
  :id_number    => 18,
  :name         => _INTL("Bashful")
})

GameData::Nature.register({
  :id           => :RASH,
  :id_number    => 19,
  :name         => _INTL("Rash"),
  :stat_changes => [[:SPECIAL_ATTACK, 10], [:SPECIAL_DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :CALM,
  :id_number    => 20,
  :name         => _INTL("Calm"),
  :stat_changes => [[:SPECIAL_DEFENSE, 10], [:ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :GENTLE,
  :id_number    => 21,
  :name         => _INTL("Gentle"),
  :stat_changes => [[:SPECIAL_DEFENSE, 10], [:DEFENSE, -10]]
})

GameData::Nature.register({
  :id           => :SASSY,
  :id_number    => 22,
  :name         => _INTL("Sassy"),
  :stat_changes => [[:SPECIAL_DEFENSE, 10], [:SPEED, -10]]
})

GameData::Nature.register({
  :id           => :CAREFUL,
  :id_number    => 23,
  :name         => _INTL("Careful"),
  :stat_changes => [[:SPECIAL_DEFENSE, 10], [:SPECIAL_ATTACK, -10]]
})

GameData::Nature.register({
  :id           => :QUIRKY,
  :id_number    => 24,
  :name         => _INTL("Quirky")
})
