import Foundation

public enum LogPriority: Int, Comparable, Sendable {
    case debug
    case info
    case warning
    case error
    case critical
    case terminal

    public static func < (lhs: LogPriority, rhs: LogPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    func stringRepresentation(even: Bool) -> String {
        switch self {
        case .debug:    return "[DEBUG]"
        case .info:     return even ? "[INFO] " : "[INFO]"
        case .warning:  return even ? "[WARN] " : "[WARNING]"
        case .error:    return "[ERROR]"
        case .critical: return even ? "[CRIT] " : "[CRITICAL]"
        case .terminal: return "[EMERG]"
        }
    }
}
