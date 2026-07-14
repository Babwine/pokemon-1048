#===============================================================================
# Power is doubled if the user is burned, poisoned or paralyzed or deafened. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class Battle::Move::DoublePowerIfUserPoisonedBurnedParalyzed < Battle::Move
  def damageReducedByBurn?; return Settings::MECHANICS_GENERATION <= 5; end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.poisoned? || user.burned? || user.paralyzed? || user.deafened?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target is burned. (Boiled Coffee)
#===============================================================================
class Battle::Move::DoublePowerIfTargetBurned < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.burned? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# User is protected against damaging moves this round. Torments
# the user (Objection)
#===============================================================================
class Battle::Move::Objection < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Objection
  end
end

#===============================================================================
# Until the end of the next round, the user's moves will always be critical hits.
# (Laser Focus)
#===============================================================================
class Battle::Move::EnsureNextCriticalHit < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!", user.pbThis))
    @battle.allOtherBattlers(self).each { |b| Battle::AbilityEffects.triggerOnTargetCritEnsureGain(b.ability, b) }
  end
end