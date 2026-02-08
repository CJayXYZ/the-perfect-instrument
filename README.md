# Perfect Instrument - iOS Audio App

A professional-grade iOS instrument application featuring Piano, Violin, and Guitar with gyroscope-based pitch bend and modulation control.

## Features

### 🎹 Three Instruments
- **Piano**: Resizable keyboard with 3 octaves, white and black keys
- **Violin**: Fretless vertical string with continuous frequency control
- **Guitar**: 6-string fretboard with 12 frets per string (E-A-D-G-B-E tuning)

### 🎵 Audio Engine
- Built with AudioKit 5.x for professional-quality sound synthesis
- Low latency (<10ms) audio processing
- Instrument-specific waveforms:
  - Piano: Sine wave
  - Violin: Sawtooth wave for rich harmonics
  - Guitar: Square wave with pluck-like envelope

### 📱 Motion Control
- **Roll (Device Rotation)**: Controls pitch bend (±2 semitones)
- **Pitch (Device Tilt)**: Controls amplitude/modulation (0-100%)
- Real-time sensor feedback with visual indicators

### 🔊 Haptic Feedback
- "Sticky Notches" - haptic clicks when passing standard 12-TET notes
- Triggers when frequency is within ±2Hz of a MIDI note
- Uses CoreHaptics for precise tactile feedback

### 🎨 Responsive UI
- Resizable key/fret width (30-100pt)
- Horizontal scrolling for full instrument range
- Real-time motion status display
- SwiftUI-based modern interface

## Technical Stack

- **Language**: Swift 5.x
- **UI Framework**: SwiftUI
- **Audio**: AudioKit 5.x, AVFoundation
- **Sensors**: CoreMotion
- **Haptics**: CoreHaptics
- **Target**: iOS 15.0+, iPhone 13 Pro optimized

## File Structure

```
AudioManager.swift      - DSP & Audio Engine
MotionManager.swift     - Gyroscope & Accelerometer
InstrumentViews.swift   - Piano, Violin, Guitar UI
ContentView.swift       - Main app assembly
```

## Setup Instructions

### Prerequisites
1. Xcode 14.0 or later
2. iOS 15.0+ deployment target
3. AudioKit 5.x framework

### Installation

1. **Add AudioKit via Swift Package Manager**:
   - In Xcode: File → Add Packages
   - Enter: `https://github.com/AudioKit/AudioKit`
   - Select version: 5.6.0 or later
   - Add `AudioKit` package

2. **Configure Project Settings**:
   - Set deployment target to iOS 15.0+
   - Enable "Background Modes" → "Audio" (if needed)
   - Add privacy descriptions in Info.plist:
     ```xml
     <key>NSMotionUsageDescription</key>
     <string>Motion sensors control pitch bend and modulation</string>
     ```

3. **Build and Run**:
   - Select iPhone 13 Pro (or physical device)
   - Build (⌘B) and Run (⌘R)

## Usage

1. **Select Instrument**: Use the segmented control at the top
2. **Adjust Key Size**: Use the slider to resize keys/frets
3. **Enable Motion**: Toggle motion control on/off
4. **Play**:
   - Tap/drag on keys (Piano/Guitar)
   - Drag vertically on the string (Violin)
   - Rotate device to bend pitch
   - Tilt device to control volume

## Performance Optimization

- Audio buffer: 5ms for minimal latency
- Motion updates: 100Hz (10ms intervals)
- Optimized for A15 Bionic (iPhone 13 Pro)
- Efficient haptic event generation

## Architecture Highlights

### Low Latency Audio
- Direct AudioKit node-based signal chain
- Minimal processing overhead
- Optimized buffer sizes

### Sensor Integration
- Attitude-based control (not raw accelerometer)
- Smooth interpolation for natural feel
- Separated roll/pitch mapping

### Haptic Intelligence
- Note frequency detection with 2Hz tolerance
- State tracking to prevent duplicate triggers
- Precise 12-TET MIDI note array (21-108)

## License

MIT License - Feel free to use and modify

## Credits

Built with AudioKit framework
Designed for professional iOS audio performance
