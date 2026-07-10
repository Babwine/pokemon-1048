#===============================================================================
# The target can no longer use the same move twice in a row. (Torment)
# NOTE: Torment is only supposed to start applying at the end of the round in
#       which it is used, unlike Taunt which starts applying immediately. I've
#       decided to make Torment apply immediately.
#===============================================================================
class Battle::Move::ProtectUserFromDamagingMovesObjection < Battle::Move::ProtectMove
    def initialize(battle, move)
      super
      @effect = PBEffects::Objection
  end
end