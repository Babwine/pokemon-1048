Battle::AbilityEffects::StatusImmunity.add(:SOUNDPROOF,
  proc { |ability, battler, status|
    next true if status == :DEAFENED
  }
)

Battle::AbilityEffects::StatusCure.add(:SOUNDPROOF,
  proc { |ability, battler|
    next if battler.status != :DEAFENED
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its deafness!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)