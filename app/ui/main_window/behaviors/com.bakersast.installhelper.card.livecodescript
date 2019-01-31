script "com.bakersast.card"
constant kDatabaseURL = "https://raw.githubusercontent.com/trevordevore/bakers-assistant/master/database/helpers.json"

command DownloadDatabase
  local tError

  load url kDatabaseURL with message "DatabaseDownloaded"
  put the result into tError
end DownloadDatabase


command DatabaseDownloaded pURL, pURLStatus
  local tJson, tDatabase

  switch pURLStatus
    case "cached"
      put url pURL into tJson
      put JsonImport(tJson) into tDatabase
      unload url pURL
      break
  end switch
end DatabaseDownloaded


command DisplayDatabase

end DisplayDatabase
