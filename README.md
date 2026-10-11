# bonjour.playground

A Swift playground that discovers devices on the local network advertising a Bonjour/mDNS service and prints them as sanitized JSON.

## How it works

- `Device` — a `Codable` model (`name`, optional `hostname`, `port`).
- `sanitized()` — strips characters outside alphanumerics/whitespace/`-_.,` before JSON encoding.
- `Array<Device>.json()` — encodes the device list to JSON (sorted keys, no escaped slashes), falling back to `"[]"`.
- `NetworkDevices` — owns a `NetServiceScanner`, accumulates deduplicated devices, and prints the JSON whenever the list changes.
- `NetServiceScanner` — wraps `NetServiceBrowser`, resolves each found `NetService` (5s timeout), and reports resolved services via a delegate.
- Entry point — starts the scan and runs the current `RunLoop` forever so callbacks keep firing.

## Usage

1. Set a real service type in `getServiceType()` (e.g. `_http._tcp`, `_ssh._tcp`) — the default is a placeholder.
2. Open `playground.xcworkspace` (or `contents.xcplayground`) in Xcode and run the playground.

Resolved devices are printed as JSON, suitable for consumption by other tooling.

## Notes

- Uses the legacy `NetServices` API; the modern `Network.framework` `NWBrowser` is a possible future replacement.