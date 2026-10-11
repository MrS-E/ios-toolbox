import Foundation

protocol NetServiceScannerDelegate: AnyObject {
    func foundDeviceForService(_ service: NetService)
    func getServiceType() -> String
}

/// Legacy `NetServiceBrowser` wrapper that resolves found services (5s timeout)
/// and reports them through a delegate.
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

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("Start scanning")
    }
}

extension NetServiceScanner: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved: \(sender.name) hostName=\(String(describing: sender.hostName)) port=\(sender.port)")
        delegate?.foundDeviceForService(sender)
    }
}