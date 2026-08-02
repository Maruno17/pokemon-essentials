#===============================================================================
#
#===============================================================================
class AnimationEditor
  def save
#    AnimationEditor::ParticleDataHelper.optimize_all_particles(@anim[:particles])
    GameData::Animation.register(@anim, @anim_id)
    Compiler.write_battle_animation_file(@anim[:pbs_path])
    if @anim[:pbs_path] != @pbs_path
      if GameData::Animation::DATA.any? { |_key, anim| anim.pbs_path == @pbs_path }
        Compiler.write_battle_animation_file(@pbs_path)
      elsif FileTest.exist?("PBS/Animations/" + @pbs_path + ".txt")
        File.delete("PBS/Animations/" + @pbs_path + ".txt")
      end
      @pbs_path = @anim[:pbs_path]
    end
    save_settings
  end
end
