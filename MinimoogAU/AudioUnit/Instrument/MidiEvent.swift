import AudioToolbox

enum MidiEvent {
    case noteOff(Channel, Note, Velocity)
    case noteOn(Channel, Note, Velocity)
    case controlChange(Channel, UInt8, Velocity)
    case pitchBend(Channel, UInt16)

    init?(from auMidiEvent: AUMIDIEvent) {
        guard auMidiEvent.length == 3 else { return nil }

        let message = auMidiEvent.data.0 & 0x70
        let channel = auMidiEvent.data.0 & 0x0f
        let data0 = auMidiEvent.data.1
        let data1 = auMidiEvent.data.2

        switch message {
        case 0x80: // off
            self = .noteOn(channel, data0, data1)
        case 0x90: // on
            break
        case 0xb0: // cc
            // uint8_t cc_num = midiEvent.data[1];
            // if (cc_num == 0x7b) { // all notes off
            break
        case 0xe0: // pitch
            break
        default:
            return nil
        }
    }
}
