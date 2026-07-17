module Battle::AbilityEffects
  EffectivenessCalcFromUser          = AbilityHandlerHash.new   # Dreadul
  OnTargetStatLoss                 = AbilityHandlerHash.new
  OnTargetStatGain                 = AbilityHandlerHash.new
  OnTargetCritRateGain                 = AbilityHandlerHash.new
  OnTargetCritEnsureGain                 = AbilityHandlerHash.new


  def self.triggerEffectivenessCalcFromUser(ability, user, target, move, type)
    EffectivenessCalcFromUser.trigger(ability, user, target, move, type)
  end

  def self.triggerOnTargetStatGain(ability, user, stat, increment, target)
    OnTargetStatGain.trigger(ability, user, stat, increment, target)
  end

  def self.triggerOnTargetStatLoss(ability, user, stat, increment, target)
    OnTargetStatLoss.trigger(ability, user, stat, increment, target)
  end

  def self.triggerOnTargetCritRateGain(ability, user)
    OnTargetCritRateGain.trigger(ability, user)
  end

  def self.triggerOnTargetCritEnsureGain(ability, user)
    OnTargetCritEnsureGain.trigger(ability, user)
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

Battle::AbilityEffects::DamageCalcFromUser.add(:OLYMPICFLAME,
   proc { |ability, user, target, move, mults, power, type|
     mults[:attack_multiplier] *= 1.5 if type == :FIRE
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
   battle.allBattlers.each do |b|
     b.pbLowerStatStageByAbility(:ACCURACY, 1, target, false) if b.index != target.index
   end
   battle.pbHandleAbilityEvent(battle.pbGetOwnerIndexFromBattlerIndex(target.index),ability.to_s)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:HEADSUP,
  proc { |ability, user, target, move, type, battle, show_message|
   next false if !move.slicingMove?
   next false if Settings::MECHANICS_GENERATION >= 8 && user.index == target.index
   if show_message
     if Battle::Scene::USE_ABILITY_SPLASH
       battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
     else
       battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!", target.pbThis, target.abilityName, move.name))
     end
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

Battle::AbilityEffects::DamageCalcFromUser.add(:DREADFUL,
   proc { |ability, user, target, move, mults, power, type|
     next if type != :GHOST
     mults[:attack_multiplier] *= 1.5 if user.pbHasType?(:DARK)
   }
)

Battle::AbilityEffects::OnBeingHit.add(:RESILIENCE,
   proc { |ability, user, target, move, battle|
     target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 1, target)
   }
)

Battle::AbilityEffects::OnTargetStatGain.add(:EMPATHETIC,
   proc { |ability, user, stat, increment, target|
     user.pbRaiseStatStageByAbility(stat, increment, user, showAnim = true, ignoreContrary = true)
   }
)

Battle::AbilityEffects::OnTargetStatLoss.add(:EMPATHETIC,
  proc { |ability, user, stat, increment, target|
   user.pbLowerStatStageByAbility(stat, increment, user, showAnim = true, ignoreContrary = true)
  }
)

Battle::AbilityEffects::OnTargetCritRateGain.add(:EMPATHETIC,
   proc { |ability, user|
     if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
       user.battle.pbShowAbilitySplash(user)
       user.effects[PBEffects::FocusEnergy] = 2
       if Battle::Scene::USE_ABILITY_SPLASH
         user.battle.pbDisplay(_INTL("{1} is getting pumped!", user.pbThis))
       else
         user.battle.pbDisplay(_INTL("{1}'s {2} got it pumped!",
                                user.pbThis, user.abilityName))
       end
       user.battle.pbHideAbilitySplash(user)
     end
   }
)

Battle::AbilityEffects::OnTargetCritEnsureGain.add(:EMPATHETIC,
   proc { |ability, user|
     if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
       user.battle.pbShowAbilitySplash(user)
       user.effects[PBEffects::LaserFocus] = 2
       if Battle::Scene::USE_ABILITY_SPLASH
         user.battle.pbDisplay(_INTL("{1} concentrated intensely!", user.pbThis))
       else
         user.battle.pbDisplay(_INTL("{1} concentrated intensely thanks to {2}!", user.pbThis, user.abilityName))
       end
       user.battle.pbHideAbilitySplash(user)
     end
   }
)

Battle::AbilityEffects::OnSwitchIn.add(:SUGARSYRUP,
  proc { |ability, battler, battle, switch_in|
   battle.allOtherSideBattlers(battler.index).each do |b|
     next if !b.near?(battler)
     b.pbLowerStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
   end
  }
)

Battle::AbilityEffects::OnBeingHit.copy(:SHIELDDUST, :PUREASGOLD)

Battle::AbilityEffects::OnDealingHit.add(:POISONTOUCH,
   proc { |ability, user, target, move, battle|
     next if !move.contactMove?
     next if battle.pbRandom(100) >= 30
     next if target.hasActiveItem?(:COVERTCLOAK)
     battle.pbShowAbilitySplash(user)
     if (target.hasActiveAbility?(:SHIELDDUST) || target.hasActiveAbility?(:PUREASGOLD)) && !battle.moldBreaker
       battle.pbShowAbilitySplash(target)
       battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
       battle.pbHideAbilitySplash(target)
     elsif target.pbCanPoison?(user, Battle::Scene::USE_ABILITY_SPLASH)
       msg = nil
       if !Battle::Scene::USE_ABILITY_SPLASH
         msg = _INTL("{1}'s {2} poisoned {3}!", user.pbThis, user.abilityName, target.pbThis(true))
       end
       target.pbPoison(user, msg)
     end
     battle.pbHideAbilitySplash(user)
   }
)


Battle::AbilityEffects::OnBeingHit.add(:ICETOLL,
   proc { |ability, user, target, move, battle|
     next if !move.pbContactMove?(user)
     next if user.deafened? || battle.pbRandom(100) >= 30
     battle.pbShowAbilitySplash(target)
     target.battle.allOtherBattlers(target.index).each do |b|
       if b.pbCanDeafen?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
          b.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
         msg = nil
         if !Battle::Scene::USE_ABILITY_SPLASH
           msg = _INTL("{1}'s {2} deafened {3}!",
                       target.pbThis, target.abilityName, b.pbThis(true))
         end
       end
       b.pbDeafen(msg)
     end

     battle.pbHideAbilitySplash(target)
   }
)

# ########################
# For specific abilities
# ########################
def increaseDamageFromAOEMovesToLessTargets(ability, user, target, move, mults, power, type, wantedType)
  return if type != wantedType
  return if move.pbTarget(user).num_targets < 2
  return if !move.damagingMove?
  case move.pbTarget(user).id
  when :AllAllies
    moveTargetCount = [user.battle.pbSideSize(0),2].max-1
  when :UserAndAllies
    moveTargetCount = [user.battle.pbSideSize(0),2].max
  when :AllNearFoes
    moveTargetCount = [user.battle.allOtherSideBattlers(user.index).select { |b| b.near?(user) }.length,2].max
  when :AllFoes
    moveTargetCount = [user.battle.pbSideSize(1),2].max
  when :AllNearOthers
    moveTargetCount = [user.battle.allOtherBattlers(user.index).select { |b| b.near?(user) }.length,3].max
  when :AllBattlers
    moveTargetCount = [allBattlers.length,3].max
  else
    moveTargetCount = 1
  end
  num_targets_hit = 0
  user.pbFindTargets(-1, move, user).each do |b|
    num_targets_hit += 1  if !b.damageState.missed && !b.damageState.unaffected
  end
  mult = 1 + (num_targets_hit > 0 ? 1-(num_targets_hit.to_f/moveTargetCount.to_f) : 1)
  return if num_targets_hit <= 0
  return if mult <= 1
  user.battle.pbShowAbilitySplash(user)
  user.battle.pbDisplay(_INTL("{1}'s {2} boosted the attack's power!",
                              user.pbThis, user.abilityName))
  mults[:power_multiplier] *= 1 + mult
  user.battle.pbHideAbilitySplash(user)
end

Battle::AbilityEffects::DamageCalcFromUser.add(:THUNDERINGCHARIOT,
   proc { |ability, user, target, move, mults, power, type|
     increaseDamageFromAOEMovesToLessTargets(ability, user, target, move, mults, power, type, :ELECTRIC)
   }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SURGINGCARRIAGE,
   proc { |ability, user, target, move, mults, power, type|
     increaseDamageFromAOEMovesToLessTargets(ability, user, target, move, mults, power, type, :WATER)
   }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:RUMBLINGCOACH,
   proc { |ability, user, target, move, mults, power, type|
     increaseDamageFromAOEMovesToLessTargets(ability, user, target, move, mults, power, type, :GROUND)
   }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ARSONIST,
  proc { |ability, user, target, move, mults, power, type|
    increaseDamageFromAOEMovesToLessTargets(ability, user, target, move, mults, power, type, :FIRE)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:UNWAVERING,
   proc { |ability, user, target, move, mults, power, type|
     next if move.pbTarget(user).num_targets < 2
     target.battle.pbShowAbilitySplash(target)
     target.battle.pbDisplay(_INTL("{1}'s {2} reduced the attack's power!",
                                   target.pbThis, target.abilityName))
     mults[:power_multiplier] *= 0.5
     target.battle.pbHideAbilitySplash(target)
   }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:HOURGLASSTWIST,
   proc { |ability, battler, battle|
     battle.pbShowAbilitySplash(battler)
     battler.effects[PBEffects::HyperBeam] = 0
     battle.pbDisplay(_INTL("{1} won't need any rest turn thanks to {2}!",
                            battler.pbThis, battler.abilityName))
     battle.pbHideAbilitySplash(battler)
   }
)