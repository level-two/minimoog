// -----------------------------------------------------------------------------
//    Copyright (C) 2019 Yauheni Lychkouski.
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

import Foundation

enum ParameterId: AUParameterAddress, CaseIterable {
    case osc1Range = 0
    case osc1Waveform
    case osc2Range
    case osc2Detune
    case osc2Waveform
    case mixOsc1Volume
    case mixOsc2Volume
    case mixNoiseVolume

    var address: AUParameterAddress {
        return self.rawValue
    }

    var identifier: String {
        switch self {
        case .osc1Range: return "osc1Range"
        case .osc1Waveform: return "osc1Waveform"
        case .osc2Range: return "osc2Range"
        case .osc2Detune: return "osc2Detune"
        case .osc2Waveform: return "osc2Waveform"
        case .mixOsc1Volume: return "mixOsc1Volume"
        case .mixOsc2Volume: return "mixOsc2Volume"
        case .mixNoiseVolume: return "mixNoiseVolume"
        }
    }
}

struct ParameterDescription {
    var id: ParameterId
    var name: String
    var shortName: String
    var min: Float
    var max: Float
    var step: Float
    var initValue: Float
    var unit: AudioUnitParameterUnit
    var valueStrings: [String]?

    var address: AUParameterAddress { return id.address }
    var identifier: String { return id.identifier }
}

struct AUDescription {
    public static let parameters: [ParameterDescription] = [
        .init(id: .osc1Range, name: "Oscillator 1 Range", shortName: "Range", min: 1, max: 6, step: 1, initValue: 2, unit: .indexed, valueStrings: ["LO", "32'", "16'", "8'", "4'", "2'"]),
        .init(id: .osc1Waveform, name: "Oscillator 1 Waveform", shortName: "Waveform", min: 1, max: 6, step: 1, initValue: 1, unit: .indexed, valueStrings: ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
        .init(id: .osc2Range, name: "Oscillator 2 Range", shortName: "Range", min: 1, max: 6, step: 1, initValue: 2, unit: .indexed, valueStrings: ["LO", "32'", "16'", "8'", "4'", "2'"]),
        .init(id: .osc2Detune, name: "Oscillator 2 Detune", shortName: "Detune", min: -1200, max: 1200, step: 0, initValue: 0, unit: .cents, valueStrings: nil),
        .init(id: .osc2Waveform, name: "Oscillator 2 Waveform", shortName: "Waveform", min: 1, max: 6, step: 1, initValue: 1, unit: .indexed, valueStrings: ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
        .init(id: .mixOsc1Volume, name: "Mixer Oscillator 1 Volume", shortName: "Osc1", min: 0, max: 10, step: 0, initValue: 10, unit: .customUnit, valueStrings: nil),
        .init(id: .mixOsc2Volume, name: "Mixer Oscillator 2 Volume", shortName: "Osc2", min: 0, max: 10, step: 0, initValue: 0, unit: .customUnit, valueStrings: nil),
        .init(id: .mixNoiseVolume, name: "Mixer Noise Volume", shortName: "Noise", min: 0, max: 10, step: 0, initValue: 0, unit: .customUnit, valueStrings: nil)
    ]
}

extension AUParameterTree {
    static func createParameter(with description: ParameterDescription) -> AUParameter {
        return AUParameterTree.createParameter(
                 withIdentifier: description.identifier,
                           name: description.name,
                        address: description.address,
                            min: AUValue(description.min),
                            max: AUValue(description.max),
                           unit: description.unit,
                       unitName: nil,
                          flags: [.flag_IsWritable, .flag_IsReadable],
                   valueStrings: description.valueStrings,
            dependentParameters: nil
        )
    }
}
