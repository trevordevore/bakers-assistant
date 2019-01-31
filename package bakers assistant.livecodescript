script "Package Bakers Assistant"

command PackageBakersAssistant
  local tMainStack, tStacksA, tStackA, tCard, tControl
  local tBehaviorStack

  put "Bakers Assistant" into tMainStack

  # Bring all behaviors into the stack
  put levureGetUIStacks("templates") into tStacksA
  put the long id of stack tMainStack into tStacksA[the number of elements of tStacksA+1]["filename"]

  repeat for each element tStackA in tStacksA
    repeat for each line tCard in the cardNames of stack tStackA["filename"]
      repeat with i = 1 to the number of controls of card tCard of stack tStackA["filename"]
        put the long id of control i of card tCard of stack tStackA["filename"] into tControl

        if the behavior of tControl is not empty then
          put the behavior of tControl into tBehaviorStack
          set the mainstack of tBehaviorStack to tMainStack
        end if
      end repeat
    end repeat
  end repeat

end PackageBakersAssistant
