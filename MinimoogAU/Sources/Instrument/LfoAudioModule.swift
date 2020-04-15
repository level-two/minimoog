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

final class LfoAudioModule: AudioUnitModule {
    init(midiEventQueueManager: MidiEventQueueManager) {
        noteOnEvent = midiEventQueueManager.makeQueue(for: .noteOn)
        noteOffEvent = midiEventQueueManager.makeQueue(for: .noteOff)
    }

    override func doRender(_ frameCount: AUAudioFrameCount) {
        for frame in 0..<frameCount {
            cvOutput?[frame] = 0

            if let _ = noteOnEvent.event(at: frame) {
//                phase = 0

                let frequency = Float32(0.5)
                phaseStep = 2 * Float32.pi * frequency / sampleRate

                isOn = true
            }

            if let _ = noteOffEvent.event(at: frame) {
                isOn = false
            }

            guard isOn else { continue }

            phase += phaseStep
            if phase > 2 * Float32.pi {
                phase -= 2 * Float32.pi
            }

            let cvValue = sin(phase)
            cvOutput?[frame] = cvValue
        }
    }

    // events
    private let noteOnEvent: MidiEventQueue
    private let noteOffEvent: MidiEventQueue

    // state
    private var phase: Float32 = 0
    private var phaseStep: Float32 = 0
    private var isOn: Bool = false

    // params
    private var amplitude: Float32 = 0
}
