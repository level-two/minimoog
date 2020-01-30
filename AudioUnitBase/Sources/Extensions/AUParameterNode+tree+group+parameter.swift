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

extension AUParameterNode {
    public static func parameter(id: String, name: String, address: AUParameterAddress, min: AUValue, max: AUValue, unit: AudioUnitParameterUnit = .generic, unitName: String? = nil, valueStrings: [String]? = nil) -> AUParameter {
        return AUParameterTree.createParameter(withIdentifier: id, name: name, address: address, min: min, max: max, unit: unit, unitName: unitName, flags: [.flag_IsReadable, .flag_IsWritable], valueStrings: valueStrings, dependentParameters: nil)
    }

    public static func group(id: String, name: String, _ children: AUParameterNode...) -> AUParameterGroup {
        return AUParameterTree.createGroup(withIdentifier: id, name: name, children: children)
    }

    public static func tree(_ children: AUParameterNode...) -> AUParameterTree {
        return AUParameterTree.createTree(withChildren: children)
    }
}
