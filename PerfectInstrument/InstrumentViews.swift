import SwiftUI

// MARK: - Piano View
struct PianoView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var keyWidth: CGFloat
    
    @State private var scrollOffset: CGFloat = 0
    
    private let whiteNotes = ["C", "D", "E", "F", "G", "A", "B"]
    private let octaves = 4
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<(whiteNotes.count * octaves), id: \.self) { index in
                            let octave = 3 + (index / whiteNotes.count)
                            let noteIndex = index % whiteNotes.count
                            let noteName = whiteNotes[noteIndex]
                            
                            PianoKey(
                                noteName: noteName,
                                octave: octave,
                                isBlack: false,
                                width: keyWidth,
                                audioManager: audioManager
                            )
                            .id(index)
                            .overlay(alignment: .topTrailing) {
                                if hasBlackKeyAfter(noteIndex) {
                                    PianoKey(
                                        noteName: getBlackNoteName(noteIndex),
                                        octave: octave,
                                        isBlack: true,
                                        width: keyWidth * 0.55,
                                        audioManager: audioManager
                                    )
                                    .offset(x: keyWidth * 0.275)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    // Scroll to middle octave on appear
                    proxy.scrollTo(7, anchor: .center)
                }
                
                // Navigation buttons - Visible at bottom
                HStack {
                    Button(action: {
                        withAnimation {
                            scrollOffset = max(0, scrollOffset - keyWidth * 7)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            scrollOffset = scrollOffset + keyWidth * 7
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 10)
            }
        }
    }
    
    private func hasBlackKeyAfter(_ noteIndex: Int) -> Bool {
        // Black keys after C, D, F, G, A (not after E and B)
        return noteIndex != 2 && noteIndex != 6
    }
    
    private func getBlackNoteName(_ noteIndex: Int) -> String {
        let blackNotes = ["C#", "D#", "", "F#", "G#", "A#", ""]
        return blackNotes[noteIndex]
    }
}

// MARK: - Piano Key
struct PianoKey: View {
    let noteName: String
    let octave: Int
    let isBlack: Bool
    let width: CGFloat
    let audioManager: AudioManager
    
    @State private var isPressed = false
    
    private var frequency: Double {
        // Convert note to MIDI number and calculate frequency
        let noteOffsets = ["C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, 
                          "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11]
        let offset = noteOffsets[noteName] ?? 0
        let midiNote = (octave + 1) * 12 + offset
        return 440.0 * pow(2.0, Double(midiNote - 69) / 12.0)
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: isBlack ? 
                        [Color.black, Color(red: 0.2, green: 0.2, blue: 0.2)] :
                        [Color.white, Color(red: 0.95, green: 0.95, blue: 1.0)]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: isBlack ? 100 : 180)
            .overlay(
                Rectangle()
                    .stroke(isBlack ? Color.white.opacity(0.3) : Color.black.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isPressed ? 0.1 : 0.4), radius: isPressed ? 2 : 5, y: isPressed ? 1 : 3)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            audioManager.playNote(frequency: frequency)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        audioManager.stopContinuousNote()
                    }
            )
            .overlay(
                Text(noteName)
                    .font(.caption)
                    .foregroundColor(isBlack ? .white : .black)
                    .padding(.bottom, 8),
                alignment: .bottom
            )
    }
}

