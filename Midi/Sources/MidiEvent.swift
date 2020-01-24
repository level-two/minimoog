
public enum MidiEvent {
    case noteOff(Channel, Note, Velocity)
    case noteOn(Channel, Note, Velocity)
    case controlChange(Channel, ControlValue, Velocity)
    case pitchBend(Channel, Pitch)
    case allNotesOff(Channel)
}
