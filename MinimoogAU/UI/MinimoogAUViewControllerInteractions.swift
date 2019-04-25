//
//  MinimoogAUViewControllerInteractions.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 4/25/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation

extension MinimoogAUViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        assembleView()
        setupLayout()
        bindEvents()
    }

    func assembleViewInteractions() {
        self.knobs.forEach { pair in
            let (paramId, knob) = pair
            knob.onValue.map { (paramId, $0) }.bind(to: onKnob).disposed(by: disposeBag)
        }
    }
    
    func connectViewWithAU() {
        guard let parameterTree = audioUnit?.parameterTree else { return }
        
        ParameterId.allCases.forEach { parameterId in
            guard let parameter = parameterTree.parameter(withAddress: parameterId.rawValue) else { return }
            self.setParameterValue(for: parameterId, value: parameter.value)
        }
        
        // TODO: Use RX
        parameterObserverToken = parameterTree.token(byAddingParameterObserver: { [weak self] _, value in
            guard let parameterId = ParameterId(rawValue: UInt64(value)) else { return }
            DispatchQueue.main.async {
                self?.setParameterValue(for: parameterId, value: value)
            }
        })
    }

    func setParameterValue(for parameterId: ParameterId, value: AUValue) {
        guard let parameter = audioUnit?.parameterTree.parameter(withAddress: parameterId.rawValue) else { return }
        parameter.setValue(value, originator: parameterObserverToken)
    }

}
