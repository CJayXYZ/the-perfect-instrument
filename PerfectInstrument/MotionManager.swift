import CoreMotion
import Combine

class MotionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var pitchBend: Double = 0.0      // -2.0 to 2.0 (from roll)
    @Published var modulation: Double = 0.5     // 0.0 to 1.0 (from pitch/tilt)
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 0.01 // 100Hz updates
    
    // MARK: - Initialization
    init() {
        setupMotionUpdates()
    }
    
    // MARK: - Motion Setup
    private func setupMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Motion update error: \(error.localizedDescription)")
                }
                return
            }
            
            self.processMotionData(motion)
        }
    }
    
    // MARK: - Motion Processing
    private func processMotionData(_ motion: CMDeviceMotion) {
        let attitude = motion.attitude
        
        // In landscape orientation:
        // Pitch (tilt left/right) controls pitch bend (-2 to +2 semitones)
        let pitch = attitude.pitch
        let normalizedPitch = pitch / (.pi / 2.0) // -1.0 to 1.0
        pitchBend = normalizedPitch * 2.0 // -2.0 to 2.0
        
        // Roll (tilt forward/backward) controls modulation/amplitude
        // More sensitive - use smaller divisor for wider range
        let roll = attitude.roll
        
        // Map roll to 0.0-1.0 range with higher sensitivity
        // Dividing by pi/3 instead of pi makes it 3x more sensitive
        let normalizedRoll = (roll / (.pi / 3.0)) // More sensitive range
        modulation = max(0.0, min(1.0, (normalizedRoll + 1.0) / 2.0))
    }
    
    // MARK: - Public Methods
    func start() {
        if !motionManager.isDeviceMotionActive {
            setupMotionUpdates()
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func reset() {
        pitchBend = 0.0
        modulation = 0.5
    }
    
    // MARK: - Cleanup
    deinit {
        stop()
    }
}
