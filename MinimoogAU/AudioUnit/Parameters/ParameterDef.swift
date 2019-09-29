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

struct ParameterDef: Decodable {
    var address: AUParameterAddress
    var name: String
    var minValue: Double
    var maxValue: Double
    var step: Double?
    var unit: AudioUnitParameterUnit?
    var valueStrings: [String]?

    enum CodingKeys: String, CodingKey {
        case address
        case name
        case minValue
        case maxValue
        case step
        case unit
        case valueStrings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(AUParameterAddress.self, forKey: .address)
        name = try container.decode(String.self, forKey: .name)
        minValue = try container.decode(Double.self, forKey: .minValue)
        maxValue = try container.decode(Double.self, forKey: .maxValue)
        step = try? container.decode(Double.self, forKey: .step)
        if let unitVal = try? container.decode(UInt32.self, forKey: .unit) {
            unit = AudioUnitParameterUnit(rawValue: unitVal)
        }
        valueStrings = try? container.decode([String].self, forKey: .valueStrings)
    }
}
