//
//  MinimoogInstrumentKnob.swift
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class MinimoogInstrumentKnob: UIControl, UIPanGestureRecognizer {

    // MARK: Outlets
    @IBOutlet weak var knobImageView: UIImageView!
    
    // MARK: Public variables
    var minValue : Float = 0
    var maxValue : Float = 1
    var initValue: Float = 0.5
    var value    : Float = 0 {
        get { return _value }
        set { setValue(newValue, animated:true) }
    }
    //var isContinuous = true
    var minAngle : Float = -3*Double.pi/4
    var maxAngle : Float =  3*Double.pi/4

    // MARK: Public functions
    func setValue(_ newValue: Float, animated: Bool = false) {
        var prevAngle = _curAngle
        _value        = min(maxValue, max(minalue, newValue))
        _curAngle     = _value*(maxAngle-minAngle)/(maxValue-minValue)
        rotateKnob(from:prevAngle to:_curAngle animated:animated)
    }

    // MARK: Private variables
    private var _value   : Float = 0
    private var _curAngle: Float = 0
    
    // MARK: Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .blue
        // TODO:load image
        setValue(initValue, animated:false)
    }
    
    private func rotateKnob(from curAngle:Float, to newAngle:Float, animated:Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        knobImageView.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1)

        if (animated) {
            let midAngle              = (newAngle + curAngle) / 2
            let animation             = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values          = [curAngle, midAngle, newAngle]
            animation.keyTimes        = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            knobImageView.layer.add(animation, forKey: "transform.rotation.z")
        }

        CATransaction.commit()
    }

    // MARK: UIPanGestureRecognizer implementation
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard 
            let touch = touches.first,
            let view  = view
        else {
            return
        }
        _lastTouchPoint = touch.location(in: view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard 
            let touch = touches.first,
            let view  = view
        else {
            return
        }
        let touchPoint  = touch.location(in: view)
        // y axis grows down, so delta should be defined as yLast-yNew
        let delta       = _lastTouchPoint.y - touchPoint.y
        let newValue    = self.value + delta*(maxValue-minValue)/(view.bounds.height*2)
        setValue(newValue, animated:false)
        _lastTouchPoint = touchPoint
    }
}

