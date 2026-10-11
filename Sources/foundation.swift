import Foundation
import Network

class NetServiceScanner: NSObject {
    private var browser: NetServiceBrowser!
    private var services = [NetService]()

    override init() {
        super.init()
        browser = NetServiceBrowser()
        browser.delegate = self
    }

    func start() {
        browser.searchForServices(ofType: "_<service>._tcp", inDomain: "")
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
}

extension NetServiceScanner: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved: \(sender.name) hostName=\(String(describing: sender.hostName)) port=\(sender.port)")
    }
}

