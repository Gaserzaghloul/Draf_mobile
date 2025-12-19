# BEACON Project

## Overview

BEACON is a peer-to-peer (P2P) emergency communication application designed to function in offline environments where cellular networks and internet connectivity are unavailable. The application utilizes Wi-Fi Direct technology to create local mesh networks, enabling users to discover nearby devices, exchange messages, and share vital resources such as food, water, and medical supplies.

This project prioritizes data security and accessibility, featuring an encrypted local database for persistent storage and integrated voice command functionality for hands-free operation.

## Key Features

### 1. Offline Peer-to-Peer Communication

- **Device Discovery**: Automatically scans for and identifies nearby devices using P2P technology.
- **Ad-Hoc Networking**: Functions as either a Group Owner (Host) or a Client to establish local networks without a central router.
- **Connection Management**: Handles connection lifecycles, including connecting, disconnecting, and handling broad network updates.

### 2. Secure Data Storage

- **Encryption**: All local data is stored in an SQLite database encrypted with SQLCipher.
- **Data Persistence**: User profiles, chat history, resource requests, and activity logs are persisted locally.
- **Secure Key Management**: Encryption keys are securely generated and stored using secure storage mechanisms.

### 3. Real-Time Messaging using Wi-Fi Direct

- **Instant Chat**: sending and receiving text messages between connected peers.
- **SOS Alerts**: Dedicated functionality to broadcast high-priority emergency alerts to all connected devices.
- **Status Updates**: Automatic sharing of device availability and status.

### 4. Resource Sharing System

- **Request & Provide**: Users can broadcast requests for specific categories of supplies (Medical, Shelter, Food).
- **Fulfillment Tracking**: Tracks who is providing resources for specific requests.
- **Broadcast Updates**: Updates on resource status are propagated across the local network.

### 5. Accessibility

- **Voice Commands**: Integrated speech-to-text allows users to navigate the app and perform actions (e.g., sending SOS, checking status) using voice commands.
- **Text-to-Speech**: Incoming messages and alerts can be read aloud, aiding users in high-stress or low-visibility situations.

### 6. User Management

- **Profile System**: Users can create and manage detailed profiles, including emergency contact information and medical details.
- **Activity Logging**: A local log tracks all network interactions, ensuring a record of events is maintained.

## Technical Architecture

The application follows a modular architecture using the Provider pattern for state management. The codebase is organized into distinct layers to separate concerns:

### Directory Structure

- **lib/database**: Contains `DatabaseService`, handling all SQLite interactions, encryption, and schema migrations.
- **lib/models**: Data classes definition (User, Message, Resource, ConnectedDevice, Activity) with serialization logic.
- **lib/screens**: UI components and screens (Dashboard, Chat, Profile, Resource Sharing).
- **lib/services**: Core business logic and external service integrations:
  - `P2PService`: Manages Wi-Fi Direct APIs.
  - `VoiceCommandService`: Handles speech recognition and synthesis.
  - `NotificationService`: Manages local system notifications.
  - `*Provider`: Classes responsible for state management and bridging UI with services.
- **lib/main.dart**: Application entry point and theme configuration.

### Dependencies

The project relies on the following key libraries:

- **Flutter SDK**: The core framework.
- **Provider**: For dependency injection and state management.
- **Flutter P2P Connection**: For handling Wi-Fi Direct discovery and connection.
- **Sqflite SQLCipher**: For database encryption.
- **Speech to Text & Flutter TTS**: For voice interaction.

## Setup and Installation

### Prerequisites

- Flutter SDK (Version 3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- A physical Android device (Required for P2P testing as Wi-Fi Direct is not supported on emulators)

### Installation

1.  Navigate to the project directory:
    ```bash
    cd beacon_app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

### Permissions

The application requires the following runtime permissions to function correctly:

- **Location**: Required for Wi-Fi Direct peer discovery.
- **Microphone**: Required for voice commands.
- **Storage**: Required for database and file handling.
- **Nearby Devices**: Required for Android 12+ peer discovery.

## Testing

The project includes a comprehensive testing suite to ensure reliability and performance.

### 1. Unit & Widget Tests

Located in the `test` directory, these tests verify individual functions, models, and UI components.

- **Unit Tests**: Verify the logic of data models (e.g., `test/models/user_test.dart`).
- **Widget Tests**: Verify the UI rendering and interaction (e.g., `test/widget_test.dart`).

To run unit and widget tests:

```bash
flutter test
```

### 2. Integration Tests

Located in the `integration_test` directory, these tests simulate a complete user session on a physical device or emulator to verify end-to-end functionality.

- **End-to-End Test**: `integration_test/app_test.dart` verifies the complete application flow.

To run integration tests:

```bash
flutter test integration_test/app_test.dart
```
