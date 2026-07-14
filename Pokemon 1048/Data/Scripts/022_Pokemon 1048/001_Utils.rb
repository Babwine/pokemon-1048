def playNoteFromVariable(numVar)
  valVar = $game_variables[numVar]
  case valVar
  when 0
    pbSEPlay("Note_D4", 100)
  when 1
    pbSEPlay("Note_E4", 100)
  when 2
    pbSEPlay("Note_A4", 100)
  when 3
    pbSEPlay("Note_B4", 100)
  when 4
    pbSEPlay("Note_C5", 100)
  when 5
    pbSEPlay("Note_D5", 100)
  when 6
    pbSEPlay("Note_E5", 100)
  else  
  end
end

def checkNotesAreOkByVariableMin(numVarMin, eNote1, eNote2, eNote3, eNote4)
  valVar1 = $game_variables[numVarMin]
  valVar2 = $game_variables[numVarMin+1]
  valVar3 = $game_variables[numVarMin+2]
  valVar4 = $game_variables[numVarMin+3]
  
  return valVar1 == eNote1 && valVar2 == eNote2 && valVar3 == eNote3 && valVar4 == eNote4 
end