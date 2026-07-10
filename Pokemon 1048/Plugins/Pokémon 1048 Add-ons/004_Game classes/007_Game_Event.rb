class Game_Event < Game_Character
  attr_reader   :map_id
  attr_reader   :trigger
  attr_reader   :list
  attr_reader   :starting
  attr_reader   :tempSwitches   # Temporary self-switches
  attr_accessor :need_refresh
  attr_accessor :sped_up

  def initialize(map_id, event, map = nil)
    super(map)
    @map_id       = map_id
    @event        = event
    @id           = @event.id
    @original_x   = @event.x
    @original_y   = @event.y
    if @event.name[/size\((\d+),(\d+)\)/i]
      @width = $~[1].to_i
      @height = $~[2].to_i
    end
    @erased       = false
    @starting     = false
    @need_refresh = false
    @route_erased = false
    @through      = true
    @to_update    = true
    @tempSwitches = {}
    moveto(@event.x, @event.y) if map
    refresh
  end
end