# Flutter Liveness Detection Randomized Plugin

A Flutter plugin for liveness detection with randomized challenge response method with an interaction mechanism between the user and the system in the form of a movement challenge that indicates life is detected on the face. This plugin helps implement secure biometric authentication by detecting real human presence through dynamic facial verification challenges.

[![pub package](https://img.shields.io/pub/v/flutter_liveness_detection_randomized_plugin.svg)](https://pub.dev/packages/flutter_liveness_detection_randomized_plugin)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/50b64954ad654b65b0424d266399b026)](https://app.codacy.com/gh/bagussubagja/flutter-liveness-detection-randomized-plugin/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

## Preview 🪟
![Slide 16_9 - 1](https://github.com/user-attachments/assets/55e59d51-e0da-4562-879e-ae50adaced33)

https://github.com/user-attachments/assets/f7266dc9-c4a2-4fba-8684-0ead2f678180

## Features ✨

- 📱 Real-time face detection
- 🎲 Randomized challenge sequence generation
- 💫 Cross-platform support (iOS & Android) 
- 🎨 Light and dark mode support
- ✅ High accuracy liveness verification
- 🚀 Simple integration API
- 🎭 Customizable liveness challenge labels
- ⏳ Flexible security verification duration
- 🎲 Adjustable number of liveness challenges

## Getting Started 🌟

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_liveness_detection_randomized_plugin: ^1.0.5
```

## Customized Steps Label
You can customized steps label or use certain step only of liveness challenge with this example :
```
config: LivenessDetectionConfig(
customizedLabel: LivenessDetectionLabelModel(
  blink: '', // add empty string to skip/pass this liveness challenge
  lookDown: '',
  lookLeft: '',
  lookRight: '',
  lookUp: 'Tengok Atas', // example of customize label name for liveness challenge. it will replace default 'look up'
  smile: null, // null value to use default label name
),
),
```

## ⚡️ NEW: Skip Detection Steps (Direct Face Capture)

You can now configure whether to use detection steps or directly capture the face:

```dart
// With detection steps (default - more secure)
config: LivenessDetectionConfig(
  allowDetectionSteps: true,  // Users must blink, smile, etc.
)

// Without detection steps (quick capture)
config: LivenessDetectionConfig(
  allowDetectionSteps: false, // Direct face capture, no verification steps
)
```

**When to use each mode:**
- `allowDetectionSteps: true` → Banking, KYC, high-security authentication
- `allowDetectionSteps: false` → Quick profile photos, low-risk scenarios

📖 [Read the full Detection Steps Configuration Guide](DETECTION_STEPS_GUIDE.md) for detailed usage and best practices.

## Platform Setup

### Android
Add camera permission to your AndroidManifest.xml:
```
<uses-permission android:name="android.permission.CAMERA"/>
```
Minimum SDK version: 23

### iOS
Add camera usage description to Info.plist:
```
<key>NSCameraUsageDescription</key>
<string>Camera access is required for liveness detection</string>
```
