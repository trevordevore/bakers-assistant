script "com.bakersast.dataview.stacks" with behavior "DataView Tree Behavior"

on selectedRowChanged pRow, pPreviousRow
  uiPreviewControl the dvRowId[pRow] of me
end selectedRowChanged


command ToggleRow pRow
  if the dvRowIsExpanded[pRow] of me then
    set the dvRowChildren[pRow] of me to empty
    SetRowIsExpanded pRow, empty, false
  else
    local tNodesA

    put createNodesForControlChildren(the dvRowId[pRow] of me) into tNodesA
    set the dvRowChildren[pRow] of me to tNodesA
    SetRowIsExpanded pRow, empty, true
  end if
end ToggleRow


/**
Summary: Request from DataView Tree for node data to display.

Returns: nothing
*/
command DataForNode pNodeA, pRow, @rDataA, @rTemplate
  put pNodeA into rDataA

  put rDataA["type"] is "stack" and the selectedText of button "UIType" is "Embeddable Views" \
        into rDataA["can insert"]

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
    switch word 1 of tControl
      case "card"
      case "stack"
        go tControl
        break
      default
        go CardOf(tControl)
        select tControl
    end switch
  end if
end mouseDoubleUp


on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "OpenStack"
        go (the uSelectedControlId of me)
        break
      case "Reveal"
        set the itemDelimiter to "/"
        launch document item 1 to -2 of the effective filename of (the uSelectedControlId of me)
        break
      case "InsertEmbeddableView"
        uiInsertEmbeddableViewIntoTopStack the uSelectedControlName of me
        break
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
