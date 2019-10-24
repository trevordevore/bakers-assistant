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

    put createNodesForControlChildren(tRowId) into tNodesA
    set the dvRowChildren[pRow] of me to tNodesA
    SetRowIsExpanded pRow, empty, true

    set the uIsNodeExpanded[tRowId] of this card to true
  end if
end ToggleRow


command RefreshRowChildren pRow
  local tNodesA

  put createNodesForControlChildren(the dvRowId[pRow] of me) into tNodesA
  set the dvRowChildren[pRow] of me to tNodesA
  RefreshViewRows
end RefreshRowChildren


/**
Summary: Request from DataView Tree for node data to display.

Returns: nothing
*/
command DataForNode pNodeA, pRow, @rDataA, @rTemplate
  local tTooltip, tBehavior

  put pNodeA into rDataA

  put rDataA["type"] is "stack" and the selectedText of button "UIType" is "Embeddable Views" \
        into rDataA["can insert"]

  put the uEmbeddableViewKind of rDataA["id"] into rDataA["embeddable view kind"]

  try
    put the long name of rDataA["id"] into tTooltip
    if word 1 of rDataA["id"] is not "stack" then
      put cr & "id:" && the short id of rDataA["id"] after tTooltip
    end if
    put the behavior of rDataA["id"] into tBehavior
    repeat while tBehavior is not empty
      put cr & "   behavior:" && tBehavior && "[" & the long name of tBehavior & "]" after tTooltip
      put the behavior of tBehavior into tBehavior
    end repeat
  catch e
    # control may no longer exist
    put e
  end try
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
