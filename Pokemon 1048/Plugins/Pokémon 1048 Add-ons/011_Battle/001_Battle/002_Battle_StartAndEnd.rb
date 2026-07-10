class Battle
  #=============================================================================
  # Main battle loop
  #=============================================================================
  def pbBattleLoop
    @turnCount = 0
    pbHandleBattleStartEvents
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log_header("===== Round #{@turnCount + 1} =====")
      pbHandleTurnStartEvents
      if @debug && @turnCount >= 100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision > 0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision > 0
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision > 0
      @turnCount += 1
    end
    pbEndOfBattle
  end
end
