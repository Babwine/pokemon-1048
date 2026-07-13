class Battle
  attr_reader   :scene            # Scene object for this battle
  attr_reader   :peer
  attr_reader   :field            # Effects common to the whole of a battle
  attr_reader   :sides            # Effects common to each side of a battle
  attr_reader   :positions        # Effects that apply to a battler position
  attr_reader   :battlers         # Currently active Pokémon
  attr_reader   :sideSizes        # Array of number of battlers per side
  attr_accessor :backdrop         # Filename fragment used for background graphics
  attr_accessor :backdropBase     # Filename fragment used for base graphics
  attr_accessor :time             # Time of day (0=day, 1=eve, 2=night)
  attr_accessor :environment      # Battle surroundings (for mechanics purposes)
  attr_reader   :turnCount
  attr_accessor :decision         # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_reader   :player           # Player trainer (or array of trainers)
  attr_reader   :opponent         # Opponent trainer (or array of trainers)
  attr_accessor :items            # Items held by opponents
  attr_accessor :ally_items       # Items held by allies
  attr_accessor :party1starts     # Array of start indexes for each player-side trainer's party
  attr_accessor :party2starts     # Array of start indexes for each opponent-side trainer's party
  attr_accessor :internalBattle   # Internal battle flag
  attr_accessor :debug            # Debug flag
  attr_accessor :canRun           # True if player can run from battle
  attr_accessor :canLose          # True if player won't black out if they lose
  attr_accessor :canSwitch        # True if player is allowed to switch Pokémon
  attr_accessor :switchStyle      # Switch/Set "battle style" option
  attr_accessor :showAnims        # "Battle Effects" option
  attr_accessor :controlPlayer    # Whether player's Pokémon are AI controlled
  attr_accessor :expGain          # Whether Pokémon can gain Exp/EVs
  attr_accessor :moneyGain        # Whether the player can gain/lose money
  attr_accessor :disablePokeBalls # Whether Poké Balls cannot be thrown at all
  attr_accessor :sendToBoxes      # Send to Boxes (0=ask, 1=don't ask, 2=must add to party)
  attr_accessor :rules
  attr_accessor :choices          # Choices made by each Pokémon this round
  attr_accessor :megaEvolution    # Battle index of each trainer's Pokémon to Mega Evolve
  attr_reader   :initialItems
  attr_reader   :recycleItems
  attr_reader   :belch
  attr_reader   :battleBond
  attr_reader   :corrosiveGas
  attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
  attr_reader   :successStates    # Success states
  attr_accessor :lastMoveUsed     # Last move used
  attr_accessor :lastMoveUser     # Last move user
  attr_accessor :first_poke_ball  # ID of the first thrown Poké Ball that failed
  attr_accessor :poke_ball_failed # Set after first_poke_ball to prevent it being set again
  attr_reader   :switching        # True if during the switching phase of the round
  attr_reader   :futureSight      # True if Future Sight is hitting
  attr_reader   :command_phase
  attr_reader   :endOfRound       # True during the end of round
  attr_accessor :moldBreaker      # True if Mold Breaker applies
  attr_reader   :struggle         # The Struggle move
  attr_accessor :start_events
  attr_accessor :crit_events
  attr_accessor :supereffective_events
  attr_accessor :onehit_events
  attr_accessor :laststand_events
  attr_accessor :ability_events

  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene, p1, p2, player, opponent)
    if p1.length == 0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length == 0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = Peer.new
    @field             = ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [ActiveSide.new,   # Player's side
                          ActiveSide.new]   # Foe's side
    @positions         = []                 # Battler positions
    @battlers          = []
    @sideSizes         = [1, 1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @items             = nil
    @ally_items        = nil        # Array of items held by ally. This is just used for Mega Evolution for now.
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @canSwitch         = true
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @disablePokeBalls  = false
    @sendToBoxes       = 1
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
      [-1] * (@player ? @player.length : 1),
      [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
      Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
      Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @corrosiveGas      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @command_phase     = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
    @struggle          = Move::Struggle.new(self, nil)
	  @start_events	   = {}
    @crit_events	   = {}
    @supereffective_events = {}
    @onehit_events = {}
    @laststand_events = {}
    @ability_events = {}
    @mega_rings        = []
    GameData::Item.each { |item| @mega_rings.push(item.id) if item.has_flag?("MegaRing") }
    @battleAI          = AI.new(self)
    unless opponent.nil?
      opponent.each_with_index do |t, i|
        trainer_data = GameData::Trainer.get(t.trainer_type,t.name,t.version)
        unless trainer_data.nil?
          unless trainer_data.start_event.nil? || trainer_data.start_event.empty?
            @start_events[i] = trainer_data.start_event
          end
          unless trainer_data.crit_event.nil? || trainer_data.crit_event.empty?
            @crit_events[i] = trainer_data.crit_event
          end
          unless trainer_data.supereffective_event.nil? || trainer_data.supereffective_event.empty?
            @supereffective_events[i] = trainer_data.supereffective_event
          end
          unless trainer_data.onehit_event.nil? || trainer_data.onehit_event.empty?
            @onehit_events[i] = trainer_data.onehit_event
          end
          unless trainer_data.laststand_event.nil? || trainer_data.laststand_event.empty?
            @laststand_events[i] = trainer_data.laststand_event
          end
          unless trainer_data.ability_event.nil? || trainer_data.ability_event.empty?
            @ability_events[i] = trainer_data.ability_event
          end
        end
      end
    end
    end
end

  def allOtherSameSideBattlers(idxBattler = 0)
    return allSameSideBattlers(idxBattler).select {|b| b.index != idxBattler }
  end

  def pbHandleBattleStartEvents()
    unless @start_events.nil? || @start_events.empty?
      @start_events.each_key { |key| pbTriggerStartBattleEvent(key) }
      @start_events = []
    end
  end

  def pbHandleCritEvent(index)
    unless @crit_events.nil? || @crit_events[index].nil?
      pbTriggerBattleEvent(@crit_events, index)
    end
  end

  def pbHandleSuperEffectiveEvent(index)
    unless @supereffective_events.nil? || @supereffective_events[index].nil?
      pbTriggerBattleEvent(@supereffective_events, index)
    end
  end

  def pbHandleOneHitEvent(index)
    unless @onehit_events.nil? || @onehit_events[index].nil?
      pbTriggerBattleEvent(@onehit_events, index)
    end
  end

  def pbHandleLastStandEvent(index)
    unless @laststand_events.nil? || @laststand_events[index].nil?
      pbTriggerBattleEvent(@laststand_events, index)
    end
  end

def pbHandleAbilityEvent(index,ability)
  unless @ability_events.nil? || @ability_events[index].nil?
    pbTriggerBattleEventWithAdditionalInfo(@ability_events, index, ability)
  end
end

  def pbHandleTurnStartEvents()

  end

  def pbTriggerStartBattleEvent(index)
    @scene.pbShowOpponent(index)
    pbDisplay(_INTL(@start_events[index]))
    sleep(0.3)
    @scene.pbHideOpponent
  end

  def pbTriggerBattleEvent(event_hash,index)
    @scene.pbShowOpponent(index)
    pbDisplay(_INTL(event_hash[index]))
    sleep(0.3)
    @scene.pbHideOpponent
    event_hash.delete(index)
  end

def pbTriggerBattleEventWithAdditionalInfo(event_hash,index,additional_info)
  arr = event_hash[index].split('|')
  if arr[0] == additional_info
    @scene.pbShowOpponent(index)
    pbDisplay(_INTL(arr[1]))
    sleep(0.3)
    @scene.pbHideOpponent
    event_hash.delete(index)
  end
end

  def formatEventText(events_field, oppIdx, user, target)
    unless events_field.nil? || events_field.empty? || events_field[oppIdx].nil?
      events_field[oppIdx] = events_field[oppIdx]
             .gsub("\\pkmn",target.name)
             .gsub("\\pltr",@player[pbGetOwnerIndexFromBattlerIndex(user.index)].name)
             .gsub("\\pn",@player[0].name)
             .gsub("\\PKMN",target.name.upcase)
             .gsub("\\PLTR",@player[pbGetOwnerIndexFromBattlerIndex(user.index)].name.upcase)
             .gsub("\\PN",@player[0].name.upcase)
    end
  end
