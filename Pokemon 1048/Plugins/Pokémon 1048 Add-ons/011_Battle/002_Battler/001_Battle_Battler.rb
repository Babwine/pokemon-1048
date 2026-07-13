class Battle::Battler
  def airborne?
    return false if hasActiveItem?(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pbHasType?(:FLYING)
    return true if hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
    return true if @battle.allOtherSameSideBattlers(index).map { |b| b.hasActiveAbility?(:LENDAHAND) }.any? && !@battle.moldBreaker
    return true if hasActiveItem?(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise] > 0
    return true if @effects[PBEffects::Telekinesis] > 0
    return false
  end
end
