# BEACON - Emergency Communication App

### 🔗 Device Discovery
- Find nearby devices automatically
- Show your device to others
- Connect with nearby phones

### 💬 Chat System
- Send and receive text messages
- Support different message types (text, image, file, voice)
- Message status (sent, delivered, failed)

### 🆘 Emergency SOS Alerts
- Send emergency alerts to all connected devices
- Voice announcements for alerts
- Priority system for emergency messages

### 📁 File Sharing
- Share files between connected devices
- Support different file types (documents, images, videos, audio)
- Track download and upload status

### 👤 Profile Management
- Create and edit your profile
- Activity statistics
- Activity history

## Technologies Used

### Frontend
- **Flutter**: Cross-platform framework
- **Provider**: State management
- **Material Design 3**: Modern UI design

### Backend & Database
- **SQLite**: Local database
- **Sqflite**: Flutter SQLite library

### Additional Libraries
- **flutter_tts**: Text-to-speech
- **file_picker**: File selection
- **permission_handler**: Permission management
- **uuid**: Unique ID generation

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user.dart
│   ├── connected_device.dart
│   ├── message.dart
│   ├── resource.dart
│   └── activity.dart
├── database/         # Database services
│   └── database_service.dart
├── services/         # App services
│   └── app_state.dart
├── screens/          # UI screens
│   ├── landing_page.dart
│   ├── profile_page.dart
│   ├── network_dashboard_page.dart
│   ├── chat_page.dart
│   └── resource_sharing_page.dart
├── widgets/          # Custom UI components
└── main.dart         # App entry point
```

## How to Run the App

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Android Studio or VS Code
- Android emulator or real Android device

### Step-by-Step Instructions

1. **Open Terminal/Command Prompt**
   ```bash
   cd /path/to/your/project/beacon_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Start Android Emulator**
   - Open Android Studio
   - Go to Tools → AVD Manager
   - Click "Play" button next to your emulator
   - OR use command line:
   ```bash
   flutter emulators --launch Pixel_6a
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

### Alternative Ways to Run

**Option 1: Run on macOS (if you're on Mac)**
```bash
flutter run -d macos
```

**Option 2: Run on specific device**
```bash
flutter devices  # See available devices
flutter run -d [device-id]
```

**Option 3: Run in release mode**
```bash
flutter run --release
```

## Required Permissions

### Android Permissions
- `INTERNET`: For network connection
- `ACCESS_WIFI_STATE`: Access Wi-Fi state
- `ACCESS_NETWORK_STATE`: Access network state
- `CHANGE_WIFI_STATE`: Change Wi-Fi state
- `ACCESS_FINE_LOCATION`: Access precise location
- `ACCESS_COARSE_LOCATION`: Access approximate location
- `READ_EXTERNAL_STORAGE`: Read external files
- `WRITE_EXTERNAL_STORAGE`: Write external files

## Troubleshooting

### Common Issues

**Issue: "System UI isn't responding"**
- Solution: Restart the emulator
- Close emulator and start again

**Issue: "Build failed"**
- Solution: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

**Issue: "No devices found"**
- Solution: Check if emulator is running
```bash
flutter devices
```

**Issue: "Gradle build failed"**
- Solution: Update Android SDK
- Open Android Studio → SDK Manager → Update SDK

### If App Won't Load

1. **Check Flutter Doctor**
   ```bash
   flutter doctor
   ```

2. **Clean Project**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Restart Emulator**
   - Close emulator completely
   - Start again from Android Studio

4. **Try Different Emulator**
   ```bash
   flutter emulators --launch Medium_Phone_API_36.1
   ```

## App Screens

### 1. Landing Page
- Welcome screen with app logo
- Options to join network or start new network
- Profile settings access

### 2. Profile Page
- View and edit user profile
- Activity statistics
- Profile management

### 3. Network Dashboard
- Shows connected devices
- Quick actions (Chat, Share, SOS)
- Network status

### 4. Chat Page
- Send and receive messages
- Device list
- Message history

### 5. Resource Sharing
- Share files with connected devices
- Download shared files
- File management

## Development Status

### ✅ Completed Features
- [x] Basic UI screens
- [x] Database setup
- [x] State management
- [x] Profile management
- [x] File sharing UI

### 🚧 In Progress جاري الطبخ
- [ ] P2P device discovery
- [ ] Real message sending
- [ ] Push notifications
- [ ] File transfer
