//
//  MinimoogAUInteractions.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 2/2/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation
import CoreAudioKit

class MinimoogAUInteractor {
    public var audioUnit: AUAudioUnit? { didSet { self.connectViewWithAU() }}
    
    
    
    // MARK: AUAudioUnitFactory protocol implementation
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try MinimoogAU(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    
    
    

    func connectViewWithAU() {
        guard let parameterTree = audioUnit?.parameterTree else { return }
        
        MinimoogAU.ParameterId.allCases.forEach { parameterId in
            guard let parameter = parameterTree.parameter(withAddress: parameterId.rawValue) else { return }
            self.setParameterValue(for: parameterId, value: parameter.value)
        }
        
        parameterObserverToken = parameterTree.token(byAddingParameterObserver: { [weak self] _, value in
            guard let parameterId = MinimoogAU.ParameterId(rawValue: UInt64(value)) else { return }
            DispatchQueue.main.async {
                self?.setParameterValue(for: parameterId, value: value)
            }
        })
    }

    func setParameterValue(for parameterId: MinimoogAU.ParameterId, value: AUValue) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress: parameterId.rawValue) else { return }
        parameter.setValue(value, originator: parameterObserverToken)
    }

    fileprivate var parameterObserverToken: AUParameterObserverToken?
}
