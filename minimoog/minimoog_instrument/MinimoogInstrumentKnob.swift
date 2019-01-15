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
            return (stepSize != 0) ? getSnappedValue() : curValue
        }
        set {
            if isValueLockedByUI == false {
                setValue(newValue, animated:true)
            }
        }
    }
    
    // MARK: Private variables
    private var isViewLoaded         : Bool = false
    private var curValue             : Float = 0
    private var curAngle             : Float = 0
    private var isValueLockedByUI    : Bool = false
    private var panGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var prevOffset           : Float = 0
    
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
        let prevAngle = curAngle
        curValue        = min(maxValue, max(minValue, newValue))
        curAngle     = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
        rotateKnob(from:prevAngle, to:curAngle, animated:animated)
    }
    
    private func commonInit() {
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if isViewLoaded == false {
            isViewLoaded = true
            curValue     = initValue
            curAngle     = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
            rotateKnob(from: 0, to: curAngle, animated: false)
        }
    }
    
    private func getSnappedValue() -> Float {
        let snappedVal = minValue + roundf((curValue-minValue)/stepSize)*stepSize
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
            isValueLockedByUI    = true
            prevOffset           = 0
        case .changed:
            isValueLockedByUI    = true
            let curOffset        = -Float(recognizer.translation(in: self).y)
            let delta            = curOffset - prevOffset
            prevOffset           = curOffset
            
            // 128 is number or the total parameter steps. It is multiplied by 2 to achieve
            // sufficient tolerance and smoothness with touches
            let newValue         = curValue + (maxValue-minValue)*delta/(128*2)
            setValue(newValue, animated:false)
            sendActions(for: .valueChanged)
        default:
            isValueLockedByUI    = false
            prevOffset           = 0
        }
    }
}

