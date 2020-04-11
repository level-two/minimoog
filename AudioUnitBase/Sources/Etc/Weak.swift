//
//  Weak.swift
//  AudioUnitBase
//
//  Created by Yauheni Lychkouski on 4/10/20.
//  Copyright © 2020 Yauheni Lychkouski. All rights reserved.
//

import Foundation

class Weak<T: AnyObject> {
    private(set) weak var pointee: T?

    init(_ pointee: T?) {
        self.pointee = pointee
    }
}
