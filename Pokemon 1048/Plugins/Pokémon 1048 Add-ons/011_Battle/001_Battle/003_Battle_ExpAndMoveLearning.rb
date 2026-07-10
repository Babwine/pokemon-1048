class Battle
  #=============================================================================
  # Gaining Experience
  #=============================================================================
  def pbGainExp
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
    # Go through each battler in turn to find the Pokémon that participated in
    # battle against it, and award those Pokémon Exp/EVs
    expAll = $player.has_exp_all || $bag.has?(:EXPALL)
    p1 = pbParty(0)
    @battlers.each do |b|
        next unless b&.opposes?   # Can only gain Exp from fainted foes
        next if b.participants.length == 0
        next unless b.fainted? || b.captured
        # Count the number of participants
        numPartic = 0
        b.participants.each do |partic|
          next unless p1[partic]&.able? && pbIsOwner?(0, partic)
          numPartic += 1
        end
        # Find which Pokémon have an Exp Share
        expShare = []
        if !expAll
          eachInTeam(0, 0) do |pkmn, i|
            next if !pkmn.able?
            next if !pkmn.hasItem?(:EXPSHARE) && GameData::Item.try_get(@initialItems[0][i]) != :EXPSHARE
            expShare.push(i)
          end
        end
        # Calculate EV and Exp gains for the participants
        if numPartic > 0 || expShare.length > 0 || expAll
          # Gain EVs and Exp for participants
          eachInTeam(0, 0) do |pkmn, i|
            next if !pkmn.able?
            next unless b.participants.include?(i) || expShare.include?(i)
            pbGainEVsOne(i, b)
            pbGainExpOne(i, b, numPartic, expShare, expAll, !pkmn.shadowPokemon?) if canLevelUp(pkmn)
          end
          # Gain EVs and Exp for all other Pokémon because of Exp All
          if expAll
            showMessage = true
            eachInTeam(0, 0) do |pkmn, i|
              next if !pkmn.able?
              next if b.participants.include?(i) || expShare.include?(i)
              pbDisplayPaused(_INTL("Your other Pokémon also gained Exp. Points!")) if showMessage
              showMessage = false
              pbGainEVsOne(i, b)
              pbGainExpOne(i, b, numPartic, expShare, expAll, false) if canLevelUp(pkmn)
            end
          end
        end
        # Clear the participants array
        b.participants = []
    end
  end
  
  def canLevelUp(pkmn)
    badge_level = 20 + 10 * ($player.badge_count)
    badge_level = GameData::GrowthRate.max_level if $player.badge_count >= 8
    return !(pkmn.level >= badge_level)
  end
end