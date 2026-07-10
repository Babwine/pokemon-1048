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
