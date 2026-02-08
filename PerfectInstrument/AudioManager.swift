import AVFoundation
import CoreHaptics

class AudioManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentFrequency: Double = 440.0
    @Published var amplitude: Double = 0.5
    @Published var pitchBend: Double = 0.0 // -2.0 to 2.0 semitones
    @Published var instrumentMode: InstrumentMode = .piano
    
    // MARK: - Audio Engine Components
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var currentBuffer: AVAudioPCMBuffer?
    private var isPlaying = false
    
    // MARK: - Haptics
    private var hapticEngine: CHHapticEngine?
    private var lastHapticNoteIndex: Int = -1
    
    // MARK: - MIDI Note Frequencies (12-TET)
    private let midiNoteFrequencies: [Double] = {
        var frequencies: [Double] = []
        // Generate frequencies for MIDI notes 21-108 (Piano range)
        for midiNote in 21...108 {
            let frequency = 440.0 * pow(2.0, Double(midiNote - 69) / 12.0)
            frequencies.append(frequency)
        }
        return frequencies
    }()
    
    enum InstrumentMode {
        case piano
        case violin
        case guitar
    }
    
    // MARK: - Initialization
    init() {
        setupAudio()
        setupHaptics()
    }
    
    // MARK: - Audio Setup
    private func setupAudio() {
        do {
            // Configure audio session for low latency
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            // Setup audio engine with proper format
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
            audioEngine.prepare()
            try audioEngine.start()
            
            print("Audio engine started successfully")
        } catch {
            print("Audio setup error: \(error.localizedDescription)")
        }
    }
    
    private func setupOscillatorForMode(_ mode: InstrumentMode) {
        stopSound()
        instrumentMode = mode
    }
    
    private func generateTone(frequency: Double, duration: Double = 1.0) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        guard let leftChannel = buffer.floatChannelData?[0],
              let rightChannel = buffer.floatChannelData?[1] else { return nil }
        
        let bendMultiplier = pow(2.0, pitchBend / 12.0)
        let finalFrequency = frequency * bendMultiplier
        let angularFrequency = 2.0 * .pi * finalFrequency
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            var sample: Float = 0.0
            
            switch instrumentMode {
            case .piano:
                // Piano: Rich harmonic content with ADSR envelope
                let attackTime = 0.005
                let decayTime = 0.8
                let sustainLevel = 0.6
                let releaseTime = 1.0
                
                // ADSR Envelope
                var envelope = 1.0
                if time < attackTime {
                    envelope = time / attackTime
                } else if time < attackTime + decayTime {
                    let decayProgress = (time - attackTime) / decayTime
                    envelope = 1.0 - (1.0 - sustainLevel) * decayProgress
                } else if time > duration - releaseTime {
                    envelope = sustainLevel * (duration - time) / releaseTime
                } else {
                    envelope = sustainLevel
                }
                
                // Multiple harmonics for rich piano sound
                let fundamental = sin(angularFrequency * time)
                let harmonic2 = sin(angularFrequency * 2.0 * time) * 0.6
                let harmonic3 = sin(angularFrequency * 3.0 * time) * 0.4
                let harmonic4 = sin(angularFrequency * 4.0 * time) * 0.25
                let harmonic5 = sin(angularFrequency * 5.0 * time) * 0.15
                let harmonic6 = sin(angularFrequency * 7.0 * time) * 0.08
                
                sample = Float((fundamental + harmonic2 + harmonic3 + harmonic4 + harmonic5 + harmonic6) * envelope * amplitude * 0.35)
                
            case .violin:
                // Violin: Rich sawtooth with vibrato and bow pressure simulation
                let vibrato = sin(2.0 * .pi * 5.0 * time) * 0.005 // 5Hz vibrato
                let vibratoFreq = angularFrequency * (1.0 + vibrato)
                
                // Sawtooth wave with harmonics
                var sawtoothSum = 0.0
                for harmonic in 1...8 {
                    sawtoothSum += sin(vibratoFreq * Double(harmonic) * time) / Double(harmonic)
                }
                
                // Smooth envelope for bowing
                let bowEnvelope = min(1.0, time * 10.0) // Quick attack
                sample = Float(sawtoothSum * bowEnvelope * amplitude * 0.25)
                
            case .guitar:
                // Guitar: Karplus-Strong inspired pluck with natural decay
                let pluckDecay = exp(-1.5 * time) // Slower decay for sustain
                
                // Multiple harmonics with different decay rates
                var pluckSum = 0.0
                for harmonic in 1...8 {
                    let harmonicDecay = exp(-Double(harmonic) * 0.8 * time)
                    pluckSum += sin(angularFrequency * Double(harmonic) * time) * harmonicDecay / Double(harmonic)
                }
                
                // Add some brightness at the attack
                let brightness = time < 0.02 ? (0.02 - time) * 50.0 : 0.0
                let noise = Float.random(in: -0.05...0.05) * Float(brightness)
                
                sample = Float(pluckSum * pluckDecay * amplitude * 0.5) + noise
            }
            
            // Write to both channels (stereo)
            leftChannel[frame] = sample
            rightChannel[frame] = sample
        }
        
        return buffer
    }
    
    private func stopSound() {
        if isPlaying {
            playerNode.stop()
            isPlaying = false
        }
    }
    
    // MARK: - Haptics Setup
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device does not support haptics")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    func switchInstrument(to mode: InstrumentMode) {
        instrumentMode = mode
        setupOscillatorForMode(mode)
    }
    
    func playNote(frequency: Double) {
        currentFrequency = frequency
        checkAndTriggerHaptic()
        
        let duration = instrumentMode == .guitar ? 2.0 : 3.0
        if let buffer = generateTone(frequency: frequency, duration: duration) {
            playerNode.stop()
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            playerNode.play()
            isPlaying = true
            print("Playing note: \(frequency) Hz")
        }
    }
    
    func startContinuousNote(frequency: Double) {
        currentFrequency = frequency
        checkAndTriggerHaptic()
        
        if let buffer = generateTone(frequency: frequency, duration: 5.0) {
            playerNode.stop()
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            playerNode.play()
            isPlaying = true
            print("Starting continuous note: \(frequency) Hz")
        }
    }
    
    func stopContinuousNote() {
        stopSound()
    }
    
    func updatePitchBend(_ bend: Double) {
        pitchBend = max(-2.0, min(2.0, bend))
        // For violin, regenerate the tone with new pitch in real-time
        if isPlaying && instrumentMode == .violin {
            startContinuousNote(frequency: currentFrequency)
        }
        checkAndTriggerHaptic()
    }
    
    func updateAmplitude(_ amp: Double) {
        amplitude = max(0.0, min(1.0, amp))
        // For violin and piano, regenerate with new amplitude
        if isPlaying && (instrumentMode == .violin || instrumentMode == .piano) {
            startContinuousNote(frequency: currentFrequency)
        }
    }
    
    // MARK: - Private Helpers
    private func updateOscillatorFrequency() {
        // Not needed with buffer approach
    }
    
    private func triggerLatchingHaptic() {
        guard let engine = hapticEngine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(eventType: .hapticTransient, 
                                   parameters: [intensity, sharpness], 
                                   relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic playback error: \(error.localizedDescription)")
        }
    }
    
    private func checkAndTriggerHaptic() {
        let bendMultiplier = pow(2.0, pitchBend / 12.0)
        let actualFrequency = currentFrequency * bendMultiplier
        
        // Find closest MIDI note
        var closestIndex = 0
        var smallestDiff = Double.infinity
        
        for (index, freq) in midiNoteFrequencies.enumerated() {
            let diff = abs(actualFrequency - freq)
            if diff < smallestDiff {
                smallestDiff = diff
                closestIndex = index
            }
        }
        
        // Trigger haptic if within 2Hz and changed note
        if smallestDiff <= 2.0 && closestIndex != lastHapticNoteIndex {
            triggerLatchingHaptic()
            lastHapticNoteIndex = closestIndex
        } else if smallestDiff > 2.0 {
            lastHapticNoteIndex = -1
        }
    }
    
    // MARK: - Cleanup
    deinit {
        audioEngine.stop()
        hapticEngine?.stop()
    }
}
