import AudioToolbox
import Midi

final class SineModule: Module {
    var parameters: [AUParameter] = []

    private let sampleRate: Float32
    private let timeStep: Float32

    private var phase: Float32 = 0.0
    private var phaseStep: Float32 = 0.0
    private var amplitude: Float32 = 0.0
    private var isOn: Bool = false

    init(sampleRate: Float32) {
        self.sampleRate = sampleRate
        self.timeStep = 1.0 / sampleRate
    }

    func handle(midiEvent: MidiEvent) {
        switch midiEvent {
        case .noteOn(let channel, let note, let velocity):
            phaseStep = 2 * Float32.pi * note.frequency * timeStep
            amplitude = Float32(velocity) / 127
            isOn = true

        case .noteOff(let channel, let note, let velocity):
            isOn = false

        default:
            break
        }
    }

    func setParameter(address: AUParameterAddress, value: AUValue) {
        // TBD
    }

    func getParameter(address: AUParameterAddress) -> AUValue {
        // TBD
        return 0
    }

    func render(leftSample: UnsafeMutablePointer<Float32>, rightSample: UnsafeMutablePointer<Float32>) {
        guard isOn else {
            leftSample.initialize(to: 0)
            rightSample.initialize(to: 0)
            return
        }

        phase += phaseStep
        if phase > 2 * Float32.pi {
            phase -= 2 * Float32.pi
        }

        let sampleValue = amplitude * sin(phase)
        leftSample.initialize(to: sampleValue)
        rightSample.initialize(to: sampleValue)
    }
}
