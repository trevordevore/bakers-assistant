script "Package Bakers Assistant"
local sRemappedBehaviorNamesA

command PackageBakersAssistant pBuildProfile
  local tError, tMainStack, tStacksA, tStackA
  local tBehaviorStack, tSubFolder, tBuildFolder

  if pBuildProfile is empty then put "release" into pBuildProfile

  put "levureBakersAssistant" into tMainStack

  # Bring all behaviors into the stack
  put levureGetUIStacks("templates") into tStacksA
  put the long id of stack tMainStack into tStacksA[the number of elements of tStacksA+1]["filename"]

  createBehaviorNameRemappingTable

  repeat for each element tStackA in tStacksA
    mergeInBehaviorsOfStack tStackA["filename"], tMainStack
    set the mainstack of stack tStackA["filename"] to tMainStack
  end repeat

  ## Merge in libraries
  local tMainScript

  put the script of stack tMainStack into tMainScript
  put levureAppGet("libraries") into tStacksA
  repeat for each element tStackA in tStacksA
    put cr & the script of stack tStackA["filename"] after tMainScript
  end repeat
  set the script of stack tMainStack to tMainScript

  put levureAppGet("version") & "-" & levureAppGet("build") into tSubFolder
  put levureBuildFolder() & "/" & pBuildProfile & "/" & tSubFolder into tBuildFolder

  start using stack packagerFilename()

  packagerCreateAllFoldersInPath tBuildFolder, levureBuildFolder()
  put the result into tError

  stop using packagerFilename()

  if tError is empty then
    set the title of stack tMainStack to "Baker's Assistant [" & levureAppGet("version") && "build" && levureAppGet("build") & "]"
    save stack tMainStack as tBuildFolder & "/bakers_assistant_plugin.livecode"
  end if

  if tError is not empty then
    answer error tError
  else
    answer "Plugin has been packaged."
  end if

end PackageBakersAssistant


/**
Summary: One cannot simply deploy an IDE plugin with stack names that could be used by the app developer.

Returns: nothing
*/
private command createBehaviorNameRemappingTable
  put "Bakers Assistant DataView Behavior" into sRemappedBehaviorNamesA["DataView Behavior"]
  put "Bakers Assistant DataView Tree Behavior" into sRemappedBehaviorNamesA["DataView Tree Behavior"]
  put "Bakers Assistant DataView Array Controller Behavior" into sRemappedBehaviorNamesA["DataView Array Controller Behavior"]
  put "Bakers Assistant DataView Scrollbar Behavior" into sRemappedBehaviorNamesA["DataView Scrollbar Behavior"]
  put "Bakers Assistant DataView Drop Indicator Behavior" into sRemappedBehaviorNamesA["DataView Drop Indicator Behavior"]
  put "Bakers Assistant DataView Track Drag and Drop Behavior" into sRemappedBehaviorNamesA["DataView Track Drag and Drop Behavior"]
end createBehaviorNameRemappingTable


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
    if behaviorNameShouldBeRemapped(tBehaviorControl) and there is not a tBehaviorControl then
      put the name of stack remappedBehaviorName(tBehaviorControl) into tBehaviorControl
    end if

    mergeInBehaviorsOfControl tBehaviorControl, pMainStack

    if word 1 of pControl is "stack" and the scriptOnly of pControl then
      if behaviorNameShouldBeRemapped(tBehaviorControl) then
        put remapBehaviorControl(tBehaviorControl) into tBehaviorControl
        set the behavior of pControl to tBehaviorControl
      end if

      set the mainstack of tBehaviorControl to pMainStack
    else
      set the script of pControl to the script of tBehaviorControl
      set the behavior of pControl to the behavior of tBehaviorControl
    end if
  end if

  return empty
end mergeInBehaviorsOfControl


private function remapBehaviorControl pBehaviorControl
  local tRemappedName

  put remappedBehaviorName(pBehaviorControl) into tRemappedName
  clone pBehaviorControl
  set the name of it to tRemappedName
  put the name of stack tRemappedName into pBehaviorControl

  return pBehaviorControl
end remapBehaviorControl


private function stackNameFromRef pControl
  local tStackName

  if word 1 of pControl is "stack" then
    get matchText(pControl, "stack " & quote & "(.+)" & quote, tStackName)
  end if

  return tStackName
end stackNameFromRef


private function remappedBehaviorName pBehaviorControl
  return sRemappedBehaviorNamesA[stackNameFromRef(pBehaviorControl)]
end remappedBehaviorName


private function behaviorNameShouldBeRemapped pBehaviorControl
  local tControlName

  put stackNameFromRef(pBehaviorControl) into tControlName
  if tControlName is not empty then
    return tControlName is among the keys of sRemappedBehaviorNamesA
  else
    return false
  end if
end behaviorNameShouldBeRemapped


private function packagerFilename
  local tPackagerFilename

  set the itemdelimiter to "/"

  put levureFrameworkFolder() into tPackagerFilename
  put "packager/packager.livecodescript" into the last item of tPackagerFilename
  return tPackagerFilename
end packagerFilename
