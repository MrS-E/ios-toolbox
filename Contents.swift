import Network
import Foundation

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

class NetworkDevices: ObservableObject, NetServiceScannerDelegate, AnyObject {
    private(set) var devices: [Device] = [] {
        didSet { print(devices.json()) }
    }
    
    private let scanner: NetServiceScanner
    
    init() {
        scanner = NetServiceScanner()
        scanner.delegate = self
    }
    
    func startScan() {
        scanner.start()
    }
    
    func stopScan() {
        scanner.stop()
    }
    
    internal func foundDeviceForService(_ sender: NetService) {
        let device = Device(name: sender.name, hostName: sender.hostName, port: sender.port)
        if !devices.contains(device) { devices.append(device) }
    }
    
    internal func getServiceType() -> String {
        return "_<service>._tcp"
    }
}

protocol NetServiceScannerDelegate: AnyObject {
    func foundDeviceForService(_ service: NetService)
    func getServiceType() -> String
}

class NetServiceScanner: NSObject {
    private var browser: NetServiceBrowser!
    private var services = [NetService]()
    weak var delegate: (any NetServiceScannerDelegate)?

    override init() {
        super.init()
        browser = NetServiceBrowser()
        browser.delegate = self
    }

    func start() {
        guard let type = delegate?.getServiceType() else { return }
        print("Starting scanning for \(type)")
        browser.searchForServices(ofType: type, inDomain: "")
    }

    func stop() {
        browser.stop()
        services.removeAll()
    }
}

extension NetServiceScanner: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found: \(service.name) — will resolve")
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5.0)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed: \(service.name)")
        services.removeAll { $0 === service }
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser){
        print("Start scanning")
    }
}

extension NetServiceScanner: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved: \(sender.name) hostName=\(String(describing: sender.hostName)) port=\(sender.port)")
        delegate?.foundDeviceForService(sender)
    }
}

let browser = NetworkDevices()

browser.startScan()
RunLoop.current.run()
