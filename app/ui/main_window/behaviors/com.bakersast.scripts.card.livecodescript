script "com.bakersast.scripts.card"


command _resetUI
  set the dvData of group "Scripts" to empty

  lock messages
  set the menuHistory of button "ScriptType" to 1
  unlock messages
end _resetUI


on preOpenCard
  resizeStack the width of me, the height of me
  PopulateScripts
end preOpenCard


on closeCard
  set the dvData of group "Scripts" to empty
end closeCard


on resizeStack pWidth, pHeight
  ResizeGlobalControls

  set the topleft of field "LblHeading" to 20,the bottom of group "NavigationControls" + 20
  set the right of button "ScriptType" to pWidth-20
  set the top of button "ScriptType" to the item 2 of the loc of field "LblHeading" - (the height of button "ScriptType"/2)
  set the topright of field "LblTypeFilter" to the topleft of button "ScriptType"

  set the rect of group "Scripts" to 20,the bottom of field "LblHeading" + 8, pWidth-20, pHeight-20
end resizeStack


command PopulateScripts
  local tScriptsA, tKey

  put the selectedText of button "ScriptType" into tKey
  put levureAppGet(tKey) into tScriptsA
  set the dvData of group "Scripts" to tScriptsA
end PopulateScripts
