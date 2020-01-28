// -----------------------------------------------------------------------------
//    Copyright (C) 2020 Yauheni Lychkouski.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

import AudioToolbox
import AVFoundation
import AudioUnitBase
import Midi

final class SineGenerator: Instrument {
    var parameters: [AUParameter] = []

    private var timeStep: Float32 = 0

    private var phase: Float32 = 0.0
    private var phaseStep: Float32 = 0.0
    private var amplitude: Float32 = 0.0
    private var isOn: Bool = false

    func setAudioFormat(_ format: AVAudioFormat) {
        self.timeStep = 1.0 / Float32(format.sampleRate)
    }

    func handle(midiEvent: MidiEvent) {
        switch midiEvent {
        case .noteOn(_, let note, let velocity):
            phaseStep = 2 * Float32.pi * note.frequency * timeStep
            amplitude = Float32(velocity.value) / 127
            isOn = true

        case .noteOff(_, _, _):
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
