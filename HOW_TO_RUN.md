# How to Run Perfect Instrument

## ✅ Project is Now Open in Xcode!

The Xcode project should now be open. Here's how to run it:

## Step-by-Step Instructions

### 1. **Select a Simulator** (Top of Xcode window)
   - Look at the top toolbar near the center
   - You'll see something like "PerfectInstrument > iPhone 15 Pro"
   - Click on it and select any iPhone simulator (iPhone 15 Pro, iPhone 14, etc.)

### 2. **Press the Play Button** ▶️
   - Look at the top-left corner of Xcode
   - Click the large triangular **Play** button (or press ⌘R)
   - This will:
     - Build the app
     - Launch the iPhone Simulator
     - Install and run Perfect Instrument

### 3. **Wait for Build**
   - First time takes 30-60 seconds
   - You'll see a progress bar at the top
   - The simulator window will open automatically

### 4. **Use the App**
   Once running, you'll see:
   - **Instrument Picker** at top (Piano/Violin/Guitar)
   - **Key Width Slider** to resize keys
   - **Motion Control Toggle** (won't work in simulator, but works on real iPhone)
   - **Interactive Instrument** below

## 🎹 How to Play

### Piano Mode
- Tap or drag on the white and black keys
- Horizontal scroll to see all keys
- Each key plays the correct musical note

### Violin Mode
- Drag up and down on the vertical string
- Higher = higher pitch
- Lower = lower pitch
- Continuous sound while touching

### Guitar Mode
- Tap any fret on any of the 6 strings
- Each fret is one semitone higher
- Sound decays quickly (pluck effect)

## ⚙️ Settings

- **Key Width Slider**: Makes keys/frets bigger or smaller (30-100 points)
- **Motion Control**: Enable/disable gyroscope control (only works on real iPhone)

## 🚨 Troubleshooting

### If Build Fails:
1. Make sure all 5 Swift files are in the project
2. Check that deployment target is iOS 15.0+
3. Try: Product → Clean Build Folder (Shift+⌘K)

### If Simulator Doesn't Open:
1. Go to: Xcode → Settings → Locations
2. Make sure Command Line Tools is set
3. Or: Window → Devices and Simulators → Add simulator

### No Sound in Simulator:
- Check your Mac's volume
- Simulator uses your Mac's speakers
- Audio works better on real iPhone

## 📱 Running on Real iPhone (Optional)

To use motion sensors and haptics:

1. Connect iPhone via USB
2. Select your iPhone instead of simulator (top toolbar)
3. You may need to:
   - Trust this computer on iPhone
   - Sign in with Apple ID in Xcode (Signing & Capabilities)
4. Press Play ▶️

Your iPhone will:
- Rotate (roll) device = Pitch bend ±2 semitones
- Tilt (pitch) device = Volume/modulation
- Feel haptic clicks when hitting exact notes

## 🎵 That's It!

The app is ready to use. Just press the ▶️ Play button in Xcode!
