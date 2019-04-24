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

class MinimoogAUPreset {
    public var presetName  = ""
    public var presetIndex = 0
    public var presetDic   = [String: Double]()

    public var fullState: [String: Any]? {
        get {
            return ["Name": presetName, "Index": presetIndex, "presetDic": presetDic]
        }

        set {
            guard
                let state       = newValue,
                let presetName  = state["Name"] as? String,
                let presetIndex = state["Index"] as? Int,
                let presetDic   = state["presetDic"] as? [String: Double]
            else {
                print("Failed to init preset from the full state")
                return
            }

            self.presetName  = presetName
            self.presetIndex = presetIndex
            self.presetDic   = presetDic
        }
    }

    init(presetIndex: Int, presetName: String, dictionary: [String: Double]) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic   = dictionary
    }

    init(presetIndex: Int, presetName: String, parameters: [AUParameter]?) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic =
            parameters?.reduce(into: [String: Double]() ) { dic, par in
                dic[par.identifier] = Double(par.value)
            } ?? [:]
    }

    init(with fullState: [String: Any]?) {
        self.fullState = fullState
    }

    public func presetValue(for id: String) -> AUValue? {
        return presetDic[id].map { AUValue($0) }
    }
}

extension AUAudioUnitPreset {
    convenience init?(with preset: MinimoogAUPreset?) {
        guard let preset = preset else { return nil }
        self.init()
        self.name   = preset.presetName
        self.number = preset.presetIndex
    }
}
