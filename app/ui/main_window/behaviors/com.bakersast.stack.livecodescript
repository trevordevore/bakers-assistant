script "com.bakersast.stack"


on saveStackRequest
  repeat for each line tCard in the cardNames of me
    go card tCard
    dispatch "_resetUI" to card tCard
  end repeat

  lock messages
  go card "UI Stacks"
  set the hilitedItemNames of widget "Navigation" to "UI Stacks"
  unlock messages

  pass saveStackRequest
end saveStackRequest


command ResizeGlobalControls
  set the rect of widget "Navigation" to 20,20,the width of this card -20, 20+32
end ResizeGlobalControls


function SortArrayByKey pArrayA, pKey
  local tElementA, tKeys, i
  local tSortedA

  repeat for each element tElementA in pArrayA
    add 1 to i
    put i & "," && tElementA[pKey] & cr after tKeys
  end repeat

  sort lines of tKeys by item 2 to -1 of each
  put 0 into i

  repeat for each line tKey in tKeys
    add 1 to i
    put pArrayA[item 1 of tKey] into tSortedA[i]
  end repeat

  return tSortedA
end SortArrayByKey


function ScaleDimensionsToFit pWidth, pHeight, pMaxWidth, pMaxHeight, pMaxRatio, pConstrain
  local theCurrentRatio = 0.0
  local theNewRatio = 0.0
  local theDimensions = "0,0"

  if pMaxWidth is not a number or pMaxWidth < 1 then put pWidth into pMaxWidth
  else if pMaxHeight is not a number or pMaxHeight < 1 then put pHeight into pMaxHeight

  if pWidth <=0 or pHeight <=0 or pMaxWidth <=0 or pMaxHeight <= 0 then return pWidth & comma & pHeight

  put pHeight / pWidth into theCurrentRatio
  put pMaxHeight / pMaxWidth into theNewRatio

  if pConstrain is not empty and pConstrain > 0 then
    if theNewRatio > theCurrentRatio then --> WIDTH IS GUIDE
      put (pMaxWidth / pWidth) - ((pMaxWidth / pWidth) mod pConstrain) into pConstrain
    else
      put (pMaxHeight / pHeight) - ((pMaxHeight / pHeight) mod pConstrain) into pConstrain
    end if

    if pMaxRatio is not empty and pMaxRatio > 0 then put min(pConstrain, pMaxRatio) into pConstrain

    put round(pWidth * pConstrain) & comma & round(pHeight * pConstrain) into theDimensions
  else
    if theNewRatio > theCurrentRatio then --> WIDTH IS GUIDE
      if pMaxRatio is not empty and pMaxRatio > 0 and pMaxWidth > (pWidth * pMaxRatio) then
        put pWidth & comma & pHeight into theDimensions
      else
        put pMaxWidth & comma & round(pMaxWidth * theCurrentRatio) into theDimensions
      end if
    else
      if pMaxRatio is not empty and pMaxRatio > 0 and pMaxHeight > (pHeight * pMaxRatio) then
        put pWidth & comma & pHeight into theDimensions
      else
        put round(pMaxHeight / theCurrentRatio) & comma & pMaxHeight into theDimensions
      end if
    end if
  end if

  return theDimensions
end ScaleDimensionsToFit
