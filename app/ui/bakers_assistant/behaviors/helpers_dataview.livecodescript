script "com.bakersast.dataview.helpers" with behavior "DataView Array Controller Behavior"

on selectedRowChanged pRow
  DisplayHelperConfig the uSelectedHelperFolder of me
end selectedRowChanged


on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "Reveal"
        launch document the uSelectedHelperFolder of me
        break
    end switch
  end if
end mouseUp


getProp uSelectedHelperFolder
  return GetValueForKeyInRow(the dvHilitedRow of me, "filename")
end uSelectedHelperFolder

