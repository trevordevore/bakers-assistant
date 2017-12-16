script "com.bakersast.card"
constant kDatabaseURL = "https://raw.githubusercontent.com/trevordevore/bakers-assistant/master/database/helpers.json"

local sDatabase


on preOpenCard
  libURLSetStatusCallback "MonitorDownloadActivity"
  DownloadDatabase
end preOpenCard


on closeCard
  libURLSetStatusCallback empty
end closeCard


command MonitorDownloadActivity pQueue, pUrl, pUrlStatus
  put pUrl && pUrlStatus
end MonitorDownloadActivity


command DownloadDatabase
  local tError

  load url kDatabaseURL with message "DatabaseDownloaded"
  put the result into tError

  # TODO: Process error
end DownloadDatabase


command DatabaseDownloaded pURL, pURLStatus
  switch pURLStatus
    case "cached"
      local tJson

      put url pURL into tJson
      put JsonImport(tJson) into sDatabase
      unload url pURL

      DisplayDatabase
      break
  end switch

  # TODO: Process error
end DatabaseDownloaded


command DisplayDatabase pDatabase
  # todo: filter dataset as needed
  set the dgData of group "Helpers" to sDatabase
end DisplayDatabase


command uiInstallHelper
  local tIndex, tHelperA
  local tError

  put the dgHilitedIndex of group "Helpers" into tIndex
  put the dgDataOfIndex[tIndex] of group "Helpers" into tHelperA

  load url tHelperA["package"] with message "HelperDownloaded"
  put the result into tError

  # TODO: Process error
end uiInstallHelper


command HelperDownloaded pURL, pURLStatus
  switch pURLStatus
    case "cached"
      # todo: decompress helper archive appropriate folder
      # todo: add to app.yml
      unload url pURL
      break
  end switch
end HelperDownloaded
