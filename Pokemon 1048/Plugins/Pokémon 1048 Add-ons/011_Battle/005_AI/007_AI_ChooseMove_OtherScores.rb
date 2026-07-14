#===============================================================================
# Prefer flinching external effects (note that move effects which cause
# flinching are dealt with in the function code part of score calculation).
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:external_flinching_effects,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.damagingMove? && !move.move.flinchingMove? &&
       user.faster_than?(target) && target.effects[PBEffects::Substitute] == 0
      if user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
         user.has_active_ability?(:STENCH)
        if battle.moldBreaker || !target.has_active_ability?([:INNERFOCUS, :SHIELDDUST, :PUREASGOLD])
          old_score = score
          score += 8
          score += 5 if move.move.multiHitMove?
          PBDebug.log_score_change(score - old_score, "added chance to cause flinching")
        end
      end
    end
    next score
  }
)
