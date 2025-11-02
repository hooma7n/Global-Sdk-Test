# GlobalCommunicationSDK

A lightweight, production‑ready SDK for Global Communication APIs with async/await + RxSwift support.

## Features
- ✅ Swift Package Manager (SPM)
- ✅ Async/Await + completion handlers
- ✅ Optional RxSwift
- ✅ Environment-aware (Dev/Stg/Prod)
- ✅ License verification hook
- ✅ (Optional) App Attest stub
- ✅ MVVM/Coordinator friendly

## Installation (SPM)
In Xcode: **File > Add Packages…** and paste the repo URL:

```
https://github.com/<your-org-or-user>/GlobalCommunicationSDK.git
```

Select a **Version** rule (e.g. `Up to Next Major` starting at `1.0.0`).

Then import in your code:

```swift
import GlobalCommunicationSDK
```

## Quick Start

```swift
import GlobalCommunicationSDK

let config = SDKConfiguration(
    appId: "com.devotel.sample",
    environment: .development,
    licenseKey: "YOUR-LICENSE-KEY",
    useAppAttest: false
)

GlobalCommunicationSDK.shared.configure(config)

Task {
    do {
        let res = try await GlobalCommunicationSDK.shared.auth.login(email: "a@b.com", password: "secret")
        print(res.accessToken)
    } catch {
        print(error)
    }
}
```

## Endpoints & Models
Edit `Sources/GlobalCommunicationSDK/Networking/Endpoint.swift` and `Sources/GlobalCommunicationSDK/Models/*` to match your server schema.

## Versioning
We use **Semantic Versioning**:
- Breaking changes → MAJOR
- Backwards‑compatible features → MINOR
- Fixes/patches → PATCH

## License
MIT (or your license of choice).
