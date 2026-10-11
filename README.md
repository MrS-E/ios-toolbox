# ios-toolbox

A personal iOS toolbox — a growing collection of Swift snippets, helpers, and small utilities for app development, extracted from real experiments and playgrounds.

## Layout

Snippets live under `Snippets/`, grouped by topic:

```
Snippets/
├── Bonjour/                 # Network discovery (mDNS / Bonjour)
│   ├── NetServiceScanner.swift   # legacy NetServiceBrowser wrapper + delegate
│   └── BonjourBrowser.swift      # modern NWBrowser (Network framework)
├── Combine/                 # Combine helpers (publishers, subscribers, operators)
├── Foundation/              # Foundation helpers
│   └── Device.swift              # Codable model + string sanitizing + JSON encoding
├── Networking/              # URLSession, requests, small API utilities
└── SwiftUI/                 # Views, modifiers, reusable components
```

Topic folders each carry a short `README.md` describing what belongs there. Create a new folder when a snippet doesn't fit an existing topic.

## Snippets

### Bonjour / network discovery

- **`NetServiceScanner.swift`** — wraps the legacy `NetServiceBrowser`, resolves each found `NetService` (5s timeout), and reports resolved services through a `NetServiceScannerDelegate`. Set a real service type (e.g. `_http._tcp`, `_ssh._tcp`) via `getServiceType()` — the default is a placeholder.
- **`BonjourBrowser.swift`** — the modern `NWBrowser`-based alternative from the `Network` framework. Pass your service type to `startBrowsing(serviceType:)`.

### Foundation

- **`Device.swift`** — a `Codable` model (`name`, optional `hostname`, `port`), a `String.sanitized()` helper that replaces characters outside alphanumerics/whitespace/`-_.,` with `_`, and `Array<Device>.json()` which encodes the sanitized list as JSON (sorted keys, no escaped slashes), falling back to `"[]"`.

## Usage

Each file is self-contained — copy the snippet you need into your project, or point Xcode at the folder. The Bonjour snippets expect a run loop (e.g. `RunLoop.current.run()`) to keep callbacks firing when run standalone.

## Notes

- `NetServiceBrowser` / `NetService` are deprecated; prefer `NWBrowser` (`BonjourBrowser.swift`) for new code.
- Bonjour discovery on a real device requires the local-network privacy entitlement/permission.

## Contributing

Add new snippets under the matching topic folder (create one if missing) and keep each file self-contained with a short doc comment.