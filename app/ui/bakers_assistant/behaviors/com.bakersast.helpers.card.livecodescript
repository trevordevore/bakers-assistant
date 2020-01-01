script "com.bakersast.helpers.card"

command _resetUI
  set the dvData of group "Helpers" to empty
  set the text of field "HelperConfig" to empty
end _resetUI


on preOpenCard
  resizeStack the width of me, the height of me
  PopulateHelpers
end preOpenCard


on closeCard
  set the dvData of group "Helpers" to empty
end closeCard


on resizeStack pWidth, pHeight
  ResizeGlobalControls

  set the topleft of field "LblHeading" to 20,the bottom of group "NavigationControls" + 20
  set the rect of field "HelperConfig" to 20, pHeight - 150, pWidth-20, pHeight - 20

  set the rect of group "Helpers" to 20,the bottom of field "LblHeading" + 8, pWidth-20, the top of field "HelperConfig" - 8
end resizeStack


command PopulateHelpers
  local tHelpersA

  put sortedHelpers() into tHelpersA
  set the dvData of group "Helpers" to tHelpersA
end PopulateHelpers


/**
Summary: Sort helpers by name.

Returns: Array of helpers sorted by name.
*/
private function sortedHelpers
  local tHelpersA, tSortedHelpersA, tHelperA, tKeys, i

  put levureAppGet("helpers") into tHelpersA

  set the itemDelimiter to "/"

  repeat for each element tHelperA in tHelpersA
    add 1 to i
    put i & "," & the last item of tHelperA["filename"] & cr after tKeys
  end repeat
  delete the last char of tKeys

  set the itemDelimiter to ","

  sort lines of tKeys by item 2 to -1 of each
  put 0 into i

  repeat for each line tKey in tKeys
    add 1 to i
    put tHelpersA[item 1 of tKey] into tSortedHelpersA[i]
  end repeat

  return tSortedHelpersA
end sortedHelpers


/**
Summary: Displays the contents of a Helper's helper.yml file.

Returns: nothing
*/
command DisplayHelperConfig pFolder
  local tConfigFilename, tText

  put pFolder & "/helper.yml" into tConfigFilename

  if there is a file tConfigFilename then
    put URL("binfile:" & tConfigFilename) into tText
    put textDecode(tText, "utf8") into tText
  else
    put "helper.yml file not found for `" & tConfigFilename & "`" into tText
  end if

  set the text of field "HelperConfig" to tText
end DisplayHelperConfig