// MARK: - Violin View
struct ViolinView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var keyWidth: CGFloat
    
    @State private var isDragging = false
    @State private var currentPosition: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Rich wooden background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.1),
                        Color(red: 0.6, green: 0.3, blue: 0.15),
                        Color(red: 0.5, green: 0.25, blue: 0.12)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                HStack(spacing: 15) {
                    // Fretboard markers
                    VStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { position in
                            HStack {
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 12, height: 12)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                                Spacer()
                            }
                            .frame(height: geometry.size.height / 12)
                        }
                    }
                    .frame(width: 25)
                    
                    // String area with glow
                    ZStack {
                        // String glow when playing
                        if isDragging {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange.opacity(0.3), .yellow.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .blur(radius: 20)
                        }
                        
                        // Strings
                        VStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { stringIndex in
                                Spacer()
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 0.8, green: 0.7, blue: 0.4), Color(red: 0.9, green: 0.8, blue: 0.5)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 4)
                                    .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                                Spacer()
                            }
                        }
                        
                        // Position indicator
                        if isDragging {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 30, height: 30)
                                .shadow(color: .orange, radius: 10)
                                .position(x: currentPosition, y: geometry.size.height / 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                }
                                currentPosition = value.location.x
                                
                                // Map X position to frequency
                                let width = geometry.size.width - 60
                                let normalizedX = max(0, min(1, (value.location.x - 40) / width))
                                let frequency = 200 + (1800 * normalizedX)
                                
                                audioManager.startContinuousNote(frequency: frequency)
                            }
                            .onEnded { _ in
                                isDragging = false
                                audioManager.stopContinuousNote()
                            }
                    )
                    
                    Spacer()
                        .frame(width: 10)
                }
                .padding()
            }
        }
    }
}

// MARK: - Guitar View
struct GuitarView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var keyWidth: CGFloat
    
    private let strings = [
        (name: "E", baseFreq: 329.63, color: Color(red: 0.9, green: 0.9, blue: 0.7)),
        (name: "B", baseFreq: 246.94, color: Color(red: 0.9, green: 0.85, blue: 0.6)),
        (name: "G", baseFreq: 196.00, color: Color(red: 0.85, green: 0.75, blue: 0.5)),
        (name: "D", baseFreq: 146.83, color: Color(red: 0.8, green: 0.65, blue: 0.4)),
        (name: "A", baseFreq: 110.00, color: Color(red: 0.75, green: 0.55, blue: 0.3)),
        (name: "E", baseFreq: 82.41, color: Color(red: 0.7, green: 0.45, blue: 0.2))
    ]
    private let frets = 12
    
    var body: some View {
        ZStack {
            // Guitar wood background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.2, blue: 0.1),
                    Color(red: 0.4, green: 0.25, blue: 0.12)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            GeometryReader { geometry in
                VStack(spacing: 3) {
                    ForEach(Array(strings.enumerated()), id: \.offset) { stringIndex, string in
                        HStack(spacing: 0) {
                            // String label with glow
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: 28, height: 28)
                                Text(string.name)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .shadow(color: string.color, radius: 3)
                            }
                            .frame(width: 35)
                            
                            // Frets with gradient
                            let fretWidth = (geometry.size.width - 50) / CGFloat(frets + 1)
                            ForEach(0...frets, id: \.self) { fret in
                                GuitarFretButton(
                                    stringName: string.name,
                                    fret: fret,
                                    baseFrequency: string.baseFreq,
                                    stringColor: string.color,
                                    width: fretWidth,
                                    audioManager: audioManager
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Guitar Fret Button
struct GuitarFretButton: View {
    let stringName: String
    let fret: Int
    let baseFrequency: Double
    let stringColor: Color
    let width: CGFloat
    let audioManager: AudioManager
    
    @State private var isPressed = false
    
    private var frequency: Double {
        return baseFrequency * pow(2.0, Double(fret) / 12.0)
    }
    
    var body: some View {
        ZStack {
            // Fret background
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: fret == 0 ?
                            [Color(red: 0.3, green: 0.2, blue: 0.1), Color(red: 0.4, green: 0.25, blue: 0.12)] :
                            [Color(red: 0.25, green: 0.15, blue: 0.08), Color(red: 0.35, green: 0.2, blue: 0.1)]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: 45)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Fret marker
            if [3, 5, 7, 9, 12].contains(fret) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            
            // Pressed effect
            if isPressed {
                Rectangle()
                    .fill(stringColor.opacity(0.6))
                    .frame(width: width, height: 45)
                    .blur(radius: 5)
            }
            
            // Fret number
            Text("\(fret)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .onTapGesture {
            isPressed = true
            audioManager.playNote(frequency: frequency)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
            }
        }
    }
}
