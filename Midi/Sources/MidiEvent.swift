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

public struct MidiEvent {
    public let type: MidiEventType
    public let channel: Channel
    public var note: Int { return data1 }
    public var velocity: Int { return data2 }
    public var controlChange: Int { return data1 }
    public var pitch: Int { return data2 << 7 | data1 }

    public init?(from auMidiEvent: AUMIDIEvent) {
        let data0 = Int(auMidiEvent.data.0)

        let message = data0 & 0xf0

        switch message {
        case 0x80: type = .noteOff
        case 0x90: type = .noteOn
        case 0xb0 where auMidiEvent.data.1 == 0x7b: type = .allNotesOff
        case 0xb0: type = .controlChange
        case 0xe0: type = .pitchBend
        default: return nil
        }

        channel = Channel(rawValue: data0 & 0x0f)!

        data1 = Int(auMidiEvent.data.1)
        data2 = Int(auMidiEvent.data.2)
    }

    private let data1: Int
    private let data2: Int
}
