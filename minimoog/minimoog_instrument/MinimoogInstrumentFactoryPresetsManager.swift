//
//  MinimoogInstrumentFactoryPresetsManager.swift
//  minimoog
//
//  Created by Yauheni Lychkouski on 10/28/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

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
    
    public var defaultPresetIndex: Int
    private var presets: [MinimoogInstrumentPreset]
    
    init() {
        presets = []
        defaultPresetIndex = 0
        
        guard let presetsDef = loadPresetsDefFromFile() else { return }
        
        for presetDef in presetsDef.presets {
            let preset = MinimoogInstrumentPreset(presetIndex: presetDef.presetIndex,
                                                  presetName: presetDef.presetName,
                                                  dictionary: presetDef.params)
            presets.append(preset)
        }
        
        defaultPresetIndex = presetsDef.defaultPresetIndex
    }
    
    public func getPreset(withIndex index:Int) -> MinimoogInstrumentPreset? {
        for preset in presets {
            if preset.presetIndex == index {
                return preset
            }
        }
        return nil
    }
    
    public func defaultAuPreset() -> AUAudioUnitPreset? {
        let preset = getPreset(withIndex: self.defaultPresetIndex)
        return preset?.getAuPreset()
    }
    
    public func getAuPresets() -> [AUAudioUnitPreset] {
        var auPresets:[AUAudioUnitPreset] = []
        for preset in self.presets {
            auPresets.append(preset.getAuPreset())
        }
        return auPresets.sorted(by: {$0.number < $1.number})
    }
    
    private func loadPresetsDefFromFile() -> PresetsDef? {
        guard let url  = Bundle.main.url(forResource: "FactoryPresets", withExtension: "plist") else { return nil }
        
        var presetsDef : PresetsDef?
        let decoder = PropertyListDecoder()
        
        do {
            let data = try Data(contentsOf: url)
            presetsDef = try decoder.decode(PresetsDef.self, from: data)
        }
        catch {
            print(error)
        }
        
        return presetsDef
    }
}
