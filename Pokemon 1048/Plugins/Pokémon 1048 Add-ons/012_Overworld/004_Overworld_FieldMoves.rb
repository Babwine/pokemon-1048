def pbFlashForDarkMap
  darkness = $game_temp.darkness_sprite
  darkness.radius = darkness.radiusMax
  Graphics.update
  Input.update
  pbUpdateSceneMap
end

def pbReturnToDarkMap
  darkness = $game_temp.darkness_sprite
  darkness.radius = darkness.radiusMin
  Graphics.update
  Input.update
  pbUpdateSceneMap
end