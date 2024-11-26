# OpenAttribution iOS SDK

Under construction. If you'd like to help feel free to send a PR or join the Dicsord. More info on [OpenAttribution.dev](https://openattribution.dev) or [OpenAttribution GitHub](https://github.com/OpenAttribution).

## MVP Goal

To have a fully functional SDK which can be used to track and attribute installs, events and revenue for iOS back to an OpenAttribution server.

## MVP features

- Library installable via Cocoapods (? is this the right approach?) or other dependency manager for mac/ios
- user input server endpoint ie `https://demo.openattribution.dev`
- event tracking with params
- documentation for how to use and next steps

### Event tracking and params details
Events:
- Basic app_open tracking and attributing
- Basic event tracking
- Basic revenue tracking

### ExistingOpenAttribution Params:

These are very loosely defined in:
https://github.com/OpenAttribution/Open-Attribution/blob/main/apps/postback-api/config/dimensions.py

```python
# In App key values
APP_EVENT_UID = "event_uid" # UUID4, unique per tracking call
APP_EVENT_ID = "event_id" # app_open, event_name
APP_EVENT_TIME = "event_time" # epoch timestamp in ms
APP_EVENT_REV = "revenue" # not sure if this is float or string
APP_OA_USER_ID = "oa_uid" # UUID4, unique per user
```

#### Sample postback payload
```
https://demo.openattribution.dev/collect/events/xxxxxxxxxapp1?ifa=00000000-0000-0000-0000-000000000000&event_time=1732003510046&event_uid=5730a99e-b009-41da-9d52-1315e26941c1&event_id=app_open&oa_uid=3bd9e091-fa6e-4b91-8dd1-503f8d4fe8f2
```

### New Potential iOS User Params:

```json
 {
   "accessGroup": "xxx",
   "appleAttributionToken": {
     "collectionTimestamp": "1732338310.789649",
     "token": "xxx"
   },
   "bundleIdentifier": "com.myapp.myapp",
   "bundleShortVersion": "1.0",
   "bundleVersion": "1",
   "creationTimestamp": 754276487.956457,
   "executableCreationDate": "1732583673.0",
   "executableName": "MyName",
   "identifierForVendor": "IDFV..",
   "libraryDirectoryCreationDate": "1732322446.35071",
   "locale": "en_US",
   "networkPathSummary": {
     "interfaces": [
       {
         "name": "en0",
         "type": "wifi"
       }
     ],
     "status": "satisfied"
   },
   "screen": {
     "height": 1334,
     "scale": 2,
     "width": 750
   },
   "sdkVersion": "1.0.0",
   "sysctl": {
     "cpusubtype": 2,
     "cputype": 123,
     "machine": "iPhone12,8",
     "model": "D79AP",
     "osversion": "22B92"
   },
   "systemVersion": "18.1.1",
   "urlSchemes": [],
   "userAgent": "UA...",
   "utsname": {
     "machine": "iPhone12,8",
     "nodename": "localhost",
     "release": "24.1.0",
     "sysname": "Darwin",
     "version": "Darwin Kernel Version 24.2.0.."
   }
 }
```
