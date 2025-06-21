# Strive Cycling

Strive Cycling is an iOS app built in SwiftUI that integrates with the Strava API to provide cyclists with a clean, insightful dashboard for reviewing recent rides, logging nutrition, and tracking progress.

This project serves two purposes:
1. **Production Goal**: Strive Cycling is an ongoing project intended for eventual public release on the App Store.
2. **Developer Demonstration**: It is currently designed as a coding exercise and demonstration of modern iOS practices using SwiftUI, swift concurrency, and third-party API integration.

---

## Getting Started

> The following prerequisites and setup steps are required to build and run Strive Cycling **locally** in Xcode. If you are only interested in the concept or features, you may skip to the [Features](#features) section for more information and screenshots.

### Prerequisites
- A Mac running a stable release of macOS
- The latest stable version of Xcode
- An iOS device running iOS 18 or later
- A registered Strava Developer account with access to the Strava API

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/rdp10037/strive-cycling.git
   cd strive-cycling
   ```

2. **Create a Strava Developer App**
   - Visit: https://www.strava.com/settings/api
   - Click "Create & Manage Your App"
   - Set the Authorization Callback Domain to: `rdp10037.github.io`
   - Note your `Client ID` and `Client Secret`
   - Each developer should use their own keys — this keeps credentials secure and isolated.

3. **Configure Secrets (Two Approaches)**

   #### Recommended Approach (Using `.xcconfig` for Security)
   - Create a `secrets.xcconfig` file in the root of the project with the following content:
     ```
     STRAVA_CLIENT_ID=your-client-id
     STRAVA_CLIENT_SECRET=your-client-secret
     ```
   - Add the following keys to your `Info.plist`:
     ```xml
     <key>STRAVA_CLIENT_ID</key>
     <string>$(STRAVA_CLIENT_ID)</string>
     <key>STRAVA_CLIENT_SECRET</key>
     <string>$(STRAVA_CLIENT_SECRET)</string>
     ```
   - Access these in code as follows:
     ```swift
     private let clientID = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? ""
     private let clientSecret = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? ""
     private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"
     ```
   - Be sure to add `secrets.xcconfig` to `.gitignore` to avoid committing sensitive keys.

   #### Alternative (For Local Testing Only)
   - You may alternatively hardcode your client ID and secret directly in code (not recommended for production):
     ```swift
     private let clientID = "your-client-id"
     private let clientSecret = "your-client-secret"
     private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"
     ```
   - **Warning**: Never expose hardcoded credentials in a public repository. Revoke any exposed secrets in your Strava dashboard immediately.

4. **Open and Run**
   - Open the project in Xcode.
   - Run on a simulator or physical device. First-time users will be prompted to authenticate with Strava.

---

## Features

- **Strava OAuth2 Integration**: Securely connects to Strava, handling token storage and refresh via Keychain.
- **Activity Feed**: Displays recent rides with map previews and performance stats.
- **Activity Detail**: Allows users to log hydration, food intake, perceived exertion, and post-ride notes.
- **Profile View**: Shows user name, avatar, and key metrics from Strava’s athlete and stats endpoints.
- **MapKit Integration**: Visualizes route data using `MapSnapshotter` and custom overlays.


![Group 1000006259 (1)](https://github.com/user-attachments/assets/2eb33a50-6775-4961-98ba-bbf46a574307)




---

## Architecture Overview

- MVVM architecture with `@MainActor`-based ViewModels
- Custom network layer using async/await and `URLSession`
- Secure token storage using `KeychainHelper`
- Local data storage using `@AppStorage` (for prototype state)

---

## Future Features

Planned and upcoming features:
- Monthly activity heatmap based on total ride duration
- Pagination and filtering for the activity history
- Ride nutrition planning and recommendations
- HealthKit integration (for metrics like weight, sleep, and steps)

![Group 1000006261](https://github.com/user-attachments/assets/d49e573a-f32d-4250-87ad-bd21960cf781)


---

## Known Issues

- **Calorie metric shows as 0**: Current logic fetches summaries only; full per-activity fetch is required to access calories per Strava API best practices.
- **Mismatch in year-to-date stats**: Some stats (like YTD rides) show as 0 on Strive even though they appear correctly in the official Strava app.
- **Limited nutrition logging**: Only basic hydration and food logging are supported. Data may not persist due to the lack of a backend.
- **Minimal error handling**: Networking and decoding errors are not yet fully surfaced in the UI.

---

## License

This project is open source and available under the MIT License (TBD).

---

## Contact

For questions, feedback, or collaboration opportunities, contact [your email or GitHub profile].

