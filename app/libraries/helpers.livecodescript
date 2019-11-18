script "Helper Library"

/**
Summary: Tells you whether the provided list of modifier keys are depressed.

pModifiers: List of keys to check. Any combination of "shift", "option", "command", "control" or "option-control".

Description: "option-control" will check for option on macos and control on other platforms. Use this for copy operations.

Returns: true/false
*/
function IsThisModifierSetActive pModifiers
  local theState

  replace "alt" with "option" in pModifiers

  set the wholeMatches to true

  put the optionKey into theState
  if "option" is among the items of pModifiers or ("option-control" is among the items of pModifiers and the platform is "macos") then
    if theState is "up" then
      return false
    end if
  else if theState is "down" then
    return false
  end if

  put the shiftKey into theState
  if "shift" is among the items of pModifiers then
    if theState is "up" then
      return false
    end if
  else if theState is "down" then
    return false
  end if

  if the platform is "macos" then
    put the commandKey into theState
    if "command" is among the items of pModifiers then
      if theState is "up" then
        return false
      end if
    else if theState is "down" then
      return false
    end if

    put the controlKey into theState
    if "control" is among the items of pModifiers then
      if theState is "up" then
        return false
      end if
    else if theState is "down" then
      return false
    end if
  else
    put the commandKey into theState
    if "command" is among the items of pModifiers or "control" is among the items of pModifiers or "option-control" is among the items of pModifiers then
      if theState is "up" then
        return false
      end if
    else if theState is "down" then
      return false
    end if
  end if

  return true
end IsThisModifierSetActive


/**
Summary: Prints an array using YAML.

Returns: YAML string
*/
function printArray pArray
  local tKeys, tKey, tYAML

  put the keys of pArray into tKeys
  sort tKeys numeric

  repeat for each line tKey in tKeys
    put _outputKeyAsYAML(pArray, tKey, 1) & cr after tYAML
  end repeat
  delete the last char of tYAML

  return tYAML
end printArray


private function _outputKeyAsYAML pArrayA, pKey, pLevel
  local tIndent, tKey, tStr, i

  repeat with i = 1 to pLevel-1
    put space & space after tIndent
  end repeat
  put tIndent after tStr
  put pKey & ": " after tStr

  if pArrayA[pKey] is an array then
    put cr after tStr
    repeat for each key tKey in pArrayA[pKey]
      put _outputKeyAsYAML(pArrayA[pKey], tKey, pLevel+1) & cr after tStr
    end repeat
  else
    if pArrayA[pKey] contains CR then
      put space & space after tIndent
      put "|+" & cr & tIndent after tStr
      replace CR with CR & tIndent in pArrayA[pKey]
    end if

    if pArrayA[pKey] contains "'" then
      replace "'" with "''" in pArrayA[pKey]
      put "'" & pArrayA[pKey] & "'" & cr after tStr
    else
      put pArrayA[pKey] & cr after tStr
    end if
  end if
  delete the last char of tStr

  return tStr
end _outputKeyAsYAML
