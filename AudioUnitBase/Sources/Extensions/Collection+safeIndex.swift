//
//  Collection+safeIndex.swift
//  AudioUnitBase
//
// Got frmo https://stackoverflow.com/a/48103917
// Copyright © 2020 SafeFastExpressive
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[ index] : nil
    }
}

extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get { return indices.contains(index) ? self[index] : nil }
        set {
            guard let newValue = newValue, indices.contains(index) else { return }
            self[index] = newValue
        }
    }
}
