script "Stacks leaf Row Template Behavior"
/**
Summary: Fill in the controls in the row group with the data associated with the row.

Parameters:
pDataA: An array containing the data associated with the row.
pRow: The row number that this row control is associated with.

Returns: nothing
*/
on FillInData pDataA, pRow
  set the text of field "Label" of me to pDataA["control name"]
  set the tooltip of field "Label" of me to pDataA["tooltip"]

  set the enabled of widget "ActionMenu" of me to pDataA["control exists"]
end FillInData


/**
Summary: Message sent when you should resize the row group to fit the viewable area.

Parameters:
pControlRect: The rect that the row control should fill.

Description:
Typically you will only use `item 3 of pControlRect` to adjust the right
side of any controls to fill the available width.

If the `viewProps["fixed row height"]` of the DataView is `false` then
you will most likely be adjusting the height of the controls in the row.

Returns: nothing
*/
on LayoutControl pControlRect
  local tLevel, tInset, tRect

  put the dvRowLevel[the dvRow of me] of me - 1 into tLevel
  put tLevel * 15 into tInset

  set the right of widget "ActionMenu" of me to item 3 of pControlRect - 10

  put the rect of field "Label" of me into tRect
  put item 1 of pControlRect + tInset + 12 + 7 into item 1 of tRect
  put the left of widget "ActionMenu" of me - 10 into item 3 of tRect
  set the rect of field "Label" of me to tRect

  set the rect of graphic "Background" of me to pControlRect
end LayoutControl


/**
Summary: Returns the long id of this group.

Description:
This property can be used in code that needs to resolve the row control
that was clicked on using `the target`.

Example:
put the dvRowControl of the target into tRowControl
put the dvRow of tRowControl into tRow

Returns: Long id
*/
getProp dvRowControl
  return the long id of me
end dvRowControl


/**
Summary: Customize the look of the row when it is hilited.

Parameters:
pHiliteColor: The color that should be used to hilite the row.
pBooelan:

Description:
By default the DataView will set the background color of the "Background"
graphic (assuming the graphic exists). If you need to customize the hilite
behavior then do so here.
*/
setProp dvHilite[pHiliteColor] pBoolean
  dispatch "RenderTreeLines" to image "TreeLines" of me with the dvRow of me, "150,150,150"
end dvHilite


on mouseDown pBtnNum
  dvMouseDown pBtnNum

  if pBtnNum is 1 then
    switch the short name of the target
      case "ActionMenu"
        if the platform is "macos" then
          DisplayActionMenu the dvRowId[the dvRow of me] of me
        end if
        break
    end switch
  end if
end mouseDown


on mouseUp pBtnNum
  if pBtnNum is 1 then
    switch the short name of the target
      case "ActionMenu"
        # LC on Windows (probably Linux too) works best if menus are shown during mouseUp
        if the platform is not "macos" then
          dvMouseUp pBtnNum
          DisplayActionMenu the dvRowId[the dvRow of me] of me
          exit mouseUp
        end if
        break
    end switch
  end if

  pass mouseUp
end mouseUp


on mouseDoubleUp pBtnNum
  if pBtnNum is 1 then
    if IsThisModifierSetActive("option") then
      local tCtrl
      put the dvRowId[the dvRow of me] of me into tCtrl
      set the visible of tCtrl to not the visible of tCtrl
      exit mouseDoubleUp
    end if
  end if

  pass mouseDoubleUp
end mouseDoubleUp
