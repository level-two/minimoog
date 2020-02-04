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
    @IBInspectable public var address: Int = 0
    @IBInspectable private var topImage: UIImage? { didSet { knobView?.set(topImage: topImage) } }
    @IBInspectable private var bottomImage: UIImage? { didSet { knobView?.set(bottomImage: bottomImage) } }
    @IBInspectable private var steps: UInt = 0
    @IBInspectable private var minAngle: CGFloat = -150
    @IBInspectable private var maxAngle: CGFloat = 150
    
    public var value: CGFloat {
        get {
            switch steps {
            case 0: return curValue
            case 1: return 0.5
            default: return (curValue * CGFloat(steps-1)).rounded() / CGFloat(steps-1)
            }
        }
        set {
            guard !isValueLockedByUI else { return }
            setValue(newValue, animated: true)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        knobView = loadFromNib(owner: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        knobView = loadFromNib(owner: self)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private var knobView: UIKnobView?
    private var curValue: CGFloat = 0
    private var curAngle: CGFloat = 0
    private var lastTouchOffset: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var isValueLockedByUI: Bool {
        return panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed
    }
}

fileprivate extension UIKnob {
    func commonInit() {
        setValue(0)

        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .changed else {
            lastTouchOffset = 0
            return
        }

        let touchOffset = -CGFloat(recognizer.translation(in: self).y)
        let delta = touchOffset - lastTouchOffset
        lastTouchOffset = touchOffset

        let newValue = curValue + delta/128 // 128 is number or the total parameter steps
        setValue(newValue.clamped(in: 0...1))

        sendActions(for: .valueChanged)
    }

    func setValue(_ newValue: CGFloat, animated: Bool = false) {
        curValue = newValue

        let prevAngle = curAngle
        curAngle = minAngle + value * (maxAngle - minAngle)
        knobView?.rotate(by: curAngle - prevAngle, animated: animated)
    }
}
