//
//  AUParameter+make.swift
//  MinimoogAU
//
//  Created by Yauheni Lychkouski on 12/27/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import AudioToolbox

extension AUParameter {
    static func make(_ identifier: String, _ parameterDef: ParameterDef) -> AUParameter {
        return AUParameterTree.createParameter(
            withIdentifier: identifier,
            name: parameterDef.name,
            address: parameterDef.address,
            min: AUValue(parameterDef.minValue),
            max: AUValue(parameterDef.maxValue),
            unit: parameterDef.unit ?? .customUnit,
            unitName: nil,
            flags: [.flag_IsWritable, .flag_IsReadable],
            valueStrings: parameterDef.valueStrings,
            dependentParameters: nil
        )
    }
}
