script "Package Bakers Assistant"

command PackageBakersAssistant pBuildProfile
  local tError, tMainStack, tStacksA, tStackA
  local tBehaviorStack, tSubFolder, tBuildFolder

  if pBuildProfile is empty then put "release" into pBuildProfile

  put "Bakers Assistant" into tMainStack

  # Bring all behaviors into the stack
  put levureGetUIStacks("templates") into tStacksA
  put the long id of stack tMainStack into tStacksA[the number of elements of tStacksA+1]["filename"]

  repeat for each element tStackA in tStacksA
    mergeInBehaviorsOfStack tStackA["filename"], tMainStack
    set the mainstack of stack tStackA["filename"] to tMainStack
  end repeat

  put levureAppGet("version") & "-" & levureAppGet("build") into tSubFolder
  put levureBuildFolder() & "/" & pBuildProfile & "/" & tSubFolder into tBuildFolder

  start using stack packagerFilename()

  packagerCreateAllFoldersInPath tBuildFolder, levureBuildFolder()
  put the result into tError

  stop using packagerFilename()

  if tError is empty then
    save stack tMainStack as tBuildFolder & "/bakers_assistant_plugin.livecode"
  end if

  if tError is not empty then
    answer error tError
  else
    answer "Plugin has been packaged."
  end if

end PackageBakersAssistant


private command mergeInBehaviorsOfStack pStack, pMainStack
  local tCardId

  mergeInBehaviorsOfControl the long id of stack pStack, pMainStack

  repeat for each line tCardId in the cardIds of stack pStack
    mergeInBehaviorsOfControl the long id of card id tCardId of stack pStack

    repeat with i = 1 to the number of controls of card id tCardId of stack pStack
      mergeInBehaviorsOfControl the long id of control i of card id tCardId of stack pStack, pMainStack
    end repeat
  end repeat

  return empty
end mergeInBehaviorsOfStack


private command mergeInBehaviorsOfControl pControl, pMainStack
  local tBehaviorControl

  put the behavior of pControl into tBehaviorControl
  if tBehaviorControl is not empty then
    mergeInBehaviorsOfControl tBehaviorControl, pMainStack

    if word 1 of pControl is "stack" and the scriptOnly of pControl then
      set the mainstack of tBehaviorControl to pMainStack
    else
      set the script of pControl to the script of tBehaviorControl
      set the behavior of pControl to the behavior of tBehaviorControl
    end if
  end if

  return empty
end mergeInBehaviorsOfControl


private function packagerFilename
  local tPackagerFilename

  set the itemdelimiter to "/"

  put levureFrameworkFolder() into tPackagerFilename
  put "packager/packager.livecodescript" into the last item of tPackagerFilename
  return tPackagerFilename
end packagerFilename
