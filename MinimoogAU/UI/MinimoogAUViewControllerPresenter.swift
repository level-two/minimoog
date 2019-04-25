//
//  MinimoogAUViewControllerPresenter.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 4/25/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation

extension MinimoogAUViewController {
    func setKnobValue(withAddress paramId: ParameterId, value: AUValue) {
        knobs[paramId]!.value = value
    }
}
