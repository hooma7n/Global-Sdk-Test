import Foundation

enum Logger {
    static func info(_ msg: String) { print("ℹ️ [SDK] \(msg)") }
    static func warn(_ msg: String) { print("⚠️ [SDK] \(msg)") }
    static func error(_ msg: String) { print("❌ [SDK] \(msg)") }
    static func debug(_ msg: String) { #if DEBUG; print("🐞 [SDK] \(msg)"); #endif }
}
