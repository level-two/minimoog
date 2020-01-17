import AudioToolbox

protocol Module {
    init(sampleRate: Float32)

    var parameters: [AUParameter] { get }
    func process(midiEvent: MidiEvent)
    func setParameter(address: AUParameterAddress, value: AUValue)
    func getParameter(address: AUParameterAddress) -> AUValue
    func render(leftSample: UnsafeMutablePointer<Float32>, rightSample: UnsafeMutablePointer<Float32>)
}
