//
//  AudioUnitModule+connectionOperators.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 4/10/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

precedencegroup ModuleConnectionPrecedence {
    associativity: left
}

infix operator ==>: ModuleConnectionPrecedence
@discardableResult public func ==> (module1: AudioUnitModule, module2: AudioUnitModule) -> AudioUnitModule {
    module2.connectAudioInput(to: module1)
    return module2
}

infix operator -->: ModuleConnectionPrecedence
@discardableResult public func --> (module1: AudioUnitModule, module2: AudioUnitModule) -> AudioUnitModule {
    module2.connectCvInput(to: module1)
    return module2
}
