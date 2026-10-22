# LiveTalk 🔴 (TikTok Live & Interactive Spaces)

LiveTalk is a modern, feature-rich Flutter mobile application designed for real-time live streaming (TikTok style) and multi-seat interactive audio/video spaces (up to 10 seats) with a prominent big screen spotlight. Built following Google’s recommended Android/Flutter development best practices and Material 3 design guidelines.

---

## ✨ Key Features

1. **TikTok-Style Live Streaming**:
   - Immersive vertical video streaming feed with real device camera and microphone integration (`camera` & `permission_handler`).
   - Real-time ephemeral chat messages and floating heart like animations.
   - Host details, viewer counts, and instant broadcast controls.

2. **Multi-Seat Interactive Spaces (Up to 10 Seats)**:
   - Host rooms supporting up to 10 participants sitting in seats.
   - **Big Screen Spotlight View**: Dynamically spotlight any speaker or co-host onto the main big screen.
   - Creators can invite co-hosts to go live with their camera active.

3. **Ephemeral Data Privacy (Zero Storage)**:
   - All streams, chat messages, and participant seats exist strictly in-memory during the active session.
   - At the end of every live stream or space, all data is completely and instantly wiped with no persistent database storage.

4. **Modern Architecture & Best Practices**:
   - Built with **Flutter** and **Material 3 Dark Theme**.
   - State management via **Provider** (`ChangeNotifier`).
   - Clean, modular code structure adhering to Google recommended settings.

---

## 🛠️ Project Structure

```text
lib/
├── models/
│   └── app_models.dart        # Data models (LiveStreamItem, SeatParticipant, ChatMessage)
├── providers/
│   └── live_manager.dart      # Ephemeral state management & session controller
├── screens/
│   ├── home_screen.dart       # Main dashboard & active feeds list
│   ├── create_stream_screen.dart # Setup screen for starting Lives or Spaces (up to 10 seats)
│   ├── live_streaming_screen.dart # TikTok-style live viewing/hosting with camera preview
│   └── space_room_screen.dart # Multi-seat space view with big screen spotlight & camera live
└── main.dart                  # App entry point & theme configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.13.0 or higher)
- Android Studio / VS Code with Flutter & Dart extensions
- An Android device/emulator or iOS device with camera/microphone permissions enabled.

### Installation & Running

1. **Clone or open the project** in Android Studio or VS Code.
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app** (Make sure to perform a **full restart** when launching for the first time so native camera plugins register correctly):
   ```bash
   flutter run
   ```

---

## 📱 Permissions

LiveTalk requests the following native permissions:
- **Camera** (`android.permission.CAMERA`): For live video broadcasting and co-hosting.
- **Microphone** (`android.permission.RECORD_AUDIO`): For audio streaming in lives and spaces.
