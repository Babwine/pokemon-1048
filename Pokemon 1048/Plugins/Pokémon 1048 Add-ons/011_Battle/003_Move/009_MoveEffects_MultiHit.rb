#===============================================================================
# Hits twice.
#===============================================================================
class Battle::Move::HitTwoTimes < Battle::Move

#===============================================================================
# Hits 2-5 in a row. May deafen the target on each hit. (Bubble Mill)
#===============================================================================
class Battle::Move::HitTwoToFiveTimesDeafenTarget < Battle::Move::DeafenTarget
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets)
    hitChances = [
      2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3, 3, 3,
      4, 4, 4,
      5, 5, 5
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
end
end
