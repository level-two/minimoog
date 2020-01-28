import AudioToolbox

public extension AUAudioUnit {
    public static func create(with instrument: Instrument,
                              componentDescription: AudioComponentDescription,
                              options: AudioComponentInstantiationOptions = []) throws -> AUAudioUnit {
        return try AudioUnitBase(with: instrument, componentDescription: componentDescription, options: options)
    }
}
