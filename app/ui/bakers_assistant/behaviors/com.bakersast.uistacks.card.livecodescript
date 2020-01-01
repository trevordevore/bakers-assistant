script "com.bakersast.uistacks.card"
local sNodeExpandedCacheA


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

  put ScaleDimensionsToFit(the formattedwidth of image "Preview" / tPixelScale, \
        the formattedheight of image "Preview" / tPixelScale, \
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

  put cr & "Open Stacks" after tMenu

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

  if there is not a pControl then
    return empty
  end if

  show field "Preview"

  if word 1 of pControl is "stack" then
    put the long id of the current card of pControl into pControl
  end if

  put StackOf(pControl) into tStack

  send "RenderPreviewOfControl tStack, pControl" to me in 10 milliseconds
end uiPreviewControl


command RenderPreviewOfControl pStack, pControl
  local tScreenNo, tPixelScale, tWidth, tHeight

  if there is not a pControl then return empty

  lock screen

  put the screen of pStack into tScreenNo
  put line tScreenNo of the screenPixelScales into tPixelScale
  put the width of pControl * tPixelScale into tWidth
  put the height of pControl * tPixelScale into tHeight

  if tWidth > 0 and tHeight > 0 then
    set the resizeQuality of image "Preview" to "good"
    set the uPixelScale of image "Preview" to tPixelScale
    export snapshot from pControl at size tWidth,tHeight to image "Preview" as PNG
    _resizePreview
    hide field "Preview"
  else
    set the text of image "Preview" to empty
  end if

  unlock screen
end RenderPreviewOfControl


command uiGoToControl pControl
  if there is a pControl then
    switch word 1 of pControl
      case "card"
      case "stack"
        go pControl
        break
      default
        go CardOf(pControl)
        select pControl
    end switch
  else
    _alertUserOfDeletedControl pControl
  end if
end uiGoToControl


command uiAlertUserOfDeletedControl pControl
  _alertUserOfDeletedControl pControl
end uiAlertUserOfDeletedControl


private command _alertUserOfDeletedControl pControl
  answer error "The control no longer exists. Would you like to refresh the tree?" with "No" or "Yes"
  if it is "Yes" then
    _refreshFirstExistingParentInView pControl
  end if
end _alertUserOfDeletedControl


command DisplayActionMenu pObject, pEmbeddableViewKind
  local tMenu, tShowHideOption

  # Don't show menu if object doesn't exist
  if there is not a pObject then
    put empty into pObject
  end if


  if word 1 of pObject is not among the items of "stack,card" then
    if the visible of pObject then
      put "Hide Control/|hide control" into tShowHideOption
    else
      put "Show Control/|show control" into tShowHideOption
    end if
  end if

  switch word 1 of pObject
    case ""
      put "(Object no longer exists" into tMenu
      break
    case "stack"
      put "Open/|open" & cr & \
          "Open Property Inspector/|open property inspector" & cr & \
          "-" & cr & \
          "Copy Long ID/|copy long id" & cr & \
          "Copy Stack/|copy stack" & cr & \
          _enableMenuLine("Paste Object/|paste object", "objects" is among the keys of the clipboarddata) & cr & \
          "-" & cr & \
          "Refresh controls/|refresh children" & cr & \
          "-" & cr & \
          "Reveal stack file/|reveal stack file" into tMenu

      if the selectedText of button "UIType" is "Embeddable Views" then
        put cr & "-" after tMenu
        put cr & _enableMenuLine("Add View to Current Card/|add embeddable view to card", the topstack is not empty) after tMenu
        put cr & _enableMenuLine("Add View to Current Group/|add embeddable view to selected group", word 1 of the selectedObject is "group") after tMenu
      end if
      break

    case "card"
      put "Open/|open" & cr & \
          "Open Property Inspector/|open property inspector" & cr & \
          "-" & cr & \
          "Copy Card/|copy card" & cr & \
          "Copy Name/|copy name" & cr & \
          "Copy Long ID/|copy long id" & cr & \
          "Cut Card/|cut card" & cr & \
          _enableMenuLine("Paste Object/|paste object", "objects" is among the keys of the clipboarddata) & cr & \
          "-" & cr & \
          "Refresh controls/|refresh children" & cr & \
          "-" & cr & \
          "Move Up/|move card up" & cr & \
          "Move Down/|move card down" into tMenu
      break

    case "group"
      put "Select/|select" & cr & \
          "Open Property Inspector/|open property inspector" & cr & \
          "-" & cr & \
          tShowHideOption & cr & \
          "-" & cr & \
          "Copy Group/|copy control" & cr & \
          "Copy Name/|copy name" & cr & \
          "Copy Long ID/|copy long id" & cr & \
          "Cut Group/|cut control" & cr & \
          _enableMenuLine("Paste Object/|paste object", "objects" is among the keys of the clipboarddata) & cr & \
          "-" & cr & \
          "Refresh controls/|refresh children" & cr & \
          "-" & cr & \
          "Move Up/|move control up" & cr & \
          "Move Down/|move control down" into tMenu

          if pEmbeddableViewKind is not empty then
            put cr & "Open Embeddable View/|open embeddable view" after line 2 of tMenu
          end if
      break

    default
      put "Select/|select" & cr & \
          "Open Property Inspector/|open property inspector" & cr & \
          "-" & cr & \
          tShowHideOption & cr & \
          "-" & cr & \
          "Copy Control/|copy control" & cr & \
          "Copy Name/|copy name" & cr & \
          "Copy Long ID/|copy long id" & cr & \
          "Cut Control/|cut control" & cr & \
          _enableMenuLine("Paste Object/|paste object", "objects" is among the keys of the clipboarddata) & cr & \
          "-" & cr & \
          "Refresh owner controls/|refresh owner" & cr & \
          "-" & cr & \
          "Move Up/|move control up" & cr & \
          "Move Down/|move control down" into tMenu
      break
  end switch

  set the text of button "ActionMenuPopup" to tMenu
  set the uTargetObject of button "ActionMenuPopup" to pObject
  popup button "ActionMenuPopup" at the bottomleft of the target
end DisplayActionMenu


private function _enableMenuLine pMenuLine, pBoolean
  if not pBoolean then
    put "(" before word 1 of pMenuLine
  end if
  return pMenuLine
end _enableMenuLine


command ProcessSelectedAction pTarget, pAction
  local tControl

  # Global actions
  switch pAction
    case "copy long id"
      set the clipboarddata to pTarget
      break

    case "copy name"
      set the clipboarddata to the name of pTarget
      break

    case "open"
      go pTarget
      break

    case "select"
      go CardOf(pTarget)
      select pTarget
      break

    case "show control"
      show pTarget
      break

    case "hide control"
      hide pTarget
      break

    case "copy card"
    case "copy control"
      copy pTarget
      break

    case "cut control"
    case "cut card"
      put the long id of the owner of pTarget into tControl
      cut pTarget
      _refreshControlChildrenInView tControl
      break

    case "paste object"
      # Process in time in case entire DataView is redrawn
      local tIsExpanded
      put the dvNodeIsExpanded[pTarget] of group "Stacks" into tIsExpanded
      send "_processPasteObject pTarget, tIsExpanded" to me in 0 seconds
      break

    case "open property inspector"
      revIDEOpenInspectorForObjects pTarget
      break

    case "move control up"
      _moveControlUp pTarget
      break

    case "move control down"
      _moveControlDown pTarget
      break

    case "refresh children"
      dispatch "RefreshRowChildren" to group "Stacks" with item 1 of the dvHilitedRow of group "Stacks"
      break
  end switch

  # Control specific actions
  switch word 1 of pTarget
    case "stack"
      _processStackAction pTarget, pAction
      break

    case "card"
      _processCardAction pTarget, pAction
      break

    case "group"
      _processGroupAction pTarget, pAction
      break

    default
      _processControlAction pTarget, pAction
      break
  end switch
end ProcessSelectedAction


command _processPasteObject pControl, pIsExpanded
  if word 1 of pControl is "stack" then
    go pControl
  else
    go CardOf(pControl)
  end if
  _pasteObjectAfterControl pControl, pIsExpanded
end _processPasteObject


private command _processStackAction pTarget, pAction
  switch pAction
    case "copy stack"
      copy pTarget
      break

    case "reveal stack file"
      set the itemDelimiter to "/"
      launch document item 1 to -2 of the effective filename of pTarget
      break

    case "add embeddable view to card"
      uiInsertEmbeddableView the short name of pTarget, the long id of this card of the topstack
      break

    case "add embeddable view to selected group"
      uiInsertEmbeddableView the short name of pTarget, the long id of the selectedObject
      break
  end switch
end _processStackAction


private command _processCardAction pTarget, pAction
  local tControl

  switch pAction
    case "move card up"
      _moveCardUp pTarget
      break
    case "move card down"
      _moveCardDown pTarget
      break
  end switch
end _processCardAction


private command _processGroupAction pTarget, pAction
  switch pAction
  case "open embeddable view"
    go stack (the uEmbeddableViewKind of pTarget)
    break
  end switch
end _processGroupAction


private command _processControlAction pTarget, pAction
  switch pAction
    case "refresh owner"
      _refreshControlParentInView pTarget
      break
  end switch
end _processControlAction


private command _moveControlUp pControl
  local tAnchorLayer, tSiblingControl
  local tMoveControl = false

  put the layer of pControl into tAnchorLayer
  if there is a control (tAnchorLayer-1) of CardOf(pControl) then
    put the long id of control (tAnchorLayer-1) of CardOf(pControl) into tSiblingControl
  end if

  if tSiblingControl is not empty then
    put true into tMoveControl

    if word 1 of tSiblingControl is "group" then
      put the long id of the owner of pControl is tSiblingControl into tMoveControl
    else if the owner of tSiblingControl is not the owner of pControl then
      put the long id of the owner of tSiblingControl into tSiblingControl
    end if
  end if

  if tMoveControl then
    lock screen
    relayer pControl before tSiblingControl
    _refreshControlParentInView pControl
    _selectControlRow pControl
    unlock screen
  else
    beep
  end if

end _moveControlUp


private command _moveControlDown pControl
  local tAnchorLayer, tSiblingControl
  local tMoveControl = false

  put the layer of pControl into tAnchorLayer
  if word 1 of pControl is "group" then
    put _nextGroupSibling(pControl) into tSiblingControl
  else if there is a control (tAnchorLayer+1) of CardOf(pControl) then
    put the long id of control (tAnchorLayer+1) of CardOf(pControl) into tSiblingControl
  end if

  if tSiblingControl is not empty then
    put the owner of tSiblingControl is the owner of pControl into tMoveControl
  end if

  if tMoveControl then
    lock screen
    relayer pControl after tSiblingControl
    _refreshControlParentInView pControl
    _selectControlRow pControl
    unlock screen
  else
    beep
  end if

end _moveControlDown


private command _moveCardDown pCard
  if the number of pCard is not the number of cards of the owner of pCard then
    set the number of pCard to the number of pCard + 1

    lock screen
    _refreshControlParentInView pCard
    _selectControlRow pCard
    unlock screen
  else
    beep
  end if
end _moveCardDown


private command _moveCardUp pCard
  if the number of pCard is not 1 then
    set the number of pCard to the number of pCard - 1

    lock screen
    _refreshControlParentInView pCard
    _selectControlRow pCard
    unlock screen
  else
    beep
  end if
end _moveCardUp


/**
Summary: Returns the next control on the card that is a sibling of a group.

Returns: nothing
*/
private function _nextGroupSibling pControl
  local tCard, tOwner

  put CardOf(pControl) into tCard
  put the long id of the owner of pControl into tOwner

  repeat with i = the layer of pControl + 1 to the number of controls of tCard
    if the long id of the owner of control i of tCard is tOwner then
      return the long id of control i of tCard
    end if
  end repeat
  return empty
end _nextGroupSibling


private command _refreshControlChildrenInView pControl
  local tRow

  put the dvRowOfId[pControl] of group "Stacks" into tRow
  if tRow > 0 then
    dispatch "RefreshRowChildren" to group "Stacks" with tRow
  end if
end _refreshControlChildrenInView


private command _refreshControlParentInView pControl
  local tRow, tParentRow

  put the dvRowOfId[pControl] of group "Stacks" into tRow
  if tRow > 0 then
    put the dvRowParentRow[tRow] of group "Stacks" into tParentRow
    if tParentRow > 0 then
      dispatch "RefreshRowChildren" to group "Stacks" with tParentRow
    end if
  end if
end _refreshControlParentInView


private command _refreshFirstExistingParentInView pControl
  local tRow, tParentRow
  local tRefreshEntireTree = "false"

  put the dvRowOfId[pControl] of group "Stacks" into tRow

  repeat forever
    if tRow > 0 then
      put the dvRowParentRow[tRow] of group "Stacks" into tParentRow
      if tParentRow > 0 then
        put the dvRowId[tParentRow] of group "Stacks" into pControl
        if there is a pControl then
          dispatch "RefreshRowChildren" to group "Stacks" with tParentRow
          exit repeat
        else
          put tParentRow into tRow
        end if
      else
        put true into tRefreshEntireTree
      end if
    else
      put true into tRefreshEntireTree
    end if

    if tRefreshEntireTree then
      # refresh entire view
      PopulateUIStacks
      exit repeat
    end if
  end repeat
end _refreshFirstExistingParentInView


private command _selectControlRow pControl
  local tRow

  put the dvRowOfId[pControl] of group "Stacks" into tRow
  if tRow > 0 then
    set the dvHilitedRow of group "Stacks" to tRow
  end if

end _selectControlRow


private command _pasteObjectAfterControl pControl, pIsExpanded
  local tNewControl, tControlId, tParentControl, tParentRow
  local tDefaultStack

  lock screen
  select empty
  paste
  put it into tNewControl
  put the short id of tNewControl into tControlId

  # Make sure this stack is target after a paste occurs.
  # Pasting a stack would change the defaultStack.
  put the defaultStack into tDefaultStack
  set the defaultStack to the short name of the owner of me

  switch word 1 of tNewControl
    case "stack"
      # refresh entire tree
      break
    case "card"
      local tIndex

      if word 1 of pControl is "stack" then
        put the number of cards of pControl + 1 into tIndex
      else
        put CardOf(pControl) + 1 into tIndex
      end if
      set the number of tNewControl to tIndex
      put StackOf(pControl) into tParentControl
      break

    default
      # relayer new control
      switch word 1 of pControl
         case "stack"
          # make first object
          relayer tNewControl to back of this card of pControl
          put pControl into tParentControl
          break

        case "card"
          # make first object
          relayer tNewControl to back of pControl
          put pControl into tParentControl
          break

        case "group"
          if pIsExpanded then
            relayer tNewControl to back of pControl
            put pControl into tParentControl
          else
            relayer tNewControl after pControl
            put the long id of the owner of pControl into tParentControl
          end if
          break

        default
          relayer tNewControl after pControl
          put the long id of the owner of pControl into tParentControl
          break
      end switch
  end switch

  if tParentControl is not empty then
    # Adjust control ref after relayering
    if word 1 of tNewControl is not among the items of "stack,card" then
      put the long id of control id tControlId of tParentControl into tNewControl
    end if

    put the dvRowOfId[tParentControl] of group "Stacks" of me into tParentRow
    if tParentRow > 0 then
      dispatch "RefreshRowChildren" to group "Stacks" of me with tParentRow
      set the dvHilitedId of group "Stacks" of me to tNewControl
    end if
  else
    PopulateUIStacks
  end if

  unlock screen

  set the defaultStack to tDefaultStack
end _pasteObjectAfterControl


command uiInsertEmbeddableView pStackShortName, pTargetObject
  local tViewKind

  if there is a pTargetObject then
    put pStackShortName into tViewKind
    embedViewsCreateViewInstance tViewKind, tViewKind, pTargetObject
  end if
end uiInsertEmbeddableView


private function createRootStackNodes
  local tUIKey, tStacksA, tStackA, tNodeA, tNodesA, tIndex

  put the selectedText of button "UIType" into tUIKey
  -- filename
  -- key
  -- name
  -- encrypt
  if tUIKey is "open stacks" then
    local tStack, i

    repeat for each line tStack in the openstacks
      if not filterOutStack(tStack) then
        add 1 to i
        put tStack into tStacksA[i]["name"]
      end if
    end repeat
  else
    put SortArrayByKey(levureGetUIStacks(tUIKey), "name") into tStacksA
  end if

  repeat for each element tStackA in tStacksA
    put empty into tNodeA
    put the long id of stack tStackA["name"] into tNodeA["id"]
    put tStackA["name"] into tNodeA["name"]
    put the name of stack tStackA["name"] into tNodeA["control name"]
    put "stack" into tNodeA["type"]
    put sNodeExpandedCacheA[tNodeA["id"]] into tNodeA["expanded"]
    put false into tNodeA["is leaf"]

    if tNodeA["expanded"] then
      put createNodesForStack(tNodeA["id"]) into tNodeA["children"]
    else
      put empty into tNodeA["children"]
    end if

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
    put sNodeExpandedCacheA[tNodeA["id"]] into tNodeA["expanded"]
    put false into tNodeA["is leaf"]

    if tNodeA["expanded"] then
      put createNodesForStack(tNodeA["id"]) into tNodeA["children"]
    else
      put empty into tNodeA["children"]
    end if

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  repeat for each line tCardId in the cardIds of pStackRef
    put empty into tNodeA
    put the long id of card id tCardId of pStackRef into tNodeA["id"]
    put the short name of card id tCardId of pStackRef into tNodeA["name"]
    put the name of card id tCardId of pStackRef into tNodeA["control name"]
    put "card" into tNodeA["type"]
    put sNodeExpandedCacheA[tNodeA["id"]] into tNodeA["expanded"]
    put false into tNodeA["is leaf"]

    if tNodeA["expanded"] then
      put createNodesForCardOrGroup(tNodeA["id"]) into tNodeA["children"]
    else
      put empty into tNodeA["children"]
    end if

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
    put _correctCardIdInBackgoundGroups(the long id of control id tControlId of pControlRef, \
          pControlRef) into tNodeA["id"]

    put the short name of control id tControlId of pControlRef into tNodeA["name"]
    put the name of control id tControlId of pControlRef into tNodeA["control name"]
    put word 1 of tNodeA["id"] into tNodeA["type"]
    put sNodeExpandedCacheA[tNodeA["id"]] into tNodeA["expanded"]
    put tNodeA["type"] is not "group" into tNodeA["is leaf"]

    if not tNodeA["is leaf"] and tNodeA["expanded"] then
      put createNodesForCardOrGroup(tNodeA["id"]) into tNodeA["children"]
    else
      put empty into tNodeA["children"]
    end if

    add 1 to tIndex
    put tNodeA into tNodesA[tIndex]
  end repeat

  return tNodesA
end createNodesForCardOrGroup


/**
Summary: Fix card in controls in a background group.

Parameters:
pControl: The control that may have an invalid card id.
pReferenceControl: A control known to have the correct card id.

Description:
For background groups (and any children controls) the card id must be updated
because the `long id` of the control will have the id of the current card.
This will lead to duplicate `id`s in the tree. If the group is shown in the tree
more than once than only the last instance will display data.

Returns: id
*/
private function _correctCardIdInBackgoundGroups pControl, pReferenceControl
  local tCardId

  get matchText(pReferenceControl, "card id ([0-9]+)", tCardId)
  put replacetext(pControl, "card id ([0-9]+)", "card id" && tCardId) into pControl
  return pControl
end _correctCardIdInBackgoundGroups


/**
Summary: Determines if a stack should be filtered out of the open stacks listing.

Returns: Boolean
*/
private function filterOutStack pStackName
  return pStackName is the short name of the owner of me or \
        not the visible of stack pStackName or \
        pStackName begins with "rev" or \
        pStackName begins with "com.livecode." or \
        pStackName is "Message Box"
end filterOutStack


setProp uIsNodeExpanded[pNodeId] pBoolean
  if pBoolean then
    put true into sNodeExpandedCacheA[pNodeId]
  else
    delete local sNodeExpandedCacheA[pNodeId]
  end if
end uIsNodeExpanded


getProp uIsNodeExpanded[pNodeId]
  return sNodeExpandedCacheA[pNodeId] is true
end uIsNodeExpanded

