#===============================================================================
# TODO: Expect a particular (definable) number of digits. Crop or postpend if
#       the number of digits is wrong. Is optional. Make ColorPicker set this
#       amount.
#===============================================================================
class UIControls::HexNumberTextBox < UIControls::TextBox
  def update_text_entry
    ret = false
    Input.gets.each_char do |ch|
      case ch
      when "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
           "A", "B", "C", "D", "E", "F",
           "a", "b", "c", "d", "e", "f"
        insert_char(ch.upcase)
        ret = true
      end
    end
    return ret
  end
end
