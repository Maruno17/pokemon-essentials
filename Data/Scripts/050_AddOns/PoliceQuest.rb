def getBlackMarketOriginalTrainer
  randomTrainer = GameData::Trainer.list_all.values.sample
  return randomTrainer
  # trainer = NPCTrainer.new("", randomTrainer.id)
  # return trainer
end


