class Battle
  # Actually performs the recalling and sending out in all situations.
  def pbRecallAndReplace(idxBattler, idxParty, randomReplacement = false, batonPass = false)
    @scene.pbRecall(idxBattler) if !@battlers[idxBattler].fainted?
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    @scene.pbShowPartyLineup(idxBattler & 1) if pbSideSize(idxBattler) == 1
    pbMessagesOnReplace(idxBattler, idxParty) if !randomReplacement
    pbReplace(idxBattler, idxParty, batonPass)
    if opposes?(idxBattler)
        pbAbleTeamCounts(1).each_with_index do |count, index|
        if count == 1 # replace 2 with battle side size (x3 battle)
          formatEventText(@laststand_events,index,@battlers[index].pbDirectOpposing,pbParty(idxBattler)[idxParty])
          pbHandleLastStandEvent(index)
        end
      end
    end
  end
end