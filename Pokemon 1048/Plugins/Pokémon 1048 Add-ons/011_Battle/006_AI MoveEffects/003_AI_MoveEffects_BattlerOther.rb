Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("GiveUserStatusToTarget",
  proc { |score, move, user, target, ai, battle|
    # Curing the user's status problem
    score += 15 if !user.wants_status_problem?(user.status)
    # Giving the target a status problem
    function_code = {
      :SLEEP     => "SleepTarget",
      :PARALYSIS => "ParalyzeTarget",
      :POISON    => "PoisonTarget",
      :BURN      => "BurnTarget",
      :FROZEN    => "FreezeTarget",
      :DEAFENED  => "DeafenTarget"
    }[user.status]
    if function_code
      new_score = Battle::AI::Handlers.apply_move_effect_against_target_score(function_code,
         score, move, user, target, ai, battle)
      next new_score if new_score != Battle::AI::MOVE_USELESS_SCORE
    end
    next score
  }
)