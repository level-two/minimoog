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

extension AUParameter {
    static func make(_ identifier: String, _ parameterDef: ParameterDef) -> AUParameter {
        return AUParameterTree.createParameter(
            withIdentifier: identifier,
            name: parameterDef.name,
            address: parameterDef.address,
            min: AUValue(parameterDef.minValue),
            max: AUValue(parameterDef.maxValue),
            unit: parameterDef.unit ?? .customUnit,
            unitName: nil,
            flags: [.flag_IsWritable, .flag_IsReadable],
            valueStrings: parameterDef.valueStrings,
            dependentParameters: nil
        )
    }
}
