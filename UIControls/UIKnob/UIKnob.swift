// -----------------------------------------------------------------------------
//    Copyright (C) 2019 Yauheni Lychkouski.
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
public final class UIKnob: UIControl, NibLoadable {
    @IBInspectable public var parameterId: Int = 0
    @IBInspectable public var title: String = ""
    @IBInspectable public var minValue: CGFloat = 0
    @IBInspectable public var maxValue: CGFloat = 1
    @IBInspectable public var step: CGFloat = 0

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var minLabel: UILabel?
    @IBOutlet var midLabel: UILabel?
    @IBOutlet var maxLabel: UILabel?
    @IBOutlet var pointer: UIView?
    
    public var value: CGFloat {
        get {
            return curValue.snapped(to: step, in: minValue...maxValue)
        }
        set {
            guard !isValueLockedByUI else { return }
            setValue(newValue, animated: true)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    override public func awakeFromNib() {
        commonInit()
    }

    override public func prepareForInterfaceBuilder() {
        commonInit()
    }

    fileprivate func commonInit() {
        titleLabel?.text = title
        minLabel?.text = "\(minValue)"
        midLabel?.text = "\((minValue + maxValue)/2)"
        maxLabel?.text = "\(maxValue)"

        setValue(minValue)

        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }

    fileprivate let minAngle: CGFloat = -150 * CGFloat.pi/180
    fileprivate let maxAngle: CGFloat = 150 * CGFloat.pi/180

    fileprivate var isValueLockedByUI: Bool {
        return panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed
    }

    fileprivate var curValue: CGFloat = 0
    fileprivate var curAngle: CGFloat = 0
    fileprivate var lastTouchOffset: CGFloat = 0
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
}

extension UIKnob {
    @objc public func handlePan(recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .changed else {
            lastTouchOffset = 0
            return
        }

        let touchOffset = -CGFloat(recognizer.translation(in: self).y)
        let delta = touchOffset - lastTouchOffset
        lastTouchOffset = touchOffset

        let newValue = curValue + (maxValue-minValue)*delta/128 // 128 is number or the total parameter steps
        setValue(newValue.clamped(in: minValue...maxValue))

        sendActions(for: .valueChanged)
    }
}

extension UIKnob {
    func setValue(_ newValue: CGFloat, animated: Bool = false) {
        curValue = newValue

        let prevAngle = curAngle
        curAngle = minAngle + (curValue-minValue)*(maxAngle-minAngle)/(maxValue-minValue)

        UIView.animate(withDuration: animated ? 1 : 0) {
            guard let pointer = self.pointer else { return }
            pointer.transform = pointer.transform.rotated(by: self.curAngle - prevAngle)
        }
    }
}

extension CGFloat {
    func snapped(to step: CGFloat, in range: ClosedRange<CGFloat>) -> CGFloat {
        guard step != 0 else { return self }

        let min = range.lowerBound
        let val = min + ((self-min)/step).rounded() * step

        return val.clamped(in: range)
    }

    func clamped(in range: ClosedRange<CGFloat>) -> CGFloat {
        return
            self > range.upperBound ? range.upperBound :
            self < range.lowerBound ? range.lowerBound : self
    }
}
