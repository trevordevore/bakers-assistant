script "com.bakersast.dataview.stacks" with behavior "DataView Array Controller Behavior"

on selectedRowChanged pRow, pPreviousRow
  uiPreviewUIStack
end selectedRowChanged


on mouseDoubleUp pBtnNum
  local tStackFile

  if pBtnNum is 1 and the dvRowControl of the target is not empty then
    go stack the uSelectedStackFilename of me
  end if
end mouseDoubleUp


on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "OpenStack"
        go stack the uSelectedStackFilename of me
        break
      case "Reveal"
        set the itemDelimiter to "/"
        launch document item 1 to -2 of the uSelectedStackFilename of me
        break
    end switch
  end if
end mouseUp


getProp uSelectedStackName
  return GetValueForKeyInRow(the dvHilitedRow of me, "name")
end uSelectedStackName


getProp uSelectedStackFilename
  return GetValueForKeyInRow(the dvHilitedRow of me, "filename")
end uSelectedStackFilename
