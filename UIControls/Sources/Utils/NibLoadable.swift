// -----------------------------------------------------------------------------
//    Copyright (C) 2020 Yauheni Lychkouski.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

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
