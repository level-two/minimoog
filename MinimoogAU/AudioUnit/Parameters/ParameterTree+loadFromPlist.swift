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

import AudioToolbox

enum AUParameterTreeError: Error {
    case failedLoadParameters
}

extension AUParameterTree {
    class func createTree(from plistFile: String, bundle: Bundle = .main) throws -> AUParameterTree {
        guard let plistUrl = bundle.url(forResource: plistFile, withExtension: nil) else {
            throw AUParameterTreeError.failedLoadParameters
        }

        let data = try Data(contentsOf: plistUrl)
        let dic = try PropertyListDecoder().decode([String:ParameterDef].self, from: data)
        let parameters = dic.map(AUParameter.make)

        return AUParameterTree.createTree(withChildren: parameters)
    }
}
