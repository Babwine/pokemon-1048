class Game_Character
  attr_reader   :id
  attr_reader   :original_x
  attr_reader   :original_y
  attr_reader   :x
  attr_reader   :y
  attr_reader   :real_x
  attr_reader   :real_y
  attr_writer   :x_offset   # In pixels, positive shifts sprite to the right
  attr_writer   :y_offset   # In pixels, positive shifts sprite down
  attr_accessor :width
  attr_accessor :height
  attr_accessor :sprite_size
  attr_reader   :tile_id
  attr_accessor :character_name
  attr_accessor :character_hue
  attr_accessor :opacity
  attr_reader   :blend_type
  attr_accessor :direction
  attr_accessor :pattern
  attr_accessor :pattern_surf
  attr_accessor :lock_pattern
  attr_reader   :move_route_forcing
  attr_accessor :through
  attr_accessor :animation_id
  attr_accessor :transparent
  attr_reader   :move_speed
  attr_accessor :move_frequency
  attr_reader   :jump_speed
  attr_accessor :walk_anime
  attr_writer   :bob_height

  def initialize(map = nil)
    @map                       = map
    @id                        = 0
    @original_x                = 0
    @original_y                = 0
    @x                         = 0
    @y                         = 0
    @real_x                    = 0
    @real_y                    = 0
    @x_offset                  = 0
    @y_offset                  = 0
    @width                     = 1
    @height                    = 1
    @sprite_size               = [Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT]
    @tile_id                   = 0
    @character_name            = ""
    @character_hue             = 0
    @opacity                   = 255
    @blend_type                = 0
    @direction                 = 2
    @pattern                   = 0
    @pattern_surf              = 0
    @lock_pattern              = false
    @move_route_forcing        = false
    @through                   = false
    @animation_id              = 0
    @transparent               = false
    @original_direction        = 2
    @original_pattern          = 0
    @move_type                 = 0
    self.move_speed            = 3
    self.move_frequency        = 6
    self.jump_speed            = 3
    @move_route                = nil
    @move_route_index          = 0
    @original_move_route       = nil
    @original_move_route_index = 0
    @walk_anime                = true    # Whether character should animate while moving
    @step_anime                = false   # Whether character should animate while still
    @direction_fix             = false
    @always_on_top             = false
    @anime_count               = 0   # Time since pattern was last changed
    @stop_count                = 0   # Time since character last finished moving
    @bumping                   = false   # Used by the player only when walking into something
    @jump_peak                 = 0   # Max height while jumping
    @jump_distance             = 0   # Total distance of jump
    @jump_fraction             = 0   # How far through a jump we currently are (0-1)
    @jumping_on_spot           = false
    @bob_height                = 0
    @wait_count                = 0
    @wait_start                = nil
    @moved_this_frame          = false
    @moveto_happened           = false
    @locked                    = false
    @prelock_direction         = 0
  end

  def move_frequency=(val)
    return if val == @move_frequency
    @move_frequency = val
    # Time in seconds to wait between each action in a move route (not forced).
    # Specifically, this is the time to wait after the character stops moving
    # because of the previous action.
    #   1 => 4.75 seconds
    #   2 => 3.6 seconds
    #   3 => 2.55 seconds
    #   4 => 1.6 seconds
    #   5 => 0.75 seconds
    #   6 => 0 seconds, i.e. continuous movement
    @command_delay = (40 - (val * 2)) * (6 - val) / 40.0
  end
end
