class Battle::Scene
    def pbHideOpponent()
    fadeAnim = Animation::TrainerFade.new(@sprites, @viewport, false)
    @animations.push(fadeAnim)
    while inPartyAnimation?
      pbUpdate
    end
  end
end
