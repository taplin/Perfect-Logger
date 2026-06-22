import Foundation

public struct LogOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// All prefix fields: priority, event ID, and timestamp.
    public static let `default`: LogOptions = [.priority, .eventId, .timestamp]

    /// No prefix — log the message only.
    public static let none: LogOptions = []

    /// Logs the level (e.g. `[DEBUG]`).
    public static let priority  = LogOptions(rawValue: 1 << 0)

    /// Logs the event ID (e.g. `[34E621FD-...]`).
    public static let eventId   = LogOptions(rawValue: 1 << 1)

    /// Logs a timestamp (e.g. `[2024-01-02 15:04:05 GMT]`).
    public static let timestamp = LogOptions(rawValue: 1 << 2)
}
