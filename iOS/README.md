# PlayFab Multiplayer SDK for iOS

## Logging

The PlayFab Multiplayer C++ library includes logging capabilities with a configurable verbosity level. Logging configuration is defined in `PlayFabMultiplayerLogger.json` file which can be deployed as an asset along with the application.

When this file is detected by the application at runtime it will use it to enable logging as configured. The following verbosity levels are currently supported:
1. `VERBOSE` - everything
2. `INFO` - less than everything, only important messages and errors
3. `ERROR` - only errors

The logging is disabled by default, but can be enabled with "enabled" property set to `true`.

### Example configuration file

```json
{
    "enabled": false,
    "bufferSize": 262144,
    "maxNumberOfItemsInBatch": 500,
    "maxBatchWaitTimeInSeconds": 1,
    "readBufferWaitTimeInMilliseconds": 1,
    "logFolder": "/app_sandbox_storage/Documents/",
    "logLevel": "VERBOSE",
    "muLogEnabled": false,
    "maxLogFileSizeInMegabytes": 0,
    "logAreaFlags_ApiInOut": -1,
    "logAreaFlags_FnInOut": 18056,
    "logAreaFlags_Log": 20104
}
```

### Instructions

1. Connect the iOS device to a mac device.
2. Enable **FileSharing** for your application, this can be done through the **Info.plist** file of your application.
3. Open the finder application on a Mac, locate your connected iOS device section and select it.
4. Click on the "Files" tab.
4. Locate the installed application that uses PlayFab Party.
5. Copy the `PlayFabMultiplayerLogger.json` file into this application's folder.
6. Run the application.
7. See "logFolder" property of `PlayFabPartyLogger.json` and locate the output log.