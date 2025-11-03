import Foundation

extension Data {
    init?(hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard s.count % 2 == 0 else { return nil }
        var data = Data(capacity: s.count/2)
        var i = s.startIndex
        for _ in 0..<(s.count/2) {
            let j = s.index(i, offsetBy: 2)
            guard let b = UInt8(s[i..<j], radix: 16) else { return nil }
            data.append(b); i = j
        }
        self = data
    }
    func toHex() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
    func base64UrlString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
