import Foundation

/// Posts log events to a remote HTTP endpoint. All configuration via static properties.
/// Network calls are fire-and-forget (non-blocking).
public struct RemoteLogger {
    private init() {}

    /// The remote server base URL (e.g. `"http://loghost.example.com"`).
    public nonisolated(unsafe) static var logServer = ""

    /// Bearer token included in the request URL path.
    public nonisolated(unsafe) static var token = ""

    /// Minimum priority to send remotely.
    public nonisolated(unsafe) static var threshold: LogPriority = .debug

    public nonisolated(unsafe) static var even = false

    @discardableResult
    public static func debug(_ args: String, eventid: String = UUID().uuidString) -> String {
        post(priority: .debug, args, eventid); return eventid
    }
    @discardableResult
    public static func info(_ args: String, eventid: String = UUID().uuidString) -> String {
        post(priority: .info, args, eventid); return eventid
    }
    @discardableResult
    public static func warning(_ args: String, eventid: String = UUID().uuidString) -> String {
        post(priority: .warning, args, eventid); return eventid
    }
    @discardableResult
    public static func error(_ args: String, eventid: String = UUID().uuidString) -> String {
        post(priority: .error, args, eventid); return eventid
    }
    @discardableResult
    public static func critical(_ args: String, eventid: String = UUID().uuidString) -> String {
        post(priority: .critical, args, eventid); return eventid
    }
    public static func terminal(_ args: String, eventid: String = UUID().uuidString) -> Never {
        post(priority: .terminal, args, eventid)
        fatalError(args)
    }

    private static func post(priority: LogPriority, _ args: String, _ eventid: String) {
        guard priority >= threshold,
              !logServer.isEmpty, !token.isEmpty else { return }

        let server = logServer
        let tok = token
        let payload: [String: Any] = [
            "priority": priority.stringRepresentation(even: even),
            "eventid": eventid,
            "message": args,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
        ]

        Task.detached {
            guard let url = URL(string: "\(server)/api/v1/log/\(tok)") else { return }
            guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            _ = try? await URLSession.shared.data(for: request)
        }
    }
}
