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

  put levureAppGet("helpers") into tHelpersA
  set the dvData of group "Helpers" to tHelpersA
end PopulateHelpers

