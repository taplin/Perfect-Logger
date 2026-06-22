import Foundation

struct FileLogger: @unchecked Sendable {
    var threshold: LogPriority = .debug
    var options: LogOptions = .default

    private let defaultFile = "./log.log"
    private let consoleEcho = ConsoleLogger()
    private let fmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        return f
    }()

    func filelog(priority: LogPriority, _ args: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        guard priority >= threshold else { return }

        var prefixList = [String]()
        if options.contains(.priority)   { prefixList.append(priority.stringRepresentation(even: even)) }
        if options.contains(.eventId)    { prefixList.append("[\(eventid)]") }
        if options.contains(.timestamp)  { prefixList.append("[\(fmt.string(from: Date()))]") }

        let prefix = prefixList.isEmpty ? "" : "\(prefixList.joined(separator: " ")) "
        let useFile = logFile.isEmpty ? defaultFile : logFile
        let line = "\(prefix)\(args)\n"

        do {
            try appendLine(line, to: useFile)
        } catch {
            consoleEcho.critical(message: "\(error)", even)
        }
    }

    private func appendLine(_ line: String, to path: String) throws {
        let data = Data(line.utf8)
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        }
        guard let handle = FileHandle(forWritingAtPath: path) else {
            throw CocoaError(.fileWriteUnknown)
        }
        defer { handle.closeFile() }
        handle.seekToEndOfFile()
        handle.write(data)
    }

    func debug(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.debug(message: message, even)
        filelog(priority: .debug, message, eventid, logFile, even)
    }
    func info(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.info(message: message, even)
        filelog(priority: .info, message, eventid, logFile, even)
    }
    func warning(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.warning(message: message, even)
        filelog(priority: .warning, message, eventid, logFile, even)
    }
    func error(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.error(message: message, even)
        filelog(priority: .error, message, eventid, logFile, even)
    }
    func critical(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.critical(message: message, even)
        filelog(priority: .critical, message, eventid, logFile, even)
    }
    func terminal(message: String, _ eventid: String, _ logFile: String, _ even: Bool) {
        consoleEcho.terminal(message: message, even)
        filelog(priority: .terminal, message, eventid, logFile, even)
    }
}

/// Logs messages to a file (and console). All configuration via static properties.
public struct LogFile {
    private init() {}

    nonisolated(unsafe) private static var logger = FileLogger()

    /// Minimum priority to log. Messages below this level are silently dropped.
    public nonisolated(unsafe) static var threshold: LogPriority {
        get { logger.threshold }
        set { logger.threshold = newValue }
    }

    /// Controls which prefix fields (priority, eventId, timestamp) appear in each line.
    public nonisolated(unsafe) static var options: LogOptions {
        get { logger.options }
        set { logger.options = newValue }
    }

    /// Path to the log file. Defaults to `./log.log`.
    public nonisolated(unsafe) static var location = "./log.log"

    /// When `true`, shorter level names are padded so columns align.
    public nonisolated(unsafe) static var even = false

    @discardableResult
    public static func debug(_ message: @autoclosure () -> String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> String {
        logger.debug(message: message(), eventid, logFile, evenIdents)
        return eventid
    }

    @discardableResult
    public static func info(_ message: String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> String {
        logger.info(message: message, eventid, logFile, evenIdents)
        return eventid
    }

    @discardableResult
    public static func warning(_ message: String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> String {
        logger.warning(message: message, eventid, logFile, evenIdents)
        return eventid
    }

    @discardableResult
    public static func error(_ message: String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> String {
        logger.error(message: message, eventid, logFile, evenIdents)
        return eventid
    }

    @discardableResult
    public static func critical(_ message: String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> String {
        logger.critical(message: message, eventid, logFile, evenIdents)
        return eventid
    }

    public static func terminal(_ message: String, eventid: String = Foundation.UUID().uuidString, logFile: String = location, evenIdents: Bool = even) -> Never {
        logger.terminal(message: message, eventid, logFile, evenIdents)
        fatalError(message)
    }
}
