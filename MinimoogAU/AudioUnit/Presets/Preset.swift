// -----------------------------------------------------------------------------
//    Copyright (C) 2018 Yauheni Lychkouski.
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

import AVFoundation

class Preset {
    public var name = ""
    public var index = 0
    public var dictionary = [String: Double]()

    public var fullState: [String: Any]? {
        get {
            return ["Name": name, "Index": index, "presetDic": dictionary]
        }

        set {
            guard let state = newValue,
                let name = state["Name"] as? String,
                let index = state["Index"] as? Int,
                let dictionary = state["presetDic"] as? [String: Double]
            else {
                print("Failed to init preset from the full state")
                return
            }

            self.name = name
            self.index = index
            self.dictionary = dictionary
        }
    }

    init(index: Int, name: String, dictionary: [String: Double]) {
        self.name = name
        self.index = index
        self.dictionary = dictionary
    }

    init(index: Int, name: String, parameters: [AUParameter]?) {
        self.name = name
        self.index = index
        self.dictionary =
            parameters?.reduce(into: [String: Double]() ) { dictionary, parameter in
                dictionary[parameter.identifier] = Double(parameter.value)
            } ?? [:]
    }

    init(with fullState: [String: Any]?) {
        self.fullState = fullState
    }

    public func presetValue(for id: String) -> AUValue? {
        return dictionary[id].map { AUValue($0) }
    }
}

extension AUAudioUnitPreset {
    convenience init?(with preset: Preset?) {
        guard let preset = preset else { return nil }
        self.init()
        self.name = preset.name
        self.number = preset.index
    }
}
