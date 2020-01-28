import AudioToolbox
import AVFoundation
import Midi

public protocol Instrument {
    var parameters: [AUParameter] { get }
    func handle(midiEvent: MidiEvent)
    func setAudioFormat(_ format: AVAudioFormat)
    func setParameter(address: AUParameterAddress, value: AUValue)
    func getParameter(address: AUParameterAddress) -> AUValue
    func render(leftSample: UnsafeMutablePointer<Float32>, rightSample: UnsafeMutablePointer<Float32>)
}
