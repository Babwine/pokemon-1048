#===============================================================================
# Message-displaying functions
#===============================================================================
def pbMessage(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwndw|
                             next pbShowCommands(msgwndw, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow)
  Input.update
  return ret
end
