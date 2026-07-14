class Battle::Battler
  #=============================================================================
  # Increase stat stages
  #=============================================================================
  def pbRaiseStatStage(stat, increment, user, showAnim = true, ignoreContrary = false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStage(stat, increment, user, showAnim, true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp", self) if showAnim
    arrStatTexts = [
      _INTL("{1}'s {2} rose!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} rose sharply!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} rose drastically!", pbThis, GameData::Stat.get(stat).name)
    ]
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatGain(self.ability, self, stat, user)
      @battle.allOtherBattlers(self).each { |b| Battle::AbilityEffects.triggerOnTargetStatGain(b.ability, b, stat, increment, self) }
    end
    return true
  end

  def pbRaiseStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStageByCause(stat, increment, user, cause, showAnim, true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp", self) if showAnim
    if user.index == @index
      arrStatTexts = [
        _INTL("{1}'s {2} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} sharply raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} drastically raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
      ]
    else
      arrStatTexts = [
        _INTL("{1}'s {2} raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} sharply raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} drastically raised {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
      ]
    end
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatGain(self.ability, self, stat, user)
      @battle.allOtherBattlers(self).each { |b| Battle::AbilityEffects.triggerOnTargetStatGain(b.ability, b, stat, increment, self) }
    end
    return true
  end

  #=============================================================================
  # Decrease stat stages
  #=============================================================================
  def pbLowerStatStage(stat, increment, user, showAnim = true, ignoreContrary = false,
                       mirrorArmorSplash = 0, ignoreMirrorArmor = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStage(stat, increment, user, showAnim, true)
      end
      # Mirror Armor
      if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
         user && user.index != @index && !statStageAtMin?(stat)
        if mirrorArmorSplash < 2
          @battle.pbShowAbilitySplash(self)
          if !Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} activated!", pbThis, abilityName))
          end
        end
        ret = false
        if user.pbCanLowerStatStage?(stat, self, nil, true, ignoreContrary, true)
          ret = user.pbLowerStatStage(stat, increment, self, showAnim, ignoreContrary, mirrorArmorSplash, true)
        end
        @battle.pbHideAbilitySplash(self) if mirrorArmorSplash.even?   # i.e. not 1 or 3
        return ret
      end
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown", self) if showAnim
    arrStatTexts = [
      _INTL("{1}'s {2} fell!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} harshly fell!", pbThis, GameData::Stat.get(stat).name),
      _INTL("{1}'s {2} severely fell!", pbThis, GameData::Stat.get(stat).name)
    ]
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatLoss(self.ability, self, stat, user)
      @battle.allOtherBattlers(self).each { |b| Battle::AbilityEffects.triggerOnTargetStatLoss(b.ability, b, stat, increment, self) }
    end
    return true
  end

  def pbLowerStatStageByCause(stat, increment, user, cause, showAnim = true,
                              ignoreContrary = false, ignoreMirrorArmor = false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStageByCause(stat, increment, user, cause, showAnim, true)
      end
      # Mirror Armor
      if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
         user && user.index != @index && !statStageAtMin?(stat)
        @battle.pbShowAbilitySplash(self)
        if !Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s {2} activated!", pbThis, abilityName))
        end
        ret = false
        if user.pbCanLowerStatStage?(stat, self, nil, true, ignoreContrary, true)
          ret = user.pbLowerStatStageByCause(stat, increment, self, abilityName, showAnim, ignoreContrary, true)
        end
        @battle.pbHideAbilitySplash(self)
        return ret
      end
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
    return false if increment <= 0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown", self) if showAnim
    if user.index == @index
      arrStatTexts = [
        _INTL("{1}'s {2} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} harshly lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} severely lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
      ]
    else
      arrStatTexts = [
        _INTL("{1}'s {2} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} harshly lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name),
        _INTL("{1}'s {2} severely lowered {3}'s {4}!", user.pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
      ]
    end
    @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatLoss(self.ability, self, stat, user)
      @battle.allOtherBattlers(self).each { |b| Battle::AbilityEffects.triggerOnTargetStatLoss(b.ability, b, stat, increment, self) }
    end
    return true
  end
end
