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
import AudioToolbox

@IBDesignable
public final class AUKnob: UIView, NibLoadable {
    @IBInspectable private var address: Int = 0
    @IBInspectable private var topImage: UIImage? { didSet { knobView?.set(topImage: topImage) } }
    @IBInspectable private var bottomImage: UIImage? { didSet { knobView?.set(bottomImage: bottomImage) } }
    @IBInspectable private var minAngle: CGFloat = -150
    @IBInspectable private var maxAngle: CGFloat = 150

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func set(viewModel: AUKnobViewModel) {
        self.viewModel?.set(delegate: nil)
        self.viewModel = viewModel
        self.viewModel?.set(delegate: self)
        updateView(with: viewModel.controlValue, animated: false)
    }

    private var viewModel: AUKnobViewModel?
    private var knobView: AUKnobView?
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var lastTouchPosition: CGFloat = 0
}

extension AUKnob: AUKnobViewModelDelegate {
    func update() {
        guard let value = viewModel?.controlValue else { return }
        updateView(with: value, animated: true)
    }
}

fileprivate extension AUKnob {
    func commonInit() {
        knobView = loadFromNib()
    }

    func setupView() {
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            viewModel?.userInteractionStarted()
        case .changed:
            let touchPosition = -recognizer.translation(in: self).y
            let offset = touchPosition - lastTouchPosition
            viewModel?.userChangedControl(by: Double(offset/128)) // 128 is number or the total parameter steps
            lastTouchPosition = touchPosition
        default:
            viewModel?.userInteractionEnded()
            lastTouchPosition = 0
        }
    }

    func updateView(with value: Double, animated: Bool) {
        let angle = minAngle + CGFloat(value) * (maxAngle - minAngle)
        knobView?.rotate(to: angle, animated: animated)
    }
}
