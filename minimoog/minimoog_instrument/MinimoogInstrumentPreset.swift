//
//  MinimoogInstrumentPreset.h
//  minimoog
//
//  Created by Yauheni Lychkouski on 10/28/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

class MinimoogInstrumentPreset {
    public var presetName: String = ""
    public var presetIndex: Int = 0
    public var presetDic:[String:Double] = [:]
    
    
    init(presetIndex:Int, presetName:String, dictionary:[String:Double]) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic   = dictionary
    }
    
    init(presetIndex:Int, presetName:String, parameters:[AUParameter]?) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic   = [:]
        
        guard parameters != nil else { return }
        
        for param in parameters! {
            self.presetDic[param.identifier] = Double(param.value)
        }
    }
    
    init(fromFullState fullState:[String:Any]?) {
        guard fullState != nil else { return }
        
        presetName  = fullState!["Name"] as! String
        presetIndex = fullState!["Index"] as! Int
        presetDic   = fullState!["presetDic"] as! [String:Double]
    }
    
    public func getAuPreset() -> AUAudioUnitPreset {
        let result    = AUAudioUnitPreset()
        result.name   = self.presetName
        result.number = self.presetIndex
        return result
    }
    
    public func fillParametersFromPreset(_ parameters:[AUParameter]?) {
        guard parameters != nil else { return }
        
        for param in parameters! {
            if let presetVal = self.presetDic[param.identifier] {
                param.value = AUValue(presetVal)
            }
        }
    }
    
    public func getFullState() -> [String:Any]? {
        var result: [String:Any] = [:]
        result["Name"]      = presetName
        result["Index"]     = presetIndex
        result["presetDic"] = presetDic
        return result as [String:Any]?
    }
}
