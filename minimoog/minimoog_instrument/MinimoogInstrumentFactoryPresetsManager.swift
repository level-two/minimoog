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

class MinimoogInstrumentFactoryPresetsManager {
    struct PresetsDef : Decodable {
        struct PresetDef : Decodable {
            var presetName: String
            var presetIndex: Int
            var params: [String:Double]
        }
        
        var presets: [PresetDef]
        var defaultPresetIndex: Int
    }
    
    public var defaultPresetIndex: Int = 0
    private var presets = [MinimoogInstrumentPreset]()
    
    init() {
        guard let presetsDef = loadPresetsDefFromFile() else { return }
        defaultPresetIndex = presetsDef.defaultPresetIndex
        presets = presetsDef.presets.map {
            MinimoogInstrumentPreset(presetIndex:$0.presetIndex, presetName:$0.presetName, dictionary:$0.params)
        }
    }
    
    public func getPreset(withIndex index:Int) -> MinimoogInstrumentPreset? {
        return presets.first { $0.presetIndex == index }
    }
    
    public func defaultPreset() -> MinimoogInstrumentPreset? {
        return getPreset(withIndex: self.defaultPresetIndex)
    }
    
    public func allPresets() -> [MinimoogInstrumentPreset] {
        return presets.sorted(by: {$0.presetIndex < $1.presetIndex})
    }
    
    private func loadPresetsDefFromFile() -> PresetsDef? {
        guard
            let url = Bundle.main.url(forResource: "FactoryPresets", withExtension: "plist"),
            let data = try? Data(contentsOf: url)
        else { return nil }
        
        return try? PropertyListDecoder().decode(PresetsDef.self, from: data)
    }
}
