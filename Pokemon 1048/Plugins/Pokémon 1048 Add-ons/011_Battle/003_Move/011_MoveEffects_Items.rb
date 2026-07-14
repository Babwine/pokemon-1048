#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#===============================================================================
class Battle::Move::ThrowUserItemAtTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.substitute
    return if (target.hasActiveAbility?(:SHIELDDUST) || target.hasActiveAbility?(:PUREASGOLD)) && !@battle.moldBreaker
    case user.item_id
    when :POISONBARB
      target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when :TOXICORB
      target.pbPoison(user, nil, true) if target.pbCanPoison?(user, false, self)
    when :FLAMEORB
      target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when :LIGHTBALL
      target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    when :KINGSROCK, :RAZORFANG
      target.pbFlinch(user)
    else
      target.pbHeldItemTriggerCheck(user.item_id, true)
    end
    # NOTE: The official games only let the target use Belch if the berry flung
    #       at it has some kind of effect (i.e. it isn't an effectless berry). I
    #       think this isn't in the spirit of "consuming a berry", so I've said
    #       that Belch is usable after having any kind of berry flung at you.
    target.setBelched if user.item.is_berry?
  end
end
