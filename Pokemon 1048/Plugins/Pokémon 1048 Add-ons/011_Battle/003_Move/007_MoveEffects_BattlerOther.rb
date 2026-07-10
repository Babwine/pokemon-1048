#===============================================================================
# Deafens the target.
#===============================================================================
class Battle::Move::DeafenTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    return !target.pbCanDeafen?(user, show_message, self)
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbDeafen
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbDeafen if target.pbCanDeafen?(user, true, self)
  end
end

#===============================================================================
# Gives target the Steel type. (Iron Filings)
#===============================================================================
class Battle::Move::AddSteelTypeToTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.canChangeType? || !GameData::Type.exists?(:STEEL) || target.pbHasType?(:STEEL)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::ExtraType] = :STEEL
    typeName = GameData::Type.get(:STEEL).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
  end
end

#===============================================================================
# Gives target the Rock type and paralyzes it. (Petrifaction)
#===============================================================================
class Battle::Move::AddRockTypeToTargetAndParalyze < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.canChangeType? || !GameData::Type.exists?(:ROCK) || target.pbHasType?(:ROCK)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::ExtraType] = :ROCK
    typeName = GameData::Type.get(:ROCK).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    target.pbParalyze(user) if target.pbCanParalyze?(user, nil, self)
  end
end