module Battle::AbilityEffects
  EffectivenessCalcFromUser          = AbilityHandlerHash.new   # Dreadul

  def self.triggerEffectivenessCalcFromUser(ability, user, target, move, type)
    EffectivenessCalcFromUser.trigger(ability, user, target, move, type)
  end
end
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

Battle::AbilityEffects::OnSwitchIn.add(:JUMPSCARE,
  proc { |ability, battler, battle, switch_in|
   battle.pbShowAbilitySplash(battler)
   battle.allOtherSideBattlers(battler.index).each do |b|
     next if !b.near?(battler)
     if b.effects[PBEffects::Jumpscare]
       battle.pbDisplay(_INTL("{1} didn't fall for it this time!", b.pbThis))
       next
     else
       b.effects[PBEffects::Jumpscare] = true
       b.pbFlinch(battler)
       battle.pbDisplay(_INTL("{1}'s {2} made {3} flinch!", battler.pbThis, battler.abilityName, b.pbThis(true)))
     end
   end
   battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:SORELOSER,
  proc { |ability, user, target, move, battle|
   next if !target.fainted?
   battle.pbShowAbilitySplash(target)
   battle.allBattlers.each do |b|
     b.pbLowerStatStageByAbility(:ACCURACY, 1, target, false) if b.index != target.index
   end
   battle.pbHandleAbilityEvent(battle.pbGetOwnerIndexFromBattlerIndex(target.index),ability.to_s)
   battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:HEADSUP,
  proc { |ability, user, target, move, type, battle, show_message|
   next false if !move.slicingMove?
   next false if Settings::MECHANICS_GENERATION >= 8 && user.index == target.index
   if show_message
     battle.pbShowAbilitySplash(target)
     if Battle::Scene::USE_ABILITY_SPLASH
       battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
     else
       battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!", target.pbThis, target.abilityName, move.name))
     end
     battle.pbHideAbilitySplash(target)
     target.pbRaiseStatStageByAbility(:ATTACK, 2, target, false) if user.index != target.index
   end
   next true
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:HEADSUP,
   proc { |ability, user, target, move, mults, power, type|
     mults[:power_multiplier] *= 1.25 if type == :FIRE
     mults[:power_multiplier] *= 0.5 if move.pbContactMove?(user) && type != :FIRE
   }
)

Battle::AbilityEffects::MoveBlocking.add(:SUDDENBLAST,
   proc { |ability, bearer, user, targets, move, battle|
     next false if battle.choices[user.index][4] <= 0
     next false if !bearer.opposes?(user)
     battle.pbShowAbilitySplash(bearer)
     isfoeside = false
     targets.each do |b|
       isfoeside = true if b.opposes?(user)
       if isfoeside && user.pbCanBurn?(b, Battle::Scene::USE_ABILITY_SPLASH)
         msg = nil
         if !Battle::Scene::USE_ABILITY_SPLASH
           msg = _INTL("{1}'s {2} burned {3} for using a priority move!", bearer.pbThis, bearer.abilityName, user.pbThis(true))
         end
         user.pbBurn(bearer, msg)
       end
     end
     battle.pbHideAbilitySplash(bearer)
     next false
   }
)

Battle::AbilityEffects::OnBeingHit.add(:STOICAL,
   proc { |ability, user, target, move, battle|
     next if !target.damageState.critical
     next if target.effects[PBEffects::FocusEnergy] >= 4
     battle.pbShowAbilitySplash(target)
     target.effects[PBEffects::FocusEnergy] = [target.effects[PBEffects::FocusEnergy] + 2, 4].min
     if Battle::Scene::USE_ABILITY_SPLASH
       battle.pbDisplay(_INTL("{1} is getting pumped!", target.pbThis))
     else
       battle.pbDisplay(_INTL("{1}'s {2} got it pumped!",
                              target.pbThis, target.abilityName))
     end
     battle.pbHideAbilitySplash(target)
   }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:STOICAL,
   proc { |ability, user, target, move, mults, power, type|
     next if !target.damageState.critical
     mults[:final_damage_multiplier] *= 0
     target.damageState.calcDamage = 0
   }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:SWEETDREAMS,
   proc { |ability, battler, battle|
     next if !battler.asleep? || !battler.canHeal?
     battle.pbShowAbilitySplash(battler)
     battler.pbRecoverHP(battler.totalhp / 4)
     battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
     battle.pbHideAbilitySplash(battler)
   }
)

Battle::AbilityEffects::EffectivenessCalcFromUser.add(:DREADFUL,
   proc { |ability, user, target, move, type|
     next if type != :GHOST
     ineff = false
     if target.pbTypes(true).any? {|t| Effectiveness.ineffective_type?(:DARK, t)} || target.pbTypes(true).any? {|t| Effectiveness.ineffective_type?(type, t)}
       target.damageState.typeMod = Effectiveness::INEFFECTIVE_MULTIPLIER
       ineff = true
     end
     next if ineff
     darkEff = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
     target.pbTypes(true).each do |t|
       darkEff *= move.pbCalcTypeModSingle(:DARK, t, user, target)
     end
     target.damageState.typeMod *= darkEff
   }
)