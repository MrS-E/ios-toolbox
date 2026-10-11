import Foundation

/// A discovered network device advertising a Bonjour/mDNS service.
struct Device: Codable, Equatable {
    let name: String
    let hostName: String?
    let port: Int

    enum CodingKeys: String, CodingKey {
        case name
        case hostName = "hostname"
        case port
    }
}

extension String {
    /// Replaces characters outside alphanumerics/whitespace/`-_.,` with `_`.
    func sanitized() -> String {
        let allowed = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-_.,"))
        return self.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
            .reduce("") { $0 + String($1) }
    }
}

extension Device {
    func sanitized() -> Device {
        Device(
            name: name.sanitized(),
            hostName: hostName?.sanitized(),
            port: port
        )
    }
}

extension Array where Element == Device {
    /// Encodes the sanitized device list as JSON, falling back to `[]`.
    func json() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        let sanitizedDevices = self.map { $0.sanitized() }
        guard let data = try? encoder.encode(sanitizedDevices) else {
            return "[]"
        }
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}