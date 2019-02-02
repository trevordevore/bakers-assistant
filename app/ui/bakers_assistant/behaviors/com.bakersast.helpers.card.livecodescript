script "com.bakersast.helpers.card"

command _resetUI
  set the dvData of group "Helpers" to empty
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

  set the rect of group "Helpers" to 20,the bottom of field "LblHeading" + 8, pWidth-20, pHeight-20
end resizeStack


command PopulateHelpers
  local tHelpersA

  put sortedHelpers() into tHelpersA
  set the dvData of group "Helpers" to tHelpersA
end PopulateHelpers


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
