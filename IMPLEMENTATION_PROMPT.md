 # Task: Build "Perfect Instrument" End-to-End

I need the full implementation for an iOS app called "Perfect Instrument." Follow the architecture in SYSTEM_PROMPT.md.

## 1. AudioManager Implementation
- Initialize an `AudioEngine`.
- Create two modes:
    - **Violin:** Use an `Oscillator` (Sawtooth) with continuous glide.
    - **Guitar:** Use a `PluckedString` or `PWMOscillator` with a fast decay.
- Implement `triggerLatchingHaptic()`: Check the current frequency against a calculated array of 12-std MIDI note frequencies. Trigger a click when passing a note.

## 2. MotionManager Implementation (Sensor Reversal)
- Track `deviceMotion`.
- Map `data.attitude.roll` to a `pitchBend` variable (Range: -2.0 to 2.0).
- Map `data.attitude.pitch` to an `amplitude` or `modulation` variable (Range: 0.0 to 1.0).

## 3. Instrument UI Implementation
- **Resizable Piano:** Create a SwiftUI keyboard where `keyWidth` is a `@Binding`. Use a `ScrollView(.horizontal)`.
- **Guitar Fretboard:** Create a grid of 6 strings (E-A-D-G-B-E) and 12 frets. Each "key" width must be resizable.
- **Single String (Violin):** A fretless vertical bar where Y-axis position controls frequency linearly.

## 4. ContentView Integration
- A `Picker` at the top to swap between Piano, Violin, and Guitar.
- A `Slider` to adjust `keyWidth` globally.
- An `onAppear` block that links `MotionManager` updates directly to the `AudioManager` oscillators.

## 5. End-to-End Requirements
- Provide the full code for all 4 files.
- Ensure the app is "Plug and Play" for an iPhone 13 Pro target in Xcode.