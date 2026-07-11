#===============================================================================
# Heals user to full HP. User is confused for 2 rounds. (Rest)
#===============================================================================
class Battle::Move::HealUserFullyAndBecomeConfused < Battle::Move::HealingMove
  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Confusion] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanConfuseSelf?(true)
    return true if super
    return false
  end

  def pbHealAmount(user)
    return user.totalhp - user.hp
  end

  def pbEffectGeneral(user)
    super
    user.pbConfuse(_INTL("{1} became healthy, but is now confused!", user.pbThis))
    user.effects[PBEffects::Confusion] = 2
  end
end