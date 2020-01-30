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
import Midi

public protocol Instrument: class {
    var parameterTree: AUParameterTree { get }
    var channelCapabilities: [Int] { get }

    var factoryPresets: [[String: Any]]  { get }
    var presetForCurrentState: [String: Any] { get }
    func load(preset: [String: Any])

    func setAudioFormat(_ format: AVAudioFormat)
    func setParameter(address: AUParameterAddress, value: AUValue)
    func handle(midiEvent: MidiEvent)
    func render(to buffers: [UnsafeMutablePointer<Float32>], frames: AUAudioFrameCount)
}
