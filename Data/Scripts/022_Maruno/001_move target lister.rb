#===============================================================================
#
#===============================================================================
def marListMoveTargetFunctionCodes
  target_hash = {}
  function_hash = {}

  GameData::Move.each do |move|
    target_hash[move.target] ||= []
    target_hash[move.target].push(move.function_code)
    function_hash[move.function_code] ||= []
    function_hash[move.function_code].push(move.target)
  end

  # Write results to file
  File.open("moves_by_target.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)

    f.write("=========================================================\r\n")
    f.write("SORTED BY TARGET\r\n")
    f.write("=========================================================\r\n\r\n")
    target_keys = target_hash.keys.sort { |a, b| a.downcase <=> b.downcase }
    target_keys.each do |key|
      next if !key || !target_hash[key] || target_hash[key].length == 0
      f.write("===== #{key} =====\r\n\r\n")
      arr = target_hash[key].uniq.sort
      arr.each { |code| f.write("#{code}\r\n")}
      f.write("\r\n")
    end
  }

  File.open("moves_by_function_code.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)

    f.write("=========================================================\r\n")
    f.write("SORTED BY FUNCTION CODE\r\n")
    f.write("=========================================================\r\n\r\n")

    code_keys = function_hash.keys.sort { |a, b| a.downcase <=> b.downcase }
    code_keys.each do |key|
      next if !key || !function_hash[key] || function_hash[key].length == 0
      f.write("===== #{key} =====\r\n\r\n")
      function_hash[key].sort.each { |target| f.write("#{target}\r\n")}
      f.write("\r\n")
    end
  }

  File.open("moves_by_function_code_multiple_target_types_only.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)

    f.write("=========================================================\r\n")
    f.write("SORTED BY FUNCTION CODE\r\n")
    f.write("=========================================================\r\n\r\n")

    code_keys = function_hash.keys.sort { |a, b| a.downcase <=> b.downcase }
    code_keys.each do |key|
      next if !key || !function_hash[key] || function_hash[key].length == 0
      next if function_hash[key].uniq.length <= 1
      f.write("===== #{key} =====\r\n\r\n")
      function_hash[key].sort.each { |target| f.write("#{target}\r\n")}
      f.write("\r\n")
    end
  }
end

#===============================================================================
# Add to Debug menu
#===============================================================================
MenuHandlers.add(:debug_menu, :print_move_target_functions, {
  "name"        => "Print Out Move Targets",
  "parent"      => :main,
  "description" => "Print all blah blah blah.",
  "effect"      => proc {
    marListMoveTargetFunctionCodes
  }
})
