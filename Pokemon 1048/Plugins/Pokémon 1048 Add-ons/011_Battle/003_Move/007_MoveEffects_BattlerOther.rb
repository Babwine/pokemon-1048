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

#===============================================================================
# Increases the user's and target's Attack by 1 stage. (High Five)
#===============================================================================
class Battle::Move::RaiseUserAndTargetAtk1 < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      target.pbRaiseStatStage(:ATTACK, 1, user)
    end
    if user.pbCanRaiseStatStage?(:ATTACK, user, self)
      user.pbRaiseStatStage(:ATTACK, 1, user)
    end
  end
end

#===============================================================================
# Loses 1/4 of max HP, switches and heals the next ally of the amount lost (All for One)
#===============================================================================
class Battle::Move::LoseHpAndSwitchAndHealNextAllyTotalHPLost < Battle::Move

  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    @subLife = [user.totalhp / 4, 1].max
    user.pbReduceHP(@subLife, false, false)
    return if user.fainted? || numHits == 0
    return if !@battle.pbCanChooseNonActive?(user.index)
    @battle.pbPursuit(user.index)
    return if user.fainted?
    newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
    return if newPkmn < 0
    @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
    @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    @battle.moldBreaker = false
    @battle.pbOnBattlerEnteringBattle(user.index)
    switchedBattlers.push(user.index)
    if user.hp == user.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", user.pbThis)) if show_message
    elsif !user.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", user.pbThis)) if show_message
    else
      user.pbRecoverHP(@subLife)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
    end
  end
end