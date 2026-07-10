#===============================================================================
# Pokémon can cure its status problem or heal some HP with its ability by
# switching out. Covers all abilities with an OnSwitchOut AbilityEffects
# handler.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:cure_status_problem_by_switching_out,
  proc { |battler, reserves, ai, battle|
    next false if !battler.ability_active?
    # Don't try to cure a status problem/heal a bit of HP if entry hazards will
    # KO the battler if it switches back in
    entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pokemon, battler.side)
    next false if entry_hazard_damage >= battler.hp
    # Check specific abilities
    single_status_cure = {
      :IMMUNITY    => :POISON,
      :INSOMNIA    => :SLEEP,
      :LIMBER      => :PARALYSIS,
      :MAGMAARMOR  => :FROZEN,
      :VITALSPIRIT => :SLEEP,
      :WATERBUBBLE => :BURN,
      :WATERVEIL   => :BURN,
      :SOUNDPROOF  => :DEAFENED
    }[battler.ability_id]
    if battler.ability == :NATURALCURE || (single_status_cure && single_status_cure == battler.status)
      # Cures status problem
      next false if battler.wants_status_problem?(battler.status)
      next false if battler.status == :SLEEP && battler.statusCount == 1   # Will wake up this round anyway
      next false if entry_hazard_damage >= battler.totalhp / 4
      # Don't bother curing a poisoning if Toxic Spikes will just re-poison the
      # battler when it switches back in
      if battler.status == :POISON && reserves.none? { |pkmn| pkmn.hasType?(:POISON) }
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 2
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 1 && battler.statusCount == 0
      end
      # Not worth curing status problems that still allow actions if at high HP
      next false if battler.hp >= battler.totalhp / 2 && ![:SLEEP, :FROZEN].include?(battler.status)
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to cure its status problem with #{battler.ability.name}")
        next true
      end
    elsif battler.ability == :REGENERATOR
      # Not worth healing if battler would lose more HP from switching back in later
      next false if entry_hazard_damage >= battler.totalhp / 3
      # Not worth healing HP if already at high HP
      next false if battler.hp >= battler.totalhp / 2
      # Don't bother if a foe is at low HP and could be knocked out instead
      if battler.check_for_move { |m| m.damagingMove? }
        weak_foe = false
        ai.each_foe_battler(battler.side) do |b, i|
          weak_foe = true if b.hp < b.totalhp / 3
          break if weak_foe
        end
        next false if weak_foe
      end
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to heal with #{battler.ability.name}")
        next true
      end
    end
    next false
  }
)