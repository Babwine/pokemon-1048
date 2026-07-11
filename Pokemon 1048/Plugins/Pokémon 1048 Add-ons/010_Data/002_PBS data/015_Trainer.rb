module GameData
  class Trainer
    attr_reader :id
    attr_reader :trainer_type
    attr_reader :real_name
    attr_reader :version
    attr_reader :items
    attr_reader :real_lose_text
    attr_reader :pokemon
    attr_reader :start_event
    attr_reader :crit_event
    attr_reader :supereffective_event
    attr_reader :onehit_event
    attr_reader :laststand_event
    attr_reader :ability_event
    attr_reader :pbs_file_suffix

    # "Pokemon" is specially mentioned in def compile_trainers and def
    # write_trainers, and acts as a subheading for a particular Pokémon.
    SCHEMA = {
      "SectionName" => [:id,             "esU", :TrainerType],
      "Items"       => [:items,          "*e", :Item],
      "LoseText"    => [:real_lose_text, "q"],
      "Pokemon"     => [:pokemon,        "ev", :Species],   # Species, level
      "StartEvent"  => [:start_event,    "q"],
      "CritEvent"   => [:crit_event,    "q"],
      "SuperEffectiveEvent"   => [:supereffective_event,    "q"],
      "OneHitEvent"  => [:onehit_event,    "q"],
      "LastStandEvent"  => [:laststand_event,    "q"],
      "AbilityEvent"  => [:ability_event,    "q"]
    }

    def initialize(hash)
      @id              = hash[:id]
      @trainer_type    = hash[:trainer_type]
      @real_name       = hash[:real_name]       || ""
      @version         = hash[:version]         || 0
      @items           = hash[:items]           || []
      @real_lose_text  = hash[:real_lose_text]  || "..."
      @pokemon         = hash[:pokemon]         || []
      @pokemon.each do |pkmn|
        GameData::Stat.each_main do |s|
          pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
          pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
        end
      end
      @start_event     = hash[:start_event] || ""
      @crit_event     = hash[:crit_event] || ""
      @supereffective_event = hash[:supereffective_event] || ""
      @onehit_event     = hash[:onehit_event] || ""
      @laststand_event     = hash[:laststand_event] || ""
      @ability_event     = hash[:ability_event] || ""
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end
  end
end
