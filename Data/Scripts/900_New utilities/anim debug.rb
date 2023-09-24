MenuHandlers.add(:debug_menu, :create_animation_pbs_files, {
  "name"        => _INTL("Write all animation PBS files"),
  "parent"      => :files_menu,
  "description" => _INTL("Write all animation PBS files."),
  "effect"      => proc {
    Compiler.write_all_battle_animations
  }
})
