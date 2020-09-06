

ItemHandlers::UseFromBag.add(:REDCLOTHES2,proc { |item|
  if $Trainer.trainertype==000
    if $Trainer.outfit==1 || $Trainer.outfit==3 
    pbUseItemMessage(item)
    pbMessage(_INTL("You must be using Red Alola Clothes to equip this."))  
      elsif $Trainer.outfit==2
        pbUseItemMessage(item)
        pbMessage(_INTL("You changed back your clothes."))
        $Trainer.outfit=0
        $game_map.refresh
      else   
        pbUseItemMessage(item)
        pbMessage(_INTL("You changed your clothes."))
        $Trainer.outfit=2
        $game_map.refresh
      end  
      next 1  
    next false
  end  
  next false
})

ItemHandlers::UseFromBag.add(:REDCLOTHES3,proc { |item|
  if $Trainer.trainertype==000
    if $Trainer.outfit==1 || $Trainer.outfit==2 
    pbUseItemMessage(item)
    pbMessage(_INTL("You must be using Red Alola Clothes to equip this."))  
      elsif $Trainer.outfit==3
        pbUseItemMessage(item)
        pbMessage(_INTL("You changed back your clothes."))
        $Trainer.outfit=0
        $game_map.refresh
      else   
        pbUseItemMessage(item)
        pbMessage(_INTL("You changed your clothes."))
        $Trainer.outfit=3
        $game_map.refresh
      end  
      next 1  
    next false
  end  
  next false
})

ItemHandlers::UseFromBag.add(:REDCLOTHES,proc { |item|
  oldfit=$Trainer.outfit
  if $Trainer.trainertype==000
    case $Trainer.outfit
    when 0
      $Trainer.outfit=1
    when 1
      $Trainer.outfit=0
    when 2
      $Trainer.outfit=5
    when 3
      $Trainer.outfit=6
    when 4
      $Trainer.outfit=7
    else
      pbMessage(_INTL("Unfortunately, this is not configured, please report to the Dev."))
    end  
  end
  if oldfit!=$Trainer.outfit
    pbWait(1)
    pbMessage(_INTL("You changed your clothes."))
    next 1
  end
  next 0
})

ItemHandlers::UseFromBag.add(:REDCLOTHES1,proc { |item|
  oldfit=$Trainer.outfit
  if $Trainer.trainertype==000
    case $Trainer.outfit
    when 0
      $Trainer.outfit=1
    when 1
      $Trainer.outfit=0
    when 2
      $Trainer.outfit=5
    when 3
      $Trainer.outfit=6
    when 4
      $Trainer.outfit=7
    else
      pbMessage(_INTL("Unfortunately, this is not configured, please report to the Dev."))
    end  
  end
  if oldfit!=$Trainer.outfit
    pbWait(1)
    pbMessage(_INTL("You changed your clothes."))
    next 1
  end
  next 0
})