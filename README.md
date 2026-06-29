# Perfect Logging (File & Remote)

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

> **Swift 6 resurrection note.** This package has been rebuilt on top of
> [`apple/swift-log`](https://github.com/apple/swift-log). PerfectLogger now provides a
> friendly Perfect-style façade (`LogFile`) plus two custom `LogHandler` backends
> (`FileLogHandler`, `RemoteLogHandler`) that you bootstrap into the standard
> swift-log system. Libraries can log against the plain swift-log `Logger`
> façade and stay backend-agnostic; applications decide where the logs go.

Using the `PerfectLogger` module, events can be logged to the console, to a file,
and/or shipped to a remote collector — all through swift-log's `LogHandler` system.

## Using in your project

Add the dependency to your project's `Package.swift`:

``` swift
.package(url: "https://github.com/taplin/Perfect-Logger.git", from: "4.0.0"),
```

…and add `PerfectLogger` to your target's dependencies. Then import it:

``` swift
import PerfectLogger
```

## Bootstrapping

Call `PerfectLogger.bootstrap(...)` once, early in app startup. It wires any
combination of console, file, and remote handlers into swift-log's global
`LoggingSystem` (which may only be bootstrapped a single time per process):

``` swift
PerfectLogger.bootstrap(
    console: true,                       // echo to stdout
    file: "/var/log/myapp.log",          // append structured lines to a file
    remoteServer: "https://logs.example.com",
    remoteToken: "<your token>",
    level: .info                         // minimum level for all handlers
)
```

Every argument except `console` is optional — pass only what you need.

## Friendly façade: `LogFile`

`LogFile` keeps the original ergonomic Perfect surface. Each call returns a
reusable **event id** so related events can be correlated:

``` swift
let eid = LogFile.warning("payment retry scheduled")
LogFile.critical("payment failed", eventid: eid)   // same id → linked events
```

With the file handler's default options the file receives:

```
[WARNING] [62f940aa-f204-43ed-9934-166896eda21c] [2026-06-21 15:18:02 GMT-05:00] payment retry scheduled
[CRITICAL] [62f940aa-f204-43ed-9934-166896eda21c] [2026-06-21 15:18:02 GMT-05:00] payment failed
```

The returned eventid is `@discardableResult`, so it can be ignored when not needed.

`LogFile` delegates to a swift-log `Logger`. To gate output or retarget it without
re-bootstrapping, set `LogFile.logger` or `LogFile.logger.logLevel`.

## Logging from a library (swift-log façade)

Libraries should log against a plain swift-log `Logger` and let the host app
choose the backend — no hard dependency on the file/remote handlers:

``` swift
import Logging

let logger = Logger(label: "com.example.MyLibrary")
logger.error("connection failed", metadata: ["eventid": "\(UUID().uuidString)"])
```

## File line format: `LogOptions`

`FileLogHandler` controls its prefix fields via `LogOptions`:

``` swift
FileLogHandler(label: "app", path: "/var/log/app.log", options: .default)
// "[ERROR] [<eventid>] [2026-06-21 15:18:02 GMT-05:00] message"

FileLogHandler(label: "app", path: "/var/log/app.log", options: .none)
// "message"

FileLogHandler(label: "app", path: "/var/log/app.log", options: [.priority, .timestamp])
// "[ERROR] [2026-06-21 15:18:02 GMT-05:00] message"
```

The event id is read from the `eventid` metadata key (which `LogFile` sets
automatically).

## Remote logging

`RemoteLogHandler` POSTs each event to `<server>/api/v1/log/<token>` as JSON,
fire-and-forget (a failed POST never blocks or throws into the call site).
Wire it up via `bootstrap(remoteServer:remoteToken:)` above, or construct it
directly to combine with other handlers using swift-log's `MultiplexLogHandler`.

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
