#===============================================================================
# Play the original Vs. Trainer battle transition animation for any single
# trainer battle where the following graphics exist in the Graphics/Transitions/
# folder for the opponent:
#   * "vsTrainer_TRAINERTYPE.png" and "vsBar_TRAINERTYPE.png"
#===============================================================================
##### VS. animation, by Luka S.J. #####
##### Tweaked by Maruno           #####
SpecialBattleIntroAnimations.register("alternate_vs_trainer_animation", 50,   # Priority 50
  proc { |battle_type, foe, location|   # Condition
    if !battle_type.even? && foe.length  != 1  # Trainer battle against +1 trainer
      tr_type1 = foe[0].trainer_type
      tr_type2 = foe[1].trainer_type
      next pbResolveBitmap("Graphics/Transitions/vsDoubleTrainer_#{tr_type1}_#{tr_type2}") &&
           pbResolveBitmap("Graphics/Transitions/vsDoubleBar_#{tr_type1}_#{tr_type2}")
    elsif !battle_type.even?
        tr_type = foe[0].trainer_type
        next pbResolveBitmap("Graphics/Transitions/vsTrainer_#{tr_type}") &&
             pbResolveBitmap("Graphics/Transitions/vsBar_#{tr_type}")
    end
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    # Determine filenames of graphics to be used
    tr_type = foe[0].trainer_type
    if !battle_type.even? && foe.length != 1
      tr_type2 = foe[1].trainer_type
      trainer_bar_graphic = sprintf("vsDoubleBar_%s_%s", tr_type.to_s, tr_type2.to_s) rescue nil
      trainer_graphic = sprintf("vsDoubleTrainer_%s_%s", tr_type.to_s, tr_type2.to_s) rescue nil
    elsif !battle_type.even?
      trainer_bar_graphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
      trainer_graphic     = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
    end
    player_tr_type = $player.trainer_type
    outfit = $player.outfit
    player_bar_graphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
    if !pbResolveBitmap("Graphics/Transitions/" + player_bar_graphic) 
      if (tr_type.to_s.include? "LEADER")
        player_bar_graphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
      else
        player_bar_graphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
      end
    end
    if $PokemonGlobal.partner != nil
      player_graphic = sprintf("vsDoubleTrainer_%s_%s_%d", player_tr_type.to_s, $PokemonGlobal.partner[0].to_s, outfit) rescue nil
      if !pbResolveBitmap("Graphics/Transitions/" + player_graphic)
        player_graphic = sprintf("vsDoubleTrainer_%s_%s", player_tr_type.to_s, $PokemonGlobal.partner[0].to_s) rescue nil
      end
    else
      player_graphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
      if !pbResolveBitmap("Graphics/Transitions/" + player_graphic)
        player_graphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
      end
    end
    # Set up viewports
    viewplayer = Viewport.new(0, Graphics.height / 3, Graphics.width / 2, 128)
    viewplayer.z = viewport.z
    viewopp = Viewport.new(Graphics.width / 2, Graphics.height / 3, Graphics.width / 2, 128)
    viewopp.z = viewport.z
    viewvs = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewvs.z = viewport.z
    # Set up sprites
    fade = Sprite.new(viewport)
    fade.bitmap  = RPG::Cache.transition("vsFlash")
    fade.tone    = Tone.new(-255, -255, -255)
    fade.opacity = 100
    overlay = Sprite.new(viewport)
    overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(overlay.bitmap)
    xoffset = ((Graphics.width / 2) / 10) * 10
    bar1 = Sprite.new(viewplayer)
    bar1.bitmap = RPG::Cache.transition(player_bar_graphic) 
    bar1.x      = -xoffset
    bar2 = Sprite.new(viewopp)
    bar2.bitmap = RPG::Cache.transition(trainer_bar_graphic)
    bar2.x      = xoffset
    vs_x = Graphics.width / 2
    vs_y = Graphics.height / 1.5
    vs = Sprite.new(viewvs)
    vs.bitmap  = RPG::Cache.transition("vs")
    vs.ox      = vs.bitmap.width / 2
    vs.oy      = vs.bitmap.height / 2
    vs.x       = vs_x
    vs.y       = vs_y
    vs.visible = false
    flash = Sprite.new(viewvs)
    flash.bitmap  = RPG::Cache.transition("vsFlash")
    flash.opacity = 0
    # Animate bars sliding in from either side
    pbWait(0.25) do |delta_t|
      bar1.x = lerp(-xoffset, 0, 0.25, delta_t)
      bar2.x = lerp(xoffset, 0, 0.25, delta_t)
    end
    bar1.dispose
    bar2.dispose
    # Make whole screen flash white
    pbSEPlay("Vs flash")
    pbSEPlay("Vs sword")
    flash.opacity = 255
    # Replace bar sprites with AnimatedPlanes, set up trainer sprites
    bar1 = AnimatedPlane.new(viewplayer)
    bar1.bitmap = RPG::Cache.transition(player_bar_graphic)
    bar2 = AnimatedPlane.new(viewopp)
    bar2.bitmap = RPG::Cache.transition(trainer_bar_graphic)
    player = Sprite.new(viewplayer)
    player.bitmap = RPG::Cache.transition(player_graphic)
    player.x      = -xoffset
    trainer = Sprite.new(viewopp)
    trainer.bitmap = RPG::Cache.transition(trainer_graphic)
    trainer.x      = xoffset
    trainer.tone   = Tone.new(-255, -255, -255)
    # Dim the flash and make the trainer sprites appear, while animating bars
    pbWait(1.2) do |delta_t|
      flash.opacity = lerp(255, 0, 0.25, delta_t)
      bar1.ox = lerp(0, -bar1.bitmap.width * 3, 1.2, delta_t)
      bar2.ox = lerp(0, bar2.bitmap.width * 3, 1.2, delta_t)
      player.x = lerp(-xoffset, 0, 0.25, delta_t - 0.6)
      trainer.x = lerp(xoffset, 0, 0.25, delta_t - 0.6)
    end
    player.x = 0
    trainer.x = 0
    # Make whole screen flash white again
    flash.opacity = 255
    pbSEPlay("Vs sword")
    # Make the Vs logo and trainer names appear, and reset trainer's tone
    vs.visible = true
    trainer.tone = Tone.new(0, 0, 0)
    if $PokemonGlobal.partner != nil 
      playername = $player.name + " & " + $PokemonGlobal.partner[1]
    else
      playername = $player.name
    end
    if foe.length != 1
      trainername = foe[0].name + " & " + foe[1].name
    else
      trainername = foe[0].name
    end
    textpos = [
        [playername, Graphics.width / 4, (Graphics.height / 1.5) + 16, :center,
         Color.new(248, 248, 248), Color.new(72, 72, 72)],
        [trainername, (Graphics.width / (4*foe.length)) + (Graphics.width / 2), (Graphics.height / 1.5) + 16, :left,
         Color.new(248, 248, 248), Color.new(72, 72, 72)]
      ]
    pbDrawTextPositions(overlay.bitmap, textpos)
    # Fade out flash, shudder Vs logo and expand it, and then fade to black
    shudder_time = 1.75
    zoom_time = 2.5
    pbWait(2.8) do |delta_t|
      if delta_t <= shudder_time
        flash.opacity = lerp(255, 0, 0.25, delta_t)   # Fade out the white flash
      elsif delta_t >= zoom_time
        flash.tone = Tone.new(-255, -255, -255)   # Make the flash black
        flash.opacity = lerp(0, 255, 0.25, delta_t - zoom_time)   # Fade to black
      end
      bar1.ox = lerp(0, -bar1.bitmap.width * 7, 2.8, delta_t)
      bar2.ox = lerp(0, bar2.bitmap.width * 7, 2.8, delta_t)
      if delta_t <= shudder_time
        # +2, -2, -2, +2, repeat
        period = (delta_t / 0.025).to_i % 4
        shudder_delta = [2, 0, -2, 0][period]
        vs.x = vs_x + shudder_delta
        vs.y = vs_y - shudder_delta
      elsif delta_t <= zoom_time
        vs.zoom_x = lerp(1.0, 7.0, zoom_time - shudder_time, delta_t - shudder_time)
        vs.zoom_y = vs.zoom_x
      end
    end
    # End of animation
    player.dispose
    trainer.dispose
    flash.dispose
    vs.dispose
    bar1.dispose
    bar2.dispose
    overlay.dispose
    fade.dispose
    viewvs.dispose
    viewopp.dispose
    viewplayer.dispose
    viewport.color = Color.black   # Ensure screen is black
  }
)