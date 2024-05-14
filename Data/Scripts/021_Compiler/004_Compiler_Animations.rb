module Compiler
  @@categories[:animations] = {
    :should_compile => proc { next false },
    :header_text    => proc { next _INTL("Compiling animations") },
    :skipped_text   => proc { next _INTL("Not compiled") },
    :compile        => proc { compile_animations }
  }

  module_function

  #-----------------------------------------------------------------------------
  # Compile battle animations
  #-----------------------------------------------------------------------------
  def compile_animations
    Console.echo_li(_INTL("Compiling animations..."))
    begin
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    rescue
      pbanims = PBAnimations.new
    end
    changed = false
    move2anim = [{}, {}]
#    anims = load_data("Data/Animations.rxdata")
#    for anim in anims
#      next if !anim || anim.frames.length == 1
#      found = false
#      for i in 0...pbanims.length
#        if pbanims[i] && pbanims[i].id == anim.id
#          found = true if pbanims[i].array.length > 1
#          break
#        end
#      end
#      pbanims[anim.id] = pbConvertRPGAnimation(anim) if !found
#    end
    idx = 0
    pbanims.length.times do |i|
      echo "." if idx % 100 == 0
      Graphics.update if idx % 500 == 0
      idx += 1
      next if !pbanims[i]
      if pbanims[i].name[/^OppMove\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[1][moveid] != i
          move2anim[1][moveid] = i
        end
      elsif pbanims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[0][moveid] != i
          move2anim[0][moveid] = i
        end
      end
    end
    if changed
      save_data(move2anim, "Data/move2anim.dat")
      save_data(pbanims, "Data/PkmnAnimations.rxdata")
    end
    process_pbs_file_message_end
  end
end
