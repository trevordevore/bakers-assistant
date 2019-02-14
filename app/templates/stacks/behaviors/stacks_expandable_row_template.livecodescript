script "Stacks expandable Row Template Behavior"
/**
Summary: Fill in the controls in the row group with the data associated with the row.

Parameters:
pDataA: An array containing the data associated with the row.
pRow: The row number that this row control is associated with.

Returns: nothing
*/
on FillInData pDataA, pRow
  local tLabel, tExpandColor

  put "80,80,80" into tExpandColor

  put pDataA["control name"] into tLabel
  if pDataA["is embeddable view"] then
    put " [embedded]" after tLabel
  end if

  set the text of field "Label" of me to tLabel
  set the tooltip of field "Label" of me to pDataA["id"]

  if pDataA["expanded"] then
    set the iconPath of widget "Toggle" of me to the uExpandedIconPath of the dvControl of me
  else
    set the iconPath of widget "Toggle" of me to the uCollapsedIconPath of the dvControl of me
  end if
  if pDataA["type"] is "group" then
    if not the selectGroupedControls of pDataA["id"] then
      put "150,150,150" into tExpandColor
    end if
  end if

  set the foregroundColor of widget "Toggle" of me to tExpandColor

  set the visible of widget "OpenStack" of me to pDataA["type"] is among the items of "stack,card"
  set the visible of widget "Reveal" of me to pDataA["type"] is "stack"
  set the visible of widget "InsertEmbeddableView" of me to pDataA["can insert"]
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

  set the left of widget "Toggle" of me to item 1 of pControlRect + 7 + tInset

  set the right of widget "OpenStack" of me to item 3 of pControlRect - 10
  set the right of widget "InsertEmbeddableView" of me to the left of widget "OpenStack" of me - 8
  if the visible of widget "InsertEmbeddableView" of me then
    set the right of widget "Reveal" of me to the left of widget "InsertEmbeddableView" of me - 8
  else
    set the right of widget "Reveal" of me to the left of widget "OpenStack" of me - 8
  end if

  put the rect of field "Label" of me into tRect
  put the right of widget "Toggle" of me into item 1 of tRect
  put the left of widget "Reveal" of me - 8 into item 3 of tRect
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

end dvHilite
