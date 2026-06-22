import Foundation

struct ConsoleLogger {
    func debug(message: String, _ even: Bool) {
        print("[DEBUG] \(message)")
    }
    func info(message: String, _ even: Bool) {
        print("\(even ? "[INFO] " : "[INFO]") \(message)")
    }
    func warning(message: String, _ even: Bool) {
        print("\(even ? "[WARN] " : "[WARNING]") \(message)")
    }
    func error(message: String, _ even: Bool) {
        fputs("[ERROR] \(message)\n", stderr)
    }
    func critical(message: String, _ even: Bool) {
        fputs("\(even ? "[CRIT] " : "[CRITICAL]") \(message)\n", stderr)
    }
    func terminal(message: String, _ even: Bool) {
        fputs("[EMERG] \(message)\n", stderr)
    }
}
