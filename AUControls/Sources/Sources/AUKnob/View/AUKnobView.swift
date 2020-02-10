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

@IBDesignable
final class AUKnobView: UIView {
    @IBOutlet var top: UIImageView?
    @IBOutlet var bottom: UIImageView?

    private var curAngle: CGFloat = 0

    func set(topImage: UIImage?) {
        top?.image = topImage
    }

    func set(bottomImage: UIImage?) {
        bottom?.image = bottomImage
    }

    func rotate(to angle: CGFloat, animated: Bool) {
        let deltaAngle = angle - curAngle
        curAngle = angle
        UIView.animate(withDuration: animated ? 1 : 0) {
            guard let top = self.top else { return }
            top.transform = top.transform.rotated(by: deltaAngle * .pi / 180)
        }
    }
}
