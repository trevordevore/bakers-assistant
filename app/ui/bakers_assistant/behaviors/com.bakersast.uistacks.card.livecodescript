script "com.bakersast.uistacks.card"

command _resetUI
  set the dvTree of group "Stacks" to empty
  set the text of image "Preview" to empty
  set the rect of image "Preview" to the rect of button "Preview"
  show field "Preview"
  PopulateUITypesMenu

  lock messages
  set the menuHistory of button "UIType" to 1
  unlock messages
end _resetUI


on preOpenCard
  resizeStack the width of me, the height of me
  PopulateUITypesMenu
  PopulateUIStacks
end preOpenCard


on closeCard
  set the dvTree of group "Stacks" to empty

end closeCard


on resizeStack pWidth, pHeight
  ResizeGlobalControls

  set the topleft of field "LblHeading" to 20,the bottom of group "NavigationControls" + 20
  set the rect of button "Preview" to 20, pHeight - (pHeight * .30), pWidth-20, pHeight - 20
  set the rect of graphic "PreviewBorder" to the rect of button "Preview"
  set the loc of field "Preview" to the loc of button "Preview"
  _resizePreview
  set the rect of group "Stacks" to 20,the bottom of field "LblHeading" + 8, pWidth-20, the top of button "Preview" - 8

  set the right of button "UIType" to pWidth-20
  set the top of button "UIType" to the item 2 of the loc of field "LblHeading" - (the height of button "UIType"/2)
  set the topright of field "LblTypeFilter" to the topleft of button "UIType"
end resizeStack


private command _resizePreview
  local tDimensions, tPixelScale

  put max(1, the uPixelScale of image "Preview") into tPixelScale

  put ScaleDimensionsToFit(the width of image "Preview" / tPixelScale, \
        the height of image "Preview" / tPixelScale, \
        the width of button "Preview", the height of button "Preview", 1) into tDimensions
  set the width of image "Preview" to item 1 of tDimensions
  set the height of image "Preview" to item 2 of tDimensions
  set the loc of image "Preview" to the loc of button "Preview"
end _resizePreview


private command PopulateUITypesMenu
  local tMenu

  put "UI" & cr & "Templates" into tMenu

  if levureAppHasProperty("embeddable views") then
    put cr & "Embeddable Views" after tMenu
  end if

  set the text of button "UIType" to tMenu
end PopulateUITypesMenu


command PopulateUIStacks
  local tNodesA

  put createRootStackNodes() into tNodesA
  set the dvTree of group "Stacks" to tNodesA

  set the text of image "Preview" to empty
end PopulateUIStacks


command uiPreviewControl pControl
  local tStack

  lock screen

  show field "Preview"

  if word 1 of pControl is "stack" then
    put the long id of the current card of pControl into pControl
  end if

  put StackOf(pControl) into tStack

  local tScreenNo, tPixelScale, tWidth, tHeight

  put the screen of tStack into tScreenNo
  put line tScreenNo of the screenPixelScales into tPixelScale
  put the width of pControl * tPixelScale into tWidth
  put the height of pControl * tPixelScale into tHeight

  if tWidth > 0 and tHeight > 0 then
    set the uPixelScale of image "Preview" to tPixelScale
    export snapshot from pControl at size tWidth,tHeight to image "Preview" as PNG
    _resizePreview
  else
    set the text of image "Preview" to empty
  end if
  hide field "Preview"
  unlock screen
end uiPreviewControl


command uiInsertEmbeddableViewIntoTopStack pStackShortName
  local tViewKind

  if the topstack is not empty then
    put pStackShortName into tViewKind
    embedViewsCreateViewInstance tViewKind, the long id of this card of the topstack
  end if
end uiInsertEmbeddableViewIntoTopStack


private function createRootStackNodes
  local tUIKey, tStacksA, tStackA, tNodeA, tNodesA, tIndex

  put the selectedText of button "UIType" into tUIKey
  -- filename
  -- key
  -- name
  -- encrypt
  put SortArrayByKey(levureGetUIStacks(tUIKey), "name") into tStacksA

  repeat for each element tStackA in tStacksA
    put empty into tNodeA
    put the long id of stack tStackA["name"] into tNodeA["id"]
    put tStackA["name"] into tNodeA["name"]
    put the name of stack tStackA["name"] into tNodeA["control name"]
    put "stack" into tNodeA["type"]
    put false into tNodeA["expanded"]
    put false into tNodeA["is leaf"]
    put empty into tNodeA["children"]

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  return tNodesA
end createRootStackNodes


function createNodesForControlChildren pControlRef
  switch word 1 of pControlRef
    case "stack"
      return createNodesForStack(pControlRef)
    case "card"
    case "group"
      return createNodesForCardOrGroup(pControlRef)
    default
      return empty
  end switch
end createNodesForControlChildren


private function createNodesForStack pStackRef
  local tStack, tCardId, tNodeA, tNodesA, tIndex

  repeat for each line tStack in the substacks of pStackRef
    put empty into tNodeA
    put the long id of stack tStack of pStackRef into tNodeA["id"]
    put tStack into tNodeA["name"]
    put the name of stack tStack into tNodeA["control name"]
    put "stack" into tNodeA["type"]
    put false into tNodeA["expanded"]
    put false into tNodeA["is leaf"]
    put empty into tNodeA["children"]

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  repeat for each line tCardId in the cardIds of pStackRef
    put empty into tNodeA
    put the long id of card id tCardId of pStackRef into tNodeA["id"]
    put the short name of card id tCardId of pStackRef into tNodeA["name"]
    put the name of card id tCardId of pStackRef into tNodeA["control name"]
    put "card" into tNodeA["type"]
    put false into tNodeA["expanded"]
    put false into tNodeA["is leaf"]
    put empty into tNodeA["children"]

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  return tNodesA
end createNodesForStack


private function createNodesForCardOrGroup pControlRef
  local tControlIds, tControlId, tNodeA, tNodesA, tIndex, tCardId

  put the childControlIDs of pControlRef into tControlIds

  repeat for each line tControlId in tControlIds
    put empty into tNodeA
    put the long id of control id tControlId of pControlRef into tNodeA["id"]
    put the short name of control id tControlId of pControlRef into tNodeA["name"]
    put the name of control id tControlId of pControlRef into tNodeA["control name"]
    put word 1 of tNodeA["id"] into tNodeA["type"]
    put false into tNodeA["expanded"]
    put tNodeA["type"] is not "group" into tNodeA["is leaf"]
    put empty into tNodeA["children"]

    # For background groups (and any children controls) the card id must be updated
    # because the `long id` of the control will have the id of the current card.
    # This will lead to duplicate `id`s in the tree. If the group is shown in the tree
    # more than once than only the last instance will display data.
    get matchText(pControlRef, "card id ([0-9]+)", tCardId)
    put replacetext(tNodeA["id"], "card id ([0-9]+)", " card id" && tCardId) into tNodeA["id"]

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  return tNodesA
end createNodesForCardOrGroup

