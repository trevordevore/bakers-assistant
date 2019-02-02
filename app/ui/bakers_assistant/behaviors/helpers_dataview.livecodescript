script "com.bakersast.dataview.helpers" with behavior "DataView Array Controller Behavior"

on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "Reveal"
        launch document the uSelectedStackFilename of me
        break
    end switch
  end if
end mouseUp


getProp uSelectedStackFilename
  return GetValueForKeyInRow(the dvHilitedRow of me, "filename")
end uSelectedStackFilename

