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
    DATA_FILENAME = "items.dat"

    extend ClassMethods
    include InstanceMethods

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
