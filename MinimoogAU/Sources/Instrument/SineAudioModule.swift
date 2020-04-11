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

final class SineAudioModule: AudioUnitModule {
//    fileprivate enum ParamAddress: AUParameterAddress {
//        case osc1Range = 0
//        case osc1Volume = 1
//    }

//    let channelCapabilities: [Int] = [0, -1]

//    let parameterTree = AUParameterTree.tree(
//        .group(id: "Osc1", name: "Oscillator 1",
//           .parameter(id: "osc1Range", name: "Range", address: ParamAddress.osc1Range.rawValue, min: -2, max: 2, unit: .octaves),
//           .parameter(id: "osc1Volume", name: "Volume", address: ParamAddress.osc1Volume.rawValue, min: 0, max: 1, unit: .linearGain)
//        )
//    )

//    lazy var factoryPresets: [[String: Any]] = {
//        guard let url = Bundle.main.url(forResource: "FactoryPresets", withExtension: "json"),
//            let data = try? Data(contentsOf: url),
//            let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            else { return [] }
//        return dic?["presets"] as? [[String: Any]] ?? []
//    }()

    fileprivate var timeStep: Float32 = 0
    fileprivate var phase: Float32 = 0
    fileprivate var phaseStep: Float32 = 0
    fileprivate var amplitude: Float32 = 0
    fileprivate var range: Float32 = 0
    fileprivate var volume: Float32 = 0
//    fileprivate var isOn: Bool = false

//    init() {
//        setParameterTreeObservers()
//    }

//    func setAudioFormat(_ format: AVAudioFormat) {
//        self.timeStep = 1.0 / Float32(format.sampleRate)
//    }

//    func setParameter(address: AUParameterAddress, value: AUValue) {
//        guard let address = ParamAddress(rawValue: address) else { return }
//        setParameter(address: address, value: value)
//    }

    /*
    func handle(midiEvent: MidiEvent) {
        switch midiEvent {
        case .noteOn(_, let note, let velocity):
            phaseStep = 2 * Float32.pi * note.frequency * timeStep
            amplitude = Float32(velocity.value) / 127
            isOn = true

        case .noteOff(_, _, _):
            isOn = false

        default:
            break
        }
    }
    */

    override func doRender() {
        for idx in 0..<samplesNumber {
            phase += phaseStep
            if phase > 2 * Float32.pi {
                phase -= 2 * Float32.pi
            }

            let sampleValue = volume * amplitude * sin(phase)
            audioOutput?[idx] = sampleValue
        }
    }
}

//extension SineGenerator {
//    var presetForCurrentState: [String: Any] {
//        let keyValuePairs = parameterTree.allParameters.map { ($0.identifier, $0.value) }
//        return Dictionary(uniqueKeysWithValues: keyValuePairs)
//    }
//
//    func load(preset: [String: Any]) {
//        parameterTree.allParameters.forEach { parameter in
//            guard let value = preset[parameter.identifier] as? AUValue else { return }
//            parameter.value = value
//        }
//    }
//}

//fileprivate extension SineGenerator {
//    func setParameterTreeObservers() {
//        parameterTree.implementorValueObserver = { [weak self] param, value in
//            guard let address = ParamAddress(rawValue: param.address) else { return }
//            self?.setParameter(address: address, value: value)
//        }
//
//        parameterTree.implementorValueProvider = { [weak self] param in
//            guard let self = self, let address = ParamAddress(rawValue: param.address) else { return 0 }
//            return self.getParameter(address: address)
//        }
//
////        parameterTree.implementorStringFromValueCallback = { param, valuePtr in
////            let value = valuePtr?.pointee ?? param.value
////
////            if param.unit == .indexed, let strings = param.valueStrings, Int(value) < strings.count {
////                return strings[Int(value)]
////            } else {
////                return String(format: ".2", value)
////            }
////        }
//    }
//
//    func setParameter(address: ParamAddress, value: AUValue) {
//        switch address {
//        case .osc1Range: range = value
//        case .osc1Volume: volume = value
//        }
//    }
//
//    func getParameter(address: ParamAddress) -> AUValue {
//        switch address {
//        case .osc1Range: return self.range
//        case .osc1Volume: return self.volume
//        }
//    }
//}
