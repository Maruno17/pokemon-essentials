class Data

  class Item
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :real_name_plural
    attr_reader :pocket
    attr_reader :price
    attr_reader :real_description
    attr_reader :field_use
    attr_reader :battle_use
    attr_reader :type
    attr_reader :move

    DATA = {}

    def initialize(hash)
      validate hash => Hash, hash[:id] => Symbol
      @id               = hash[:id]
      @id_number        = hash[:id_number]   || -1
      @real_name        = hash[:name]        || "Unnamed"
      @real_name_plural = hash[:name_plural] || "Unnamed"
      @pocket           = hash[:pocket]      || 1
      @price            = hash[:price]       || 0
      @real_description = hash[:description] || "???"
      @field_use        = hash[:field_use]   || 0
      @battle_use       = hash[:battle_use]  || 0
      @type             = hash[:type]        || 0
      @move             = hash[:move]
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessage(MessageTypes::Items, @id_number)
    end

    # @return [String] the translated plural version of the name of this item
    def name_plural
      return pbGetMessage(MessageTypes::ItemPlurals, @id_number)
    end

    # @return [String] the translated description of this item
    def description
      return pbGetMessage(MessageTypes::ItemDescriptions, @id_number)
    end

    # @param other [Symbol, Item, Integer]
    # @return [Boolean] whether other is the same as this item
    def ==(other)
      return false if other.nil?
      validate other => [Symbol, Item, Integer]
      if other.is_a?(Symbol)
        return @id == other
      elsif other.is_a?(Item)
        return @id == other.id
      elsif other.is_a?(Integer)
        return @id_number == other
      end
      return false
    end

    # @param item_id [Symbol, Item, Integer]
    # @return [Boolean] whether the given item_id is defined as an Item
    def self.exists?(item_id)
      return false if item_id.nil?
      validate item_id => [Symbol, Item, Integer]
      item_id = item_id.id if item_id.is_a?(Item)
      return !DATA[item_id].nil?
    end

    # @param item_id [Symbol, Item, Integer]
    # @return [Item]
    def self.get(item_id)
      validate item_id => [Symbol, Item, Integer]
      return item_id if item_id.is_a?(Item)
#      if item_id.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      raise "Unknown item ID #{item_id}." unless DATA.has_key?(item_id)
      return DATA[item_id]
    end

    def self.try_get(item_id)
      return nil if item_id.nil?
      validate item_id => [Symbol, Item, Integer]
      return item_id if item_id.is_a?(Item)
#      if item_id.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      return (DATA.has_key?(item_id)) ? DATA[item_id] : nil
    end

    def self.each
      keys = DATA.keys
      keys.sort! { |a, b| a.to_s <=> b.to_s }
      keys.each do |key|
        yield DATA[key] if key.is_a?(Symbol)
      end
    end

    def self.load
      const_set(:DATA, load_data("Data/items.dat"))
    end

    def self.save
      save_data(DATA, "Data/items.dat")
    end
  end

end



module Compiler
  module_function

  def compile_items
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    # Read each line of items.txt at a time and compile it into an item
    pbCompilerEachCommentedLine("PBS/items.txt") { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnssuusuuUN"])
      item_number = line[0]
      item_symbol = line[1].to_sym
      if Data::Item::DATA[item_number]
        raise _INTL("Item ID number '{1}' is used twice.\r\n{2}", item_number, FileLineData.linereport)
      elsif Data::Item::DATA[item_symbol]
        raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_symbol, FileLineData.linereport)
      end
      # Construct item hash
      item_hash = {
        :id_number   => item_number,
        :id          => item_symbol,
        :name        => line[2],
        :name_plural => line[3],
        :pocket      => line[4],
        :price       => line[5],
        :description => line[6],
        :field_use   => line[7],
        :battle_use  => line[8],
        :type        => line[9]
      }
      item_hash[:move] = parseMove(line[10]) if !nil_or_empty?(line[10])
      # Add item's data to records
      Data::Item::DATA[item_number] = Data::Item::DATA[item_symbol] = Data::Item.new(item_hash)
      item_names[item_number]        = item_hash[:name]
      item_names_plural[item_number] = item_hash[:name_plural]
      item_descriptions[item_number] = item_hash[:description]
    }
    # Save all data
    Data::Item.save
    MessageTypes.setMessages(MessageTypes::Items, item_names)
    MessageTypes.setMessages(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessages(MessageTypes::ItemDescriptions, item_descriptions)

    Graphics.update
  end
end
