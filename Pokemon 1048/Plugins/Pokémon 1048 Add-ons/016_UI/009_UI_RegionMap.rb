class PokemonRegionMap_Scene
  LEFT          = 0
  TOP           = 0
  RIGHT         = 25
  BOTTOM        = 25
  SQUARE_WIDTH  = 16
  SQUARE_HEIGHT = 16

  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end
end
