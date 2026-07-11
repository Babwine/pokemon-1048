#===============================================================================
#
#===============================================================================
class Battle::AI
  BASE_ABILITY_RATINGS[6] << :WINGEDFEET
end

Battle::AI::Handlers::AbilityRanking.add(:WINGEDFEET,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:FLYING)
    next 0
  }
)