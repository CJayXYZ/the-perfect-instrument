import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var motionManager = MotionManager()
    
    @State private var selectedInstrument = 0
    @State private var keyWidth: CGFloat = 60.0
    @State private var isMotionEnabled = true
    
    private let instruments = ["Piano", "Violin", "Guitar"]
    
    var body: some View {
        ZStack {
            // Professional gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - Premium design
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("The Perfect Instrument")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("PrimeC Labs")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Instrument Picker - Styled
                        Picker("Instrument", selection: $selectedInstrument) {
                            ForEach(0..<instruments.count, id: \.self) { index in
                                Text(instruments[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                        .onChange(of: selectedInstrument) { newValue in
                            switchInstrument(newValue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Controls - Sleek design
                    HStack(spacing: 20) {
                        // Key Width Slider
                        HStack(spacing: 8) {
                            Image(systemName: "ruler")
                                .foregroundColor(.white.opacity(0.8))
                            Slider(value: $keyWidth, in: 30...100, step: 5)
                                .frame(width: 100)
                                .accentColor(.cyan)
                            Text("\(Int(keyWidth))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 30)
                        }
                        
                        // Motion Toggle
                        HStack(spacing: 8) {
                            Image(systemName: "gyroscope")
                                .foregroundColor(.white.opacity(0.8))
                            Toggle("", isOn: $isMotionEnabled)
                                .labelsHidden()
                                .onChange(of: isMotionEnabled) { enabled in
                                    if enabled {
                                        motionManager.start()
                                    } else {
                                        motionManager.stop()
                                    }
                                }
                        }
                        
                        // Motion Status - Modern design
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PITCH BEND")
                                    .font(.system(size: 8))
                                    .foregroundColor(.cyan)
                                HStack(spacing: 4) {
                                    ProgressView(value: (motionManager.pitchBend + 2.0) / 4.0)
                                        .frame(width: 60)
                                        .accentColor(.cyan)
                                    Text(String(format: "%.1f", motionManager.pitchBend))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("MODULATION")
                                    .font(.system(size: 8))
                                    .foregroundColor(.purple)
                                HStack(spacing: 4) {
                                    ProgressView(value: motionManager.modulation)
                                        .frame(width: 60)
                                        .accentColor(.purple)
                                    Text(String(format: "%.1f", motionManager.modulation))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(
                    Color.black.opacity(0.3)
                        .blur(radius: 20)
                )
                .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Instrument View
                Group {
                    switch selectedInstrument {
                    case 0:
                        PianoView(audioManager: audioManager, keyWidth: $keyWidth)
                    case 1:
                        ViolinView(audioManager: audioManager, keyWidth: $keyWidth)
                    case 2:
                        GuitarView(audioManager: audioManager, keyWidth: $keyWidth)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            setupApp()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    // MARK: - Setup & Lifecycle
    private func setupApp() {
        // Start motion updates
        if isMotionEnabled {
            motionManager.start()
        }
        
        // Link motion to audio
        setupMotionAudioLink()
        
        // Set initial instrument
        switchInstrument(selectedInstrument)
    }
    
    private func setupMotionAudioLink() {
        // Observe motion changes and update audio manager
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard isMotionEnabled else { return }
            
            // Update pitch bend from gyro roll
            audioManager.updatePitchBend(motionManager.pitchBend)
            
            // Update amplitude/modulation from gyro pitch
            audioManager.updateAmplitude(motionManager.modulation)
        }
    }
    
    private func switchInstrument(_ index: Int) {
        switch index {
        case 0:
            audioManager.switchInstrument(to: .piano)
        case 1:
            audioManager.switchInstrument(to: .violin)
        case 2:
            audioManager.switchInstrument(to: .guitar)
        default:
            break
        }
    }
    
    private func cleanup() {
        motionManager.stop()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
