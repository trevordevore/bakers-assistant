script "Scripts default Row Template Behavior"
/**
Summary: Fill in the controls in the row group with the data associated with the row.

Parameters:
pDataA: An array containing the data associated with the row.
pRow: The row number that this row control is associated with.

Returns: nothing
*/
on FillInData pDataA, pRow
  set the text of field "Label" of me to the short name of stack pDataA["filename"]
  set the label of graphic "ScriptLines" of me to the number of lines of the script of stack pDataA["filename"]
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
  local tRect

  # Stretch left of label field and background to fill viewable area in DataView
  set the right of graphic "ScriptLines" of me to item 3 of pControlRect - 10
  set the right of widget "Reveal" of me to the left of graphic "ScriptLines" of me - 8

  put the rect of field "Label" of me into tRect
  put the left of widget "Reveal" of me - 8 into item 3 of tRect
  set the rect of field "Label" of me to tRect

  put the rect of graphic "Background" of me into tRect
  put item 3 of pControlRect into item 3 of tRect
  set the rect of graphic "Background" of me to tRect
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
