//  Created by Devotel
//

enum Logger {
    #if DEBUG
    static func info(_ msg: String) { print("ℹ️ [SDK] \(msg)") }
    static func warn(_ msg: String) { print("⚠️ [SDK] \(msg)") }
    static func error(_ msg: String) { print("❌ [SDK] \(msg)") }
    static func debug(_ msg: String) { print("🐞 [SDK] \(msg)") }
    #else
    static func info(_ msg: String) {}
    static func warn(_ msg: String) {}
    static func error(_ msg: String) {}
    static func debug(_ msg: String) {}
    #endif
}
