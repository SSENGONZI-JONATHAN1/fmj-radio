# Online Radio App - Flutter

A professional, feature-rich online radio streaming application built with Flutter. This app provides continuous streaming from live radio stations worldwide with advanced features like AI-powered recommendations, social features, audio visualizers, and offline capabilities.

## 🎯 Features

### Core Features
- **Continuous Streaming**: Connect to any live radio URL (MP3, AAC, HLS) and play smoothly
- **Metadata Extraction**: Automatically pull "Now Playing" song title and artist from streams
- **Background Playback**: Keep radio playing when screen is locked or app is minimized
- **System Media Controls**: Play/Pause buttons on lock screen and notification shade
- **Dynamic UI**: Beautiful volume sliders, favorite station lists, and category browsers
- **Audio Visualizers**: Real-time animations that pulse to the beat of the music

### Unique Features (What Sets Us Apart)
- **AI-Powered Recommendations**: Smart station suggestions based on listening history
- **Mood-Based Discovery**: Find stations based on your current mood (Happy, Relax, Focus, Workout, Party, Sleep)
- **Sleep Timer**: Auto-stop playback after a set time
- **Recording Capability**: Save favorite song snippets (30 seconds)
- **Cross-Fading**: Smooth transitions between stations
- **Offline Mode**: Cache favorite stations for offline listening
- **Multi-Language Support**: Global audience ready (9 languages)
- **Dark/Light Themes**: Professional UI with theme switching
- **Listening Statistics**: Track your listening habits
- **Social Sharing**: Share stations with friends

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # Entry point
├── models/
│   └── station.dart          # Data models (Station, NowPlayingInfo, Category)
├── services/
│   ├── audio_player_service.dart    # Audio playback with just_audio
│   ├── api_service.dart             # Backend API integration
│   ├── recommendation_service.dart  # AI recommendation engine
│   └── offline_service.dart         # Local storage and caching
├── blocs/
│   ├── player_bloc.dart             # Audio player state management
│   ├── station_bloc.dart            # Stations data management
│   ├── theme_bloc.dart                # Theme switching
│   └── recommendation_bloc.dart     # AI recommendations
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── player_screen.dart
│   ├── discover_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── audio_visualizer.dart
│   └── sleep_timer_dialog.dart
├── themes/
│   └── app_theme.dart
└── utils/
    └── constants.dart
```

### State Management
- **flutter_bloc**: For predictable state management
- **Streams**: For real-time audio state updates
- **Hive**: For local data persistence

## 📦 Dependencies

### Core Audio
- `just_audio`: ^0.9.36 - Audio streaming engine
- `just_audio_background`: ^0.0.1-beta.10 - Background playback
- `audio_service`: ^0.18.12 - System media controls
- `audio_waveforms`: ^1.0.4 - Audio visualizations
- `audio_session`: ^0.1.18 - Audio session management

### State Management & Storage
- `flutter_bloc`: ^8.1.3 - BLoC pattern
- `equatable`: ^2.0.5 - Value equality
- `hive`: ^2.2.3 - Local database
- `hive_flutter`: ^1.1.0 - Hive Flutter integration
- `shared_preferences`: ^2.2.2 - Simple key-value storage

### Networking
- `dio`: ^5.4.0 - HTTP client
- `http`: ^1.1.0 - HTTP requests
- `connectivity_plus`: ^5.0.2 - Network connectivity
- `socket_io_client`: ^2.0.3+1 - Real-time communication

### UI & Utilities
- `flutter_svg`: ^2.0.9 - SVG support
- `shimmer`: ^3.0.0 - Loading shimmer effects
- `flutter_slidable`: ^3.0.1 - Slidable list items
- `share_plus`: ^7.2.1 - Social sharing
- `url_launcher`: ^6.2.2 - URL launching
- `permission_handler`: ^11.1.0 - Permissions
- `path_provider`: ^2.1.1 - File system access
- `record`: ^5.0.4 - Audio recording
- `package_info_plus`: ^5.0.1 - App info
- `device_info_plus`: ^9.1.1 - Device info

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.7.0
- Dart SDK ^3.7.0
- Android Studio / Xcode
- Node.js backend (your friend's part)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/online_radio_app.git
   cd online_radio_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 🔧 Configuration

### Backend API
Update the API base URL in `lib/services/api_service.dart`:
```dart
final String baseUrl = 'https://your-backend-api.com/v1';
```

### Audio Sources
The app supports various streaming formats:
- MP3
- AAC
- OGG
- HLS (m3u8)
- Icecast/Shoutcast streams

### Theme Customization
Edit `lib/themes/app_theme.dart` to customize colors and styles.

## 📱 Screenshots

[Add screenshots of your app here]

## 🤝 Integration with Node.js Backend

Your friend is handling the Node.js backend. The Flutter app expects these API endpoints:

### Required Endpoints
```
GET  /stations              - List all stations
GET  /stations/featured     - Featured stations
GET  /stations/trending      - Trending stations
GET  /stations/:id           - Station details
GET  /categories            - List categories
GET  /search?q=query        - Search stations
GET  /countries             - List countries
GET  /languages             - List languages
GET  /lyrics                - Get song lyrics
POST /analytics/listening   - Report listening stats
POST /recommendations/*     - AI recommendation endpoints
```

### WebSocket Events (for Social Features)
```
connect
disconnect
join_station
leave_station
send_message
receive_message
user_joined
user_left
```

## 🎨 Design System

### Colors
- **Primary**: #6C63FF (Purple)
- **Secondary**: #00BFA6 (Teal)
- **Accent**: #FF6584 (Pink)
- **Dark Background**: #121212
- **Light Background**: #FFFFFF

### Typography
- **Headings**: Poppins
- **Body**: Inter

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Check code coverage
flutter test --coverage
```

## 📋 Play Store Checklist

- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (phone, tablet)
- [ ] Privacy policy
- [ ] App description
- [ ] Content rating
- [ ] Target SDK 34+
- [ ] Signed APK/App Bundle
- [ ] Obfuscation enabled

## 🐛 Troubleshooting

### Common Issues

**Audio not playing in background**
- Ensure `audio_service` is properly configured
- Check AndroidManifest.xml permissions
- Verify notification channel is created

**Build errors with Hive**
- Run `flutter packages pub run build_runner build`
- Delete `.dart_tool` and rebuild

**Network errors**
- Check internet permission in AndroidManifest.xml
- Verify API base URL is correct
- Check SSL certificate for HTTPS

## 📝 License

This project is proprietary and confidential. Unauthorized copying, transferring or reproduction of the contents of this project, via any medium is strictly prohibited.

## 👥 Team

- **Flutter Developer**: You
- **Backend Developer**: Your Friend (Node.js)
- **UI/UX Designer**: [Add name]
- **Project Manager**: [Add name]

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Ryan Heise for just_audio and audio_service packages
- The Flutter community for continuous support

## 📞 Support

For support, email support@onlineradio.com or join our Slack channel.

---

**Made with ❤️ and Flutter**
