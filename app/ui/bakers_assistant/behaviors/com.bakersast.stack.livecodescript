script "com.bakersast.stack"

on saveStackRequest
  local tCardId

  repeat for each line tCardId in the cardIds of me
    go card id tCardId
    dispatch "_resetUI" to card id tCardId
  end repeat

  lock messages
  go card "UI Stacks"
  set the hilitedItemNames of widget "Navigation" to "UI Stacks"
  unlock messages

  pass saveStackRequest
end saveStackRequest


on preOpenStack
  try
    local tStacksA
    put levureGetUIStacks() into tStacksA
  catch tError
    answer "The Levure framework is not currently loaded. Please load a Levure application and then open the plugin again."
    close this stack
    exit to top
  end try
end preOpenStack


/**
Summary: Prompts the user to save the stack in the plugins folder.

Description:
If the user opens this stack using `go stack URL` then it won't have a filename.
This handler will ask the user to save the stack in the user plugins folder
in such a case.

Returns: nothing
*/
on openStack
  if the environment is "development" and the filename of me is empty \
        and revEnvironmentUserPluginsPath() is not empty and there is a folder revEnvironmentUserPluginsPath() then
    answer "Would you like to save this plugin to your LiveCode plugins folder?" with "Save Plugin" or "No"
    if it is "save plugin" then
      local tError

      save me as (revEnvironmentUserPluginsPath() & "/bakers_assistant_plugin.livecode")
      put the result into tError

      if tError is empty then
        dispatch "preOpenCard" to this card
      else
        answer error "Error saving plugin:" && tError && "(" && sysError() & ")."
      end if
    end if
  end if
end openStack


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


/**
* \brief Creates a zip file from a directory. The ZIP archive should already have been opened with revZipOpenArchive.
*
* \param pZipArchivePath The path to save the zip archive to. This should already have been opened with revZipOpenArchive.
* \param pRootFolderPath The folder to save in the zip archive.
* \param pIncludeRootFolderInArchiveItemNames Pass in true to include the name of pRootFolderPath in the zip archive.
* \param pFilesToExclude Files that should not be included in the archive.
* \param pExtensionsThatArentCompressed File extensions that should be added without any compression.
* \param pFolderPath Used when calling itself recursively. Pass in empty.
*
Returns: Error message
*/
command zipAddFolderToArchive pZipArchivePath, pRootFolderPath, pIncludeRootFolderInArchiveItemNames, pFilesToExclude, pExtensionsThatArentCompressed, pFolderPath
  local tArchiveItemName, tCharNo, tError, tFile
  local tFiles, tFolder, tFolders

  put pIncludeRootFolderInArchiveItemNames is true into pIncludeRootFolderInArchiveItemNames
  set the wholeMatches to true

  replace comma with cr in pExtensionsThatArentCompressed

  if pFolderPath is empty then
    put pRootFolderPath into pFolderPath
    if pIncludeRootFolderInArchiveItemNames then
      set the itemdel to slash  # we want folder to be reflected in archive item name
      delete item -1 of pRootFolderPath
    end if
  end if

  put fileFilesInFolder(pFolderPath, true, true) into tFiles
  filter tFiles without "*/.DS_Store"
  set the itemdel to "."

  repeat for each line tFile in tFiles
    if tFile is among the lines of pFilesToExclude then next repeat

    put tFile into tArchiveItemName
    put offset(pRootFolderPath, tArchiveItemName) into tCharNo
    if tCharNo is 0 then return "file is not in expected folder"

    delete char 1 to (the number of chars of pRootFolderPath + 1) of tArchiveItemName # strip root folder up to slash (zip item names shouldn't start with a slash)

    if item -1 of tArchiveItemName is among the lines of pExtensionsThatArentCompressed then
      revZipAddUncompressedItemWithFile pZipArchivePath, tArchiveItemName, tFile
    else
      revZipAddItemWithFile pZipArchivePath, tArchiveItemName, tFile
    end if
    if the result is not empty then
      put the result into tError
      exit REPEAT
    end if
  end REPEAT

  if tError is empty then
    put fileFoldersInFolder(pFolderPath, true, true) into tFolders
    repeat for each line tFolder in tFolders
      zipAddFolderToArchive pZipArchivePath, pRootFolderPath, pIncludeRootFolderInArchiveItemNames, pFilesToExclude, pExtensionsThatArentCompressed, tFolder
      put the result into tError
      if tError is not empty then
        exit REPEAT
      end if
    end REPEAT
  end if

  return tError for error
end zipAddFolderToArchive


