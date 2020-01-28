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
