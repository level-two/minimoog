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

enum AUParameterTreeError: Error {
    case failedLoadParameters
}

extension AUParameterTree {
    static func load(from plistFile: String) throws -> AUParameterTree {
        guard let plistUrl = Bundle.main.url(forResource: plistFile, withExtension: nil) else {
            throw AUParameterTreeError.failedLoadParameters
        }

        let data = try Data(contentsOf: plistUrl)
        let descriptions = try PropertyListDecoder().decode([ParameterDescription].self, from: data)
        let parameters = descriptions.map(AUParameterTree.createParameter)

        return AUParameterTree.createTree(withChildren: parameters)
    }

    fileprivate static func createParameter(with description: ParameterDescription) -> AUParameter {
        return AUParameterTree.createParameter(
            withIdentifier: description.identifier,
            name: description.name,
            address: description.address,
            min: AUValue(description.minValue),
            max: AUValue(description.maxValue),
            unit: description.unit ?? .customUnit,
            unitName: nil,
            flags: [.flag_IsWritable, .flag_IsReadable],
            valueStrings: description.valueStrings,
            dependentParameters: nil
        )
    }
}
