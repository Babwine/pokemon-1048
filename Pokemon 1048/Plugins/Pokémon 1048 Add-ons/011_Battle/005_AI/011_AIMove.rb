#===============================================================================
#
#===============================================================================
class Battle::AI::AIMove
  def get_score_change_for_additional_effect(user, target = nil)
    # Doesn't have an additional effect
    return 0 if @move.addlEffect == 0
    # Additional effect will be negated
    return -999 if user.has_active_ability?(:SHEERFORCE)
    return -999 if target && user.index != target.index &&
                   (target.hasActiveAbility?(:SHIELDDUST) || target.hasActiveAbility?(:PUREASGOLD)) && !@ai.battle.moldBreaker
    # Prefer if the additional effect will have an increased chance of working
    return 5 if @move.addlEffect < 100 &&
                (Settings::MECHANICS_GENERATION >= 6 || function_code != "EffectDependsOnEnvironment") &&
                (user.has_active_ability?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
    # No change to score
    return 0
  end
end
