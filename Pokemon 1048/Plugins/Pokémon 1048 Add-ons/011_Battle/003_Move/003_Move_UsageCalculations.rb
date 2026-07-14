class Battle::Move
  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user, target, effectChance = 0)
    return 0 if (target.hasActiveAbility?(:SHIELDDUST) || target.hasActiveAbility?(:PUREASGOLD)) && !@battle.moldBreaker
    ret = (effectChance > 0) ? effectChance : @addlEffect
    return ret if ret > 100
    if (Settings::MECHANICS_GENERATION >= 6 || @function_code != "EffectDependsOnEnvironment") &&
       (user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
      ret *= 2
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user, target)
    return 0 if flinchingMove?
    return 0 if (target.hasActiveAbility?(:SHIELDDUST) || target.hasActiveAbility?(:PUREASGOLD)) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH, true) ||
       user.hasActiveItem?([:KINGSROCK, :RAZORFANG], true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow] > 0
    return ret
  end
end
