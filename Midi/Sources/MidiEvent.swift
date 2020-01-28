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

public enum MidiEvent {
    case noteOff(Channel, Note, Velocity)
    case noteOn(Channel, Note, Velocity)
    case controlChange(Channel, ControlValue, Velocity)
    case pitchBend(Channel, Pitch)
    case allNotesOff(Channel)

    public init?(from auMidiEvent: AUMIDIEvent) {
        guard auMidiEvent.length == 3 else { return nil }

        guard let channel = Channel(rawValue: Int(auMidiEvent.data.0) & 0x0f) else { return nil }

        let message = auMidiEvent.data.0 & 0xf0
        let data0 = Int(auMidiEvent.data.1)
        let data1 = Int(auMidiEvent.data.2)

        switch message {
        case 0x80:
            self = .noteOff(channel, Note(data0), Velocity(data1))
        case 0x90:
            self = .noteOn(channel, Note(data0), Velocity(data1))
        case 0xb0:
            if data1 == 0x7b {
                self = .allNotesOff(channel)
            } else {
                self = .controlChange(channel, ControlValue(data0), Velocity(data1))
            }
        case 0xe0:
            self = .pitchBend(channel, Pitch(data1 << 7 | data0))
        default:
            return nil
        }
    }
}
