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

Battle::AbilityEffects::DamageCalcFromUser.add(:WINGEDFEET,
  proc { |ability, user, target, move, mults, power, type|
   mults[:attack_multiplier] *= 1.5 if type == :FLYING
  }
)

Battle::AbilityEffects::AccuracyCalcFromAlly.add(:MAINTHREAD,
   proc { |ability, mods, user, target, move, type|
     mods[:base_accuracy] = 0
   }
)

Battle::AbilityEffects::OnBeingHit.add(:COLLAPSE,
   proc { |ability, user, target, move, battle|
     next if !move.pbContactMove?(user)
     next if user.asleep? || battle.pbRandom(100) >= 30
     battle.pbShowAbilitySplash(target)
     if user.pbCanSleep?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
        user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
       msg = nil
       if !Battle::Scene::USE_ABILITY_SPLASH
         msg = _INTL("{1}'s {2} made {3} fall asleep!",
                     target.pbThis, target.abilityName, user.pbThis(true))
       end
       user.pbSleep(msg)
     end
     battle.pbHideAbilitySplash(target)
   }
)

Battle::AbilityEffects::OnBeingHit.add(:PANICKEDCRY,
   proc { |ability, user, target, move, battle|
     next if !move.pbContactMove?(user)
     next if user.deafened? || battle.pbRandom(100) >= 30
     battle.pbShowAbilitySplash(target)
     if user.pbCanDeafen?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
        user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
       msg = nil
       if !Battle::Scene::USE_ABILITY_SPLASH
         msg = _INTL("{1}'s {2} deafened {3}!",
                     target.pbThis, target.abilityName, user.pbThis(true))
       end
       user.pbDeafen(msg)
     end
     battle.pbHideAbilitySplash(target)
   }
)