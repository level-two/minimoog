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

class FactoryPresetsManager {
    var defaultPresetIndex: Int = 0
    private var presets = [Preset]()

    init() {
        // FIXME: Pass presets through instrument protocol
        if let presetsDef = factoryPresets(from: "FactoryPresets.plist") {
            defaultPresetIndex = presetsDef.defaultPresetIndex
            presets = presetsDef.presets.map { Preset(index: $0.index, name: $0.name, dictionary: $0.parameters) }
        }
    }

    func getPreset(withIndex index: Int) -> Preset? {
        return presets.first { $0.index == index }
    }

    func defaultPreset() -> Preset? {
        return getPreset(withIndex: self.defaultPresetIndex)
    }

    func allPresets() -> [Preset] {
        return presets.sorted(by: {$0.index < $1.index})
    }
}

fileprivate extension FactoryPresetsManager {
    func factoryPresets(from plistFile: String) -> FactoryPresets? {
        guard let url = Bundle.main.url(forResource: plistFile, withExtension: nil),
            let data = try? Data(contentsOf: url),
            let presets = try? PropertyListDecoder().decode(FactoryPresets.self, from: data)
            else { return nil }

        return presets
    }
}
