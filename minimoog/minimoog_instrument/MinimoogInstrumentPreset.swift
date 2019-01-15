//
//  MinimoogInstrumentPreset.h
//  minimoog
//
//  Created by Yauheni Lychkouski on 10/28/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

class MinimoogInstrumentPreset {
    public var presetName  = ""
    public var presetIndex = 0
    public var presetDic   = [String:Double]()
    
    public var fullState: [String:Any]? {
        get {
            return ["Name": presetName, "Index": presetIndex, "presetDic": presetDic]
        }
        
        set {
            guard
                let state       = newValue,
                let presetName  = state["Name"] as? String,
                let presetIndex = state["Index"] as? Int,
                let presetDic   = state["presetDic"] as? [String:Double]
            else {
                print("Failed to init preset from the full state")
                return
            }
            
            self.presetName  = presetName
            self.presetIndex = presetIndex
            self.presetDic   = presetDic
        }
    }
    
    init(presetIndex:Int, presetName:String, dictionary:[String:Double]) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic   = dictionary
    }
    
    init(presetIndex:Int, presetName:String, parameters:[AUParameter]?) {
        self.presetName  = presetName
        self.presetIndex = presetIndex
        self.presetDic =
            parameters?.reduce(into: [String:Double]() ) { dic, par in
                dic[par.identifier] = Double(par.value)
            } ?? [:]
    }
    
    init(with fullState:[String:Any]?) {
        self.fullState = fullState
    }
    
    public func presetValue(for id: String) -> AUValue? {
        return presetDic[id].map { AUValue($0) }
    }
}


extension AUAudioUnitPreset {
    convenience init?(with preset:MinimoogInstrumentPreset?) {
        guard let pr = preset else { return nil }
        self.init()
        self.name   = pr.presetName
        self.number = pr.presetIndex
    }
}
