import Foundation

/// Modern `NWBrowser` (Network framework) alternative to the legacy
/// `NetServiceScanner`. Prints discovered services as they appear.
class BonjourBrowser {
    private var browser: NWBrowser?

    func startBrowsing(serviceType: String = "_<service>._tcp") {
        let parameters = NWParameters()

        browser = NWBrowser(for: .bonjour(type: serviceType, domain: nil), using: parameters)

        browser?.stateUpdateHandler = { newState in
            print("Browser state: \(newState)")
        }

        browser?.browseResultsChangedHandler = { results, _ in
            for result in results {
                let endpoint = result.endpoint
                switch endpoint {
                case .service(let name, let type, let domain, _):
                    print("Found service: name=\(name), type=\(type), domain=\(domain)")
                default:
                    break
                }
            }
        }

        browser?.start(queue: .main)
    }

    func stopBrowsing() {
        browser?.cancel()
        browser = nil
    }
}