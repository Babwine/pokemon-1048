class Battle::Move
  #=============================================================================
  # Messages upon being hit
  #=============================================================================
  def pbEffectivenessMessage(user, target, numTargets = 1)
    return if self.is_a?(Battle::Move::FixedDamageMove)
    return if target.damageState.disguise || target.damageState.iceFace
    if Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's super effective on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
      if user.opposes?(target.index)
        oppIdx = @battle.pbGetOwnerIndexFromBattlerIndex(target.index)
        @battle.formatEventText(@battle.supereffective_events,oppIdx,user,target)
        @battle.pbHandleSuperEffectiveEvent(oppIdx)
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
  end

  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    return if target.damageState.disguise || target.damageState.iceFace
    if target.damageState.substitute
      @battle.pbDisplay(_INTL("The substitute took damage for {1}!", target.pbThis(true)))
    end
    if target.damageState.critical
      if $game_temp.party_critical_hits_dealt &&
         $game_temp.party_critical_hits_dealt[user.pokemonIndex] &&
         user.pbOwnedByPlayer?
        $game_temp.party_critical_hits_dealt[user.pokemonIndex] += 1
      end
      if target.damageState.affection_critical
        if numTargets > 1
          @battle.pbDisplay(_INTL("{1} landed a critical hit on {2}, wishing to be praised!",
                                  user.pbThis, target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} landed a critical hit, wishing to be praised!", user.pbThis))
        end
      elsif numTargets > 1
        @battle.pbDisplay(_INTL("A critical hit on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
      unless @battle.pbOwnedByPlayer?(target.index)
        oppIdx = @battle.pbGetOwnerIndexFromBattlerIndex(target.index)
        @battle.formatEventText(@battle.crit_events, oppIdx, user, target)
        @battle.pbHandleCritEvent(oppIdx)
      end
    end
    # Effectiveness message, for moves with 1 hit
    if !multiHitMove? && user.effects[PBEffects::ParentalBond] == 0
      pbEffectivenessMessage(user, target, numTargets)
    end
    if target.damageState.substitute && target.effects[PBEffects::Substitute] == 0
      target.effects[PBEffects::Substitute] = 0
      @battle.pbDisplay(_INTL("{1}'s substitute faded!", target.pbThis))
    end
  end
end