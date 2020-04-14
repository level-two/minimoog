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

final class SineGenerator: Instrument {
    fileprivate enum ParamAddress: AUParameterAddress {
        case osc1Range = 0
        case osc1Volume = 1
    }

    let channelCapabilities: [Int] = [0, -1]

    let parameterTree = AUParameterTree.tree(
        .group(id: "Osc1", name: "Oscillator 1",
           .parameter(id: "osc1Range", name: "Range", address: ParamAddress.osc1Range.rawValue, min: -2, max: 2, unit: .octaves),
           .parameter(id: "osc1Volume", name: "Volume", address: ParamAddress.osc1Volume.rawValue, min: 0, max: 1, unit: .linearGain)
        )
    )

    lazy var factoryPresets: [[String: Any]] = {
        guard let url = Bundle.main.url(forResource: "FactoryPresets", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return [] }
        return dic?["presets"] as? [[String: Any]] ?? []
    }()

    let outputModule = OutputModule()
    let midiEventQueueManager = MidiEventQueueManager()

    init() {
        let sineModule = SineAudioModule(midiEventQueueManager: midiEventQueueManager)
        sineModule --> outputModule
        setParameterTreeObservers()
    }

    func setParameter(address: AUParameterAddress, value: AUValue) {
//        guard let address = ParamAddress(rawValue: address) else { return }
//        setParameter(address: address, value: value)
    }

}

extension SineGenerator {
    var presetForCurrentState: [String: Any] {
        let keyValuePairs = parameterTree.allParameters.map { ($0.identifier, $0.value) }
        return Dictionary(uniqueKeysWithValues: keyValuePairs)
    }

    func load(preset: [String: Any]) {
        parameterTree.allParameters.forEach { parameter in
            guard let value = preset[parameter.identifier] as? AUValue else { return }
            parameter.value = value
        }
    }
}

fileprivate extension SineGenerator {
    func setParameterTreeObservers() {
//        parameterTree.implementorValueObserver = { [weak self] param, value in
//            guard let address = ParamAddress(rawValue: param.address) else { return }
//            self?.setParameter(address: address, value: value)
//        }

//        parameterTree.implementorValueProvider = { [weak self] param in
//            guard let self = self, let address = ParamAddress(rawValue: param.address) else { return 0 }
//            return self.getParameter(address: address)
//        }

//        parameterTree.implementorStringFromValueCallback = { param, valuePtr in
//            let value = valuePtr?.pointee ?? param.value
//
//            if param.unit == .indexed, let strings = param.valueStrings, Int(value) < strings.count {
//                return strings[Int(value)]
//            } else {
//                return String(format: ".2", value)
//            }
//        }
    }

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
}
