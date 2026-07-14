#===============================================================================
# Increases the user's critical hit rate. (Focus Energy)
#===============================================================================
class Battle::Move::RaiseUserCriticalHitRate2 < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::FocusEnergy] = 2
    @battle.pbDisplay(_INTL("{1} is getting pumped!", user.pbThis))
    @battle.allOtherBattlers(user.index).each { |b| Battle::AbilityEffects.triggerOnTargetCritRateGain(b.ability, b) }
  end
end