/**
Summary: Decompresses a ZIP archive to a folder. The ZIP archive should already have been opened with revZipOpenArchive.

Parameters:
pZipArchivePath: The path to the zip archive. This should already have been opened with revZipOpenArchive.
pOutputFolder: The folder to save the zip archive to.
pItemsToExclude: List of files that won't be extracted from the ZIP archive.
pCallbackHandler: The handler to call with progress updates.

Returns: error message
*/
command zipDecompressArchiveToFolder pZipArchivePath, pOutputFolder, pItemsToExclude, pCallbackHandler
  local tError, tFileType, tArchiveItems, tArchiveItem, tItemCount
  local i, tFilePath, tDirectoryPath, tCard

  if the last char of pOutputFolder is slash then delete the last char of pOutputFolder

  set the wholeMatches to true
  put the fileType into tFileType
  set the fileType to empty

  put revZipEnumerateItems(pZipArchivePath) into tArchiveItems
  put the number of lines of tArchiveItems into tItemCount

  repeat for each line tArchiveItem in tArchiveItems
    add 1 to i

    if tArchiveItem is among the lines of pItemsToExclude then next repeat

    put pOutputFolder & slash & tArchiveItem into tFilePath
    if the last char of tFilePath is "/" then
      ## Directory
      fileCreateAllFoldersInPath tFilePath, pOutputFolder
      put _ZipErrorMsg("creating directory" && tFilePath, the result) into tError
    else
      put fileExtractDirectory(tFilePath) into tDirectoryPath

      if tDirectoryPath is not pOutputFolder then
        fileCreateAllFoldersInPath tDirectoryPath, pOutputFolder
        put _ZipErrorMsg("creating parent directory" && tDirectoryPath, the result) into tError
      end if

      if tError is empty then
        if pCallbackHandler is not empty then
          put CardOf(the long ID of the target) into tCard
          if tCard is not empty then
            dispatch pCallbackHandler to tCard with i, tItemCount
          else
            dispatch pCallbackHandler with i, tItemCount
          end if
        end if

        revZipExtractItemToFile pZipArchivePath, tArchiveItem, tFilePath
        put _ZipErrorMsg("archive:" && tArchiveItem & ", filepath:" && tFilePath, the result) into tError
      end if
    end if

    if tError is not empty then exit REPEAT
  end REPEAT

  set the fileType to tFileType

  return tError for error
end zipDecompressArchiveToFolder


private function _ZipErrorMsg pPrefix, pError
  if pError is not empty then
    answer quote & pError & quote
    if pPrefix begins with "ziperr," then
      delete char 1 to 7 of pPrefix
    end if
    return pPrefix & ": " & pError
  else
    return empty
  end if
end _ZipErrorMsg


function CardOf pControl
  local tCharNo

  put the long ID of pControl into pControl ## force the long id

  if word 1 of pControl is "stack" then
    put empty into pControl -- has no card
  else
    if word 1 of pControl is not "card" then
      put offset(" of card ", pControl) into tCharNo
      if tCharNo > 0 then
        delete char 1 to (tCharNo + 3) of pControl
      else
        put empty into pControl
      end if
    end if
  end if
  return pControl
end CardOf


function StackOf pControl
  local theCharNo

  put the long ID of pControl into pControl ## force the long id

  if word 1 of pControl is not "stack" then
    put offset(" of stack ", pControl) into theCharNo
    if theCharNo > 0 then
      delete char 1 to (theCharNo + 3) of pControl
    else
      put empty into pControl
    end if
  end if
  return pControl
end StackOf


command fileCreateAllFoldersInPath pPath, pRootPath, pPerms
  local tError, tCheck, tPathSegment

  ## Watch for double slashes /Folder/To//Something//
  ## You will not enter a never ending loop if you aren't careful.
  _stripDoubleSlash pPath
  _stripDoubleSlash pRootPath

  ## Get rid of trailing slashes
  ## We can safely ignore UNC paths starting with "//"
  ## Neither pPath or pRootPath with values of just "//" would be valid
  repeat until the last char of pPath is not slash
    delete the last char of pPath
  end repeat
  if the number of chars of pRootPath > 1 and the last char of pRootPath is slash then
    repeat forever
      delete the last char of pRootPath
      if the last char of pRootPath is not slash or the number of chars of pRootPath is 1 then
        exit repeat
      end if
    end repeat
  end if

  ## Permissions
  if pPerms is not "shared" then put "user" into pPerms
  set the itemDelimiter to slash

  if pPath is empty or the number of items of pPath is 1 then
    put "cannot create folder (invalid path)" into tError
  end if

  ## VALIDATE pRootPath
  if tError is empty then
    if pRootPath is empty then
      put item 1 to 2 of pPath into pRootPath ## "/NODE"
    end if

    if tError is empty then
      if last char of pRootPath is not slash then put slash after pRootPath ## Makes it easier to deal with "/" path

      if not fileIsFolder(pRootPath) then
        put "root path does not exist" into tError
      end if
    end if
  end if

  ## VALIDATE ANCESTORY OF PATH
  if tError is empty then
    put char 1 to -2 of pRootPath into tCheck ## -2 gets rid of trailing slash
    if char 1 to (number of chars of tCheck) of pPath is not tCheck then
      put "path is not a child of root path" into tError
    end if
  end if

  ## CREATE FOLDERS
  if tError is empty then
    if number of items of pPath > number of items of pRootPath then
      put pRootPath & item (number of items of pRootPath + 1) of pPath into tPathSegment

      if not fileIsFolder(tPathSegment) then
        create folder tPathSegment
        if the result is not empty then
          put "error creating folder (" & the result & ")" into tError
        else
          if pPerms is "shared" then
            fileSetPermissions tPathSegment, "execute", "execute", "execute"
            if the result is not empty then
              put format("error setting permissions for folder \"%s\" (%s)", tPathSegment, line 1 of the result) into tError
            end if
          end if
        end if
      end if

      if tError is empty then
        fileCreateAllFoldersInPath pPath, tPathSegment, pPerms
        put the result into tError
      end if
    end if
  end if

  return tError
