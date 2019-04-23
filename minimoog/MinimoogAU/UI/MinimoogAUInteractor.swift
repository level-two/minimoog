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
    init() {
        
        guard audioUnit != nil else { return }
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
        connectViewWithAU()
        
        // Assign default values to all controls
        MinimoogAU.ParamAddr.allCases.forEach { [weak self] addr in
            guard let parameter = self?.audioUnit?.parameterTree?.parameter(withAddress: addr.rawValue) else { return }
            self?.updateUiControl(withAddress: addr, value: parameter.value)
        }
    }
    
    // MARK: Public variables
    public var audioUnit: AUAudioUnit? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.isViewLoaded else { return }
                
                self.connectViewWithAU()
                
                // Assign default values to all controls
                MinimoogAU.ParamAddr.allCases.forEach { [weak self] addr in
                    guard let parameter = self?.audioUnit?.parameterTree?.parameter(withAddress: addr.rawValue) else { return }
                    self?.updateUiControl(withAddress: addr, value: parameter.value)
                }
            }
        }
    }


    // MARK: AUAudioUnitFactory protocol implementation
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try MinimoogAU(componentDescription: componentDescription, options: [])
        return audioUnit!
    }

    func connectViewWithAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }
        parameterObserverToken = paramTree.token(byAddingParameterObserver: { [weak self] _, value in
            guard let addr = MinimoogAU.ParamAddr(rawValue:UInt64(value)) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateUiControl(withAddress:addr, value:value)
            }
        })
    }

    func setParameterValue(withAddress address:MinimoogAU.ParamAddr, value:AUValue) {
        guard let parameter = audioUnit?.parameterTree?.parameter(withAddress:address.rawValue) else { return }
        parameter.setValue(value, originator: parameterObserverToken)
    }

    
    fileprivate var parameterObserverToken  : AUParameterObserverToken?
}
