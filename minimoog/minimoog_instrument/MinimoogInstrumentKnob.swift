//
//  MinimoogInstrumentKnob.swift
//  minimoog_instrument
//
//  Created by Yauheni Lychkouski on 10/6/18.
//  Copyright © 2018 Yauheni Lychkouski. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public class MinimoogInstrumentKnob: UIControl {

    // MARK: Outlets
    @IBOutlet weak var knobImageView: UIImageView!
    
    // MARK: Public variables
    @IBInspectable var minValue : Float = 0
    @IBInspectable var maxValue : Float = 1
    @IBInspectable var stepSize : Float = 0
    @IBInspectable var initValue: Float = 0.5
    @IBInspectable var minAngle : Float = -270
    @IBInspectable var maxAngle : Float =  270
    
    var value : Float {
        get {
            return (stepSize != 0) ? getSnappedValue() : _value
        }
        set {
            if _isValueLockedByUI == false {
                setValue(newValue, animated:true)
            }
        }
    }
    
    // MARK: Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Public functions
    public func setValue(_ newValue: Float, animated: Bool = false) {
        let prevAngle = _curAngle
        _value        = min(maxValue, max(minValue, newValue))
        _curAngle     = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
        rotateKnob(from:prevAngle, to:_curAngle, animated:animated)
    }
    
    // MARK: Private variables
    private var _isViewLoaded         : Bool = false
    private var _value                : Float = 0
    private var _curAngle             : Float = 0
    private var _isValueLockedByUI    : Bool = false
    private var _panGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var _prevOffset           : Float = 0
    
    private func commonInit() {
        _panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(_panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if _isViewLoaded == false {
            _isViewLoaded = true
            _value        = initValue
            _curAngle     = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
            rotateKnob(from: 0, to: _curAngle, animated: false)
        }
    }
    
    private func getSnappedValue() -> Float {
        let snappedVal = minValue + roundf((_value-minValue)/stepSize)*stepSize
        return min(maxValue, max(minValue, snappedVal))
    }
    
    private func rotateKnob(from curAngleDeg:Float, to newAngleDeg:Float, animated:Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let curAngleRad = curAngleDeg*Float.pi/180
        let newAngleRad = newAngleDeg*Float.pi/180
        knobImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat(newAngleRad))
        if (animated) {
            let midAngleRad           = (newAngleRad + curAngleRad) / 2
            let animation             = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values          = [curAngleRad, midAngleRad, newAngleRad]
            animation.keyTimes        = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
            knobImageView.layer.add(animation, forKey: "transform.rotation.z")
        }
        CATransaction.commit()
    }
    
    // MARK: UIPanGestureRecognizer delegate
    @objc private func handlePan(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            _isValueLockedByUI    = true
            _prevOffset           = 0
        case .changed:
            _isValueLockedByUI    = true
            let curOffset         = -Float(recognizer.translation(in: self).y)
            let delta             = curOffset - _prevOffset
            _prevOffset           = curOffset
            // 128 is number or the total parameter steps. It is multiplied by 2 to achieve
            // sufficient tolerance and smoothness with touches
            let newValue          = _value + (maxValue-minValue)*delta/(128*2)
            setValue(newValue, animated:false)
            sendActions(for: .valueChanged)
        default:
            _isValueLockedByUI    = false
            _prevOffset           = 0
        }
    }
}

