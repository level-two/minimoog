//
//  NibLoadable.swift
//  UIControls
//
//  Created by Yauheni Lychkouski on 9/23/19.
//  Copyright © 2019 Yauheni Lychkouski. All rights reserved.
//

import UIKit

protocol NibLoadable where Self: UIView {
    func loadFromNib()
}

extension NibLoadable {
    func loadFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))

        guard let views = bundle.loadNibNamed(nibName, owner: self, options: nil) else {
            fatalError("Failed to load nib \(nibName) from bundle \(String(describing: bundle))")
        }

        guard let view = views.first as? UIView else {
            fatalError("Failed to get view from nib \(nibName) in the bundle \(String(describing: bundle))")
        }

        view.frame = self.bounds
        self.addSubview(view)
    }
}
