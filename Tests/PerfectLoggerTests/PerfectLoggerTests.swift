import Testing
import Foundation
@testable import PerfectLogger

@Suite(.serialized)
struct PerfectLoggerTests {

    private func tmpLog() -> String {
        NSTemporaryDirectory() + "PerfectLoggerTests_\(UUID().uuidString).txt"
    }

    @Test func basicFileLog() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }

        LogFile.critical("test critical message", logFile: path)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        #expect(contents.contains("test critical message"))
        #expect(contents.contains("[CRITICAL]"))
    }

    @Test func eventIdEchoed() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let eid = LogFile.critical("first message", logFile: path)
        LogFile.critical("second message", eventid: eid, logFile: path)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        let occurrences = contents.components(separatedBy: eid).count - 1
        #expect(occurrences == 2)
    }

    @Test func allLevelsWriteToFile() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }

        LogFile.debug("msg-debug", logFile: path)
        LogFile.info("msg-info", logFile: path)
        LogFile.warning("msg-warning", logFile: path)
        LogFile.error("msg-error", logFile: path)
        LogFile.critical("msg-critical", logFile: path)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        #expect(contents.contains("msg-debug"))
        #expect(contents.contains("msg-info"))
        #expect(contents.contains("msg-warning"))
        #expect(contents.contains("msg-error"))
        #expect(contents.contains("msg-critical"))
    }

    @Test func thresholdFiltersLow() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }
        let savedThreshold = LogFile.threshold
        defer { LogFile.threshold = savedThreshold }

        LogFile.threshold = .error
        LogFile.debug("should-not-appear", logFile: path)
        LogFile.info("should-not-appear-either", logFile: path)
        LogFile.error("should-appear", logFile: path)

        let contents = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
        #expect(!contents.contains("should-not-appear"))
        #expect(contents.contains("should-appear"))
    }

    @Test func noOptionsWritesMessageOnly() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }
        let savedOptions = LogFile.options
        defer { LogFile.options = savedOptions }

        LogFile.options = .none
        LogFile.error("bare message", logFile: path)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        #expect(contents.trimmingCharacters(in: .whitespacesAndNewlines) == "bare message")
    }

    @Test func multipleWritesAppend() throws {
        let path = tmpLog()
        defer { try? FileManager.default.removeItem(atPath: path) }

        LogFile.error("line-one", logFile: path)
        LogFile.error("line-two", logFile: path)
        LogFile.error("line-three", logFile: path)

        let contents = try String(contentsOfFile: path, encoding: .utf8)
        #expect(contents.contains("line-one"))
        #expect(contents.contains("line-two"))
        #expect(contents.contains("line-three"))
    }
}
