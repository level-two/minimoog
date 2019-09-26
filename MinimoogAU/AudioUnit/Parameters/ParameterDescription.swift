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

struct ParameterDescription: Decodable {
    var address: AUParameterAddress
    var identifier: String
    var name: String
    var shortName: String
    var minValue: Double
    var maxValue: Double
    var step: Double?
    var unit: AudioUnitParameterUnit?
    var valueStrings: [String]?

    enum CodingKeys: String, CodingKey {
        case address
        case identifier
        case name
        case shortName
        case minValue
        case maxValue
        case step
        case unit
        case valueStrings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        address = try container.decode(AUParameterAddress.self, forKey: .address)
        identifier = try container.decode(String.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
        shortName = try container.decode(String.self, forKey: .shortName)
        minValue = try container.decode(Double.self, forKey: .minValue)
        maxValue = try container.decode(Double.self, forKey: .maxValue)
        step = try? container.decode(Double.self, forKey: .step)
        if let unitVal = try? container.decode(UInt32.self, forKey: .unit) {
            unit = AudioUnitParameterUnit(rawValue: unitVal)
        }
        valueStrings = try? container.decode([String].self, forKey: .valueStrings)
    }
}

//
//struct AUDescription {
//    public static let parameters: [ParameterDescription] = [
//        .init(id: .osc1Range, name: "Oscillator 1 Range", shortName: "Range", min: 1, max: 6, step: 1, initValue: 2, unit: .indexed, valueStrings: ["LO", "32'", "16'", "8'", "4'", "2'"]),
//        .init(id: .osc1Waveform, name: "Oscillator 1 Waveform", shortName: "Waveform", min: 1, max: 6, step: 1, initValue: 1, unit: .indexed, valueStrings: ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
//        .init(id: .osc2Range, name: "Oscillator 2 Range", shortName: "Range", min: 1, max: 6, step: 1, initValue: 2, unit: .indexed, valueStrings: ["LO", "32'", "16'", "8'", "4'", "2'"]),
//        .init(id: .osc2Detune, name: "Oscillator 2 Detune", shortName: "Detune", min: -1200, max: 1200, step: 0, initValue: 0, unit: .cents, valueStrings: nil),
//        .init(id: .osc2Waveform, name: "Oscillator 2 Waveform", shortName: "Waveform", min: 1, max: 6, step: 1, initValue: 1, unit: .indexed, valueStrings: ["Triangle", "Ramp", "Sawtooth", "Square", "Pulse1", "Pulse2"]),
//        .init(id: .mixOsc1Volume, name: "Mixer Oscillator 1 Volume", shortName: "Osc1", min: 0, max: 10, step: 0, initValue: 10, unit: .customUnit, valueStrings: nil),
//        .init(id: .mixOsc2Volume, name: "Mixer Oscillator 2 Volume", shortName: "Osc2", min: 0, max: 10, step: 0, initValue: 0, unit: .customUnit, valueStrings: nil),
//        .init(id: .mixNoiseVolume, name: "Mixer Noise Volume", shortName: "Noise", min: 0, max: 10, step: 0, initValue: 0, unit: .customUnit, valueStrings: nil)
//    ]
//}




