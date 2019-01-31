script "Download Manager"
local sDownloadsA

command downloadManagerMonitorProgress pBoolean
  if pBoolean then
    libURLSetStatusCallback "__downloadManagerMonitorUrlActivity"
  else
    libURLSetStatusCallback empty
  end if
end downloadManagerMonitorProgress


command downloadManagerQueueSet pQueue, pProp, pValue
  _ValidateQueue pQueue

  put pValue into sDownloadsA[pQueue][pProp]
end downloadManagerQueueSet


function downloadManagerQueueGet pQueue, pProp
  _ValidateQueue pQueue

  return sDownloadsA[pQueue][pProp]
end downloadManagerQueueGet


command downloadManagerAddToQueue pQueue, pURL, pMeta
  _ValidateQueue pQueue

  put pURL into line (the number of lines of sDownloadsA[pQueue]["urls"] + 1) of sDownloadsA[pQueue]["urls"]
  put pMeta into sDownloadsA[pQueue]["url metadata"][pUrl]
end downloadManagerAddToQueue


command downloadManagerStartDownloadingQueue pQueue
  _ValidateQueue pQueue

  if sDownloadsA[pQueue]["current url"] is not empty then
    return "already running"
  else
    _downloadNextUrlInQueue pQueue
    return the result
  end if
end downloadManagerStartDownloadingQueue


command downloadManagerStopAllDownloads
  repeat for each key tQueue in sDownloadsA
    if sDownloadsA[tQueue]["current url"] is not empty then
      _stopQueueDownload tQueue
    end if
  end repeat

  return empty
end downloadManagerStopAllDownloads


command downloadManagerStopDownloadingQueue pQueue
  _ValidateQueue pQueue
  _stopQueueDownload pQueue

  return empty
end downloadManagerStopDownloadingQueue


private command _stopQueueDownload pQueue
  # Put current url back into list of urls
  if sDownloadsA[pQueue]["current url"] is not empty then
    unload url sDownloadsA[pQueue]["current url"]
    if sDownloadsA[pQueue]["urls"] is not empty then
      put cr before sDownloadsA[pQueue]["urls"]
    end if
    put sDownloadsA[pQueue]["current url"] before sDownloadsA[pQueue]["urls"]

    put empty into sDownloadsA[pQueue]["current url"]
  end if

  return empty
end _stopQueueDownload


command __downloadManagerMonitorUrlActivity pUrl, pUrlStatus
  local tQueue

  repeat for each key tQueue in sDownloadsA
    if sDownloadsA[tQueue]["current url"] is pUrl then

      # dispatch message
      if sDownloadsA[tQueue]["monitor callback message"] is not empty then
        if sDownloadsA[tQueue]["monitor callback object"] is not empty then
          dispatch sDownloadsA[tQueue]["monitor callback message"] \
                to sDownloadsA[tQueue]["monitor callback object"] with tQueue, pUrl, pUrlStatus, sDownloadsA[tQueue]["url metadata"][pUrl]
        else
          dispatch sDownloadsA[tQueue]["monitor callback message"] with tQueue, pUrl, pUrlStatus, sDownloadsA[tQueue]["url metadata"][pUrl]
        end if
      end if
      exit repeat
    end if
  end repeat

  return empty
end __downloadManagerMonitorUrlActivity


command __downloadManagerFinishedCallback pUrl, pUrlStatus
  local tQueue

  repeat for each key tQueue in sDownloadsA
    if sDownloadsA[tQueue]["current url"] is pUrl then

      # dispatch message
      if sDownloadsA[tQueue]["finished callback message"] is not empty then
        if sDownloadsA[tQueue]["finished callback object"] is not empty then
          dispatch sDownloadsA[tQueue]["finished callback message"] to \
                sDownloadsA[tQueue]["finished callback object"] with tQueue, pUrl, pUrlStatus, sDownloadsA[tQueue]["url metadata"][pUrl]
        else
          dispatch sDownloadsA[tQueue]["finished callback message"] with tQueue, pUrl, pUrlStatus, sDownloadsA[tQueue]["url metadata"][pUrl]
        end if
      end if

      # check for cleanup
      switch pUrlStatus
        case "cancelled"
        case "timeout"
        case "error"
      end switch

      put empty into sDownloadsA[tQueue]["current url"]
      delete local sDownloadsA[tQueue]["url metadata"][pUrl]

      # If successful then load next url in queue
      if pUrlStatus is "cached" then
        put empty into sDownloadsA[tQueue]["last status"]
        send "_downloadNextUrlInQueue" to me in 10 milliseconds
      else
        put pUrlStatus into sDownloadsA[tQueue]["last status"]
      end if

      exit repeat
    end if
  end repeat

  return empty
end __downloadManagerFinishedCallback


private command _downloadNextUrlInQueue pQueue
  put line 1 of sDownloadsA[pQueue]["urls"] into sDownloadsA[pQueue]["current url"]
  delete line 1 of sDownloadsA[pQueue]["urls"]
  load url sDownloadsA[pQueue]["current url"] with callback "__downloadManagerFinishedCallback"
  return the result
end _downloadNextUrlInQueue


private command _ValidateQueue @xQueue
  if xQueue is empty then put "default" into xQueue
end _ValidateQueue
