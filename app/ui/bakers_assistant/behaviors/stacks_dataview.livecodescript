script "com.bakersast.dataview.stacks" with behavior "DataView Tree Behavior"


on selectedRowChanged pRow, pPreviousRow
  uiPreviewControl the dvRowId[pRow] of me
end selectedRowChanged


command ToggleRow pRow
  local tRowId

  put the dvRowId[pRow] of me into tRowId

  if there is not a tRowId then
    uiAlertUserOfDeletedControl tRowId
    return empty
  end if

  if the dvRowIsExpanded[pRow] of me then
    set the dvRowChildren[pRow] of me to empty
    SetRowIsExpanded pRow, empty, false

    set the uIsNodeExpanded[tRowId] of this card to false
  else
    local tNodesA
    local tLevelsDown = 0

    put createNodesForControlChildren(tRowId) into tNodesA

    # For stacks, cards, or groups with a single card expand the card children
    # For cards with a single group expand the group children
    if word 1 of the dvRowId[pRow] of me is among the items of "stack,card,group" then
      if the number of elements of tNodesA is 1 \
            and word 1 of tNodesA[1]["id"] is among the items of "stack,card,group" then

        if not the uIsNodeExpanded[tNodesA[1]["id"]] of this stack then
          put createNodesForControlChildren(tNodesA[1]["id"]) into tNodesA[1]["children"]
          set the uIsNodeExpanded[tNodesA[1]["id"]] of this card to true
        end if

        put 1 into tLevelsDown
      end if
    end if

    set the dvRowChildren[pRow] of me to tNodesA

    SetRowIsExpanded pRow, tLevelsDown, true

    set the uIsNodeExpanded[tRowId] of this card to true
  end if
end ToggleRow


command RefreshRowChildren pRow
  local tNodesA

  put createNodesForControlChildren(the dvRowId[pRow] of me) into tNodesA
  set the dvRowChildren[pRow] of me to tNodesA

  lock screen
  RefreshViewRows
  # Update preview
  selectedRowChanged the dvHilitedRows of me
  unlock screen
end RefreshRowChildren


/**
Summary: Request from DataView Tree for node data to display.

Returns: nothing
*/
command DataForNode pNodeA, pRow, @rDataA, @rTemplate
  local tTooltip, tBehavior

  put pNodeA into rDataA

  # Control information
  put there is a rDataA["id"] into rDataA["control exists"]

  if rDataA["control exists"] then
    put the uEmbeddableViewKind of rDataA["id"] into rDataA["embeddable view kind"]

    put the long name of rDataA["id"] into tTooltip
    if word 1 of rDataA["id"] is not "stack" then
      put cr & "id:" && the short id of rDataA["id"] after tTooltip
    end if
  else
    put "Control no longer exists" into rDataA["control name"]
  end if

  # Behavior information
  if rDataA["control exists"] then
    put the behavior of rDataA["id"] into tBehavior
    repeat while tBehavior is not empty
      if there is a tBehavior then
        put cr & "   behavior:" && tBehavior && "[" & the long name of tBehavior & "]" after tTooltip
        put the behavior of tBehavior into tBehavior
      else
        put cr & "   behavior:" && tBehavior && "[" & tBehavior && "(does not exist)]" after tTooltip
        exit repeat
      end if
    end repeat
  end if

  put tTooltip into rDataA["tooltip"]

  if pNodeA["type"] is among the items of "stack,card,group" then
    put "expandable" into rTemplate
  else
    put "leaf" into rTemplate
  end if
end DataForNode


on mouseDoubleUp pBtnNum
  local tControl

  if pBtnNum is 1 and the dvRowControl of the target is not empty then
    put the uSelectedControlId of me into tControl
    uiGoToControl tControl
  end if
end mouseDoubleUp


on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "Toggle"
        ToggleRow the dvRow of the dvRowControl of the target
        break
    end switch
  end if
end mouseUp


getProp uSelectedControlName
  return GetValueForKeyInRow(the dvHilitedRow of me, "name")
end uSelectedControlName


getProp uSelectedControlId
  return GetValueForKeyInRow(the dvHilitedRow of me, "id")
end uSelectedControlId
