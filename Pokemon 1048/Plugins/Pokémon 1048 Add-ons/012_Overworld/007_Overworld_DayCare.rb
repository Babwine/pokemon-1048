#===============================================================================
# NOTE: In Gen 7+, the Day Care is replaced by the Pokémon Nursery, which works
#       in much the same way except deposited Pokémon no longer gain Exp because
#       of the player walking around and, in Gen 8+, deposited Pokémon are able
#       to learn egg moves from each other if they are the same species. In
#       Essentials, this code can be used for both facilities, and these
#       mechanics differences are set by some Settings.
# NOTE: The Day Care has a different price than the Pokémon Nursery. For the Day
#       Care, you are charged when you withdraw a deposited Pokémon and you pay
#       an amount based on how many levels it gained. For the Nursery, you pay
#       $500 up-front when you deposit a Pokémon. This difference will appear in
#       the Day Care Lady's event, not in these scripts.
#===============================================================================
class DayCare
  def update_on_step_taken
    @step_counter += 1
    if @step_counter >= 256
      @step_counter = 0
      # Make an egg available at the Day Care
      if !@egg_generated && count == 2
        compat = compatibility
        egg_chance = [0, 20, 50, 70][compat]
        egg_chance = [0, 40, 80, 88][compat] if $bag.has?(:OVALCHARM)
        egg_chance = [0, 40, 80, 88][compat] if $player.pokemon_party.any? { |b| b.ability.ability_id == :CUPID }
        egg_chance = [0, 45, 85, 90][compat] if $bag.has?(:OVALCHARM) && $player.pokemon_party.any? { |b| b.ability.ability_id == :CUPID }
        @egg_generated = true if rand(100) < egg_chance
      end
      # Have one deposited Pokémon learn an egg move from the other
      # NOTE: I don't know what the chance of this happening is.
      share_egg_move if @share_egg_moves && rand(100) < 50
    end
    # Day Care Pokémon gain Exp/moves
    if @gain_exp
      @slots.each { |slot| slot.add_exp }
    end
  end
end
