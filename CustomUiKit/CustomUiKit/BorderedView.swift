//
//  UIViewCustomizable.swift
//  CustomUiKit
//
//  Created by Yauheni Lychkouski on 1/25/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class BorderedView: UIView {
    @IBInspectable public var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable public var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get { return layer.cornerRadius }
    }
}
