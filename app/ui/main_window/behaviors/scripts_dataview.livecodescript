script "com.bakersast.dataview.scripts" with behavior "DataView Array Controller Behavior"

on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "ScriptLines"
        edit script of stack the uSelectedStackFilename of me
        break
      case "Reveal"
        set the itemDelimiter to "/"
        launch document item 1 to -2 of the uSelectedStackFilename of me
        break
    end switch
  end if
end mouseUp


getProp uSelectedStackFilename
  return GetValueForKeyInRow(the dvHilitedRow of me, "filename")
end uSelectedStackFilename