end fileCreateAllFoldersInPath


on fileSetPermissions pFile, pOwner, pGroup, pAll
  local tError, tResult

  put _escapeForShell(pFile) into pFile

  switch the platform
    case "Win32"
      /*
      Displays or changes file attributes.
      ATTRIB [+R | -R] [+A | -A] [+S | -S] [+H | -H] [[drive:][path]filename]  [/S] [/D]

      + Sets an attribute.
      - Clears an attribute.
      R Read-only file attribute.
      A Archive file attribute.
      S system file attribute.
      H Hidden file attribute.
      /S Processes files in all directories in the specified path.
      /D Processes folders as well
      */

      switch pOwner
        case "read"
          put "+r" into pOwner
          break
        case "write"
          put "-r" into pOwner
          break
      end switch
      put shell (format ("attrib %s %s", pOwner, pFile) ) into tResult
      break

    case "MacOS"
      put _executableBitFromType(pOwner) into pOwner
      put _executableBitFromType(pGroup) into pGroup
      put _executableBitFromType(pAll) into pAll
      put shell(format("chmod %u%u%u %s ", pOwner, pGroup, pAll, pFile)) into tResult
      break
  end switch

  if the result is not empty then
    put line 1 of tResult into tError
  end if

  return tError
end fileSetPermissions


private function _executableBitFromType pType
  switch pType
    case "execute"
      put 7 into pType
      break
    case "write"
      put 6 into pType
      break
    case "read"
      put 5 into pType
      break
    default
      put 0 into pType
  end switch
  return pType
end _executableBitFromType


private function _escapeForShell pStr
  local tChar, tSpecialChars

  if the platform is "win32" then
    replace "/" with "\" in pStr
    put quote & pStr & quote into pStr
  else
    put "\" & space & quote & "'`<>!;()[]?#$^&*=|" into tSpecialChars
    repeat for each char tChar in tSpecialChars
      replace tChar with ("\" & tChar) in pStr
    end repeat
  end if

  return pStr
end _escapeForShell


## Used for removing multiple slashes from folder paths
private command _stripDoubleSlash @pVariable
  local tCharNo, tPrefix

  ## Don't wipe out UNC prefixes
  if char 1 to 2 of pVariable is "//" then
    put "//" into tPrefix
    delete char 1 to 2 of pVariable
  end if

  repeat forever
    put offset("//", pVariable) into tCharNo
    if tCharNo > 0 then
      replace "//" with slash in pVariable
    else
      exit repeat
    end if
  end repeat

  if tPrefix is not empty then
    put tPrefix before pVariable
  end if

  return empty
end _stripDoubleSlash


function fileIsFolder pPath
  local tFolder, isAFolder

  put the defaultFolder into tFolder
  set the defaultfolder to pPath
  put the result is empty into isAFolder
  set the defaultFolder to tFolder

  return isAFolder
end fileIsFolder


function fileExtractDirectory pFilePath
  set the itemDelimiter to slash
  return item 1 to -2 of pFilePath
end fileExtractDirectory


function fileFilesInFolder pFolder, pFullPath, pIncludeHidden
  local tFile, tFiles, tFullFiles

  if not fileIsFolder(pFolder) then return empty
  if last char of pFolder is not slash then put slash after pFolder

  put files(pFolder) into tFiles
  if pIncludeHidden is not true then
    filter tFiles without ".*"
  else
    filter tFiles without "..*"
  end if

  if pFullPath then
    repeat for each line tFile in tFiles
      put pFolder & tFile & cr after tFullFiles
    end repeat
    delete last char of tFullFiles
    return tFullFiles
  else
    return tFiles
  end if
end fileFilesInFolder


function fileFoldersInFolder pFolder, pFullPath, pIncludeHidden
  local tFolders, tFullFolders, tFolder

  if not fileIsFolder(pFolder) then return empty
  if last char of pFolder is not slash then put slash after pFolder

  put folders(pFolder) into tFolders

  if pIncludeHidden is not true then
    filter tFolders without ".*"
  else
    filter tFolders without "..*"
  end if

  if pFullPath then
    repeat for each line tFolder in tFolders
      put pFolder & tFolder &cr after tFullFolders
    end repeat
    delete last char of tFullFolders
    return tFullFolders
  else
    return tFolders
  end if
end fileFoldersInFolder
