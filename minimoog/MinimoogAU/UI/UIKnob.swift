// -----------------------------------------------------------------------------
//    Copyright (C) 2018 Yauheni Lychkouski.
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
import Foundation
import RxSwift

@IBDesignable
class UIKnob: UIControl {
    // MARK: Public variables
    @IBInspectable public var minValue : Float = 0
    @IBInspectable public var maxValue : Float = 1
    @IBInspectable public var stepSize : Float = 0
    @IBInspectable public var initValue: Float = 0.5
    @IBInspectable public var minAngle : Float = -270
    @IBInspectable public var maxAngle : Float =  270
    
    
    public let onValue = PublishSubject<Float>()
    
    public var value : Float {
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
    var knobPointerLayer     : CALayer!
    var isViewLoaded         : Bool = false
    var curValue             : Float = 0
    var curAngle             : Float = 0
    var isValueLockedByUI    : Bool = false
    var panGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer()
    var prevOffset           : Float = 0
    
    // MARK: Overrides
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //setup your view with the settings
    }
    
    // MARK: Public functions
    public func setValue(_ newValue: Float, animated: Bool = false) {
        let prevAngle = curAngle
        curValue      = min(maxValue, max(minValue, newValue))
        curAngle      = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
        rotateKnob(from:prevAngle, to:curAngle, animated:animated)
        
        onValue.onNext(newValue)
    }
    
    func commonInit() {
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        #if !TARGET_INTERFACE_BUILDER
        if self.knobPointerLayer == nil {
            makeKnob(frame: self.bounds)
        }
        #else
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        makeKnob(frame: self.bounds)
        #endif
        
        if isViewLoaded == false {
            isViewLoaded = true
            curValue     = initValue
            curAngle     = minAngle + (value-minValue)*(maxAngle-minAngle)/(maxValue-minValue)
            rotateKnob(from: 0, to: curAngle, animated: false)
        }
    }
    
    func getSnappedValue() -> Float {
        let snappedVal = minValue + roundf((curValue-minValue)/stepSize)*stepSize
        return min(maxValue, max(minValue, snappedVal))
    }
    
    func rotateKnob(from curAngleDeg:Float, to newAngleDeg:Float, animated:Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let curAngleRad = curAngleDeg*Float.pi/180
        let newAngleRad = newAngleDeg*Float.pi/180
        knobPointerLayer.transform = CATransform3DMakeRotation(CGFloat(newAngleRad), 0, 0, 1)
        if (animated) {
            let midAngleRad           = (newAngleRad + curAngleRad) / 2
            let animation             = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            
            animation.values          = [curAngleRad, midAngleRad, newAngleRad]
            animation.keyTimes        = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
            knobPointerLayer.add(animation, forKey: "transform.rotation.z")
        }
        CATransaction.commit()
    }
    
    // MARK: UIPanGestureRecognizer delegate
    @objc public func handlePan(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isValueLockedByUI    = true
            prevOffset           = 0
        case .changed:
            isValueLockedByUI    = true
            let curOffset        = -Float(recognizer.translation(in: self).y)
            let delta            = curOffset - prevOffset
            prevOffset           = curOffset
            
            // 128 is number or the total parameter steps
            let newValue         = curValue + (maxValue-minValue)*delta/128
            setValue(newValue, animated:false)
            sendActions(for: .valueChanged)
        default:
            isValueLockedByUI    = false
            prevOffset           = 0
        }
    }
}


extension UIKnob {
    func makeKnob(frame: CGRect) {
        let minSize      = min(frame.width, frame.height)
        let size         = CGSize(width: minSize, height: minSize)
        let drawingFrame = CGRect(origin: CGPoint(x: frame.midX-minSize/2, y: frame.midY-minSize/2), size: size)
        
        let knobLayer    = CALayer()
        knobLayer.frame  = drawingFrame
        knobLayer.addSublayer(shadowLayer(size: size))
        knobLayer.addSublayer(metallLayer(size: size))
        knobLayer.addSublayer(lightLayer(size: size))
        knobLayer.addSublayer(knobOuterLayer(size: size))
        self.layer.addSublayer(knobLayer)
        
        self.knobPointerLayer = pointerLayer(size: size)
        self.knobPointerLayer.frame = drawingFrame
        self.layer.addSublayer(self.knobPointerLayer)
    }
    
    func shadowLayer(size: CGSize) -> CALayer {
        let frame           = CGRect(origin: .zero, size: size)
        
        let path = CGMutablePath()
        path.addEllipse(in: frame.offsetBy(dx: 2, dy: 4))
        
        let layer           = CAShapeLayer()
        layer.path          = path
        layer.frame         = frame
        layer.fillColor     = UIColor.gray.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1
        layer.shadowRadius  = 4
        layer.shadowColor   = UIColor.black.cgColor
        return layer
    }
    
    func knobOuterLayer(size: CGSize) -> CALayer {
        let frame          = CGRect(origin: .zero, size: size)
        let outerSize      = frame.width / 32
        
        let maskPath       = CGMutablePath()
        maskPath.addEllipse(in: frame)
        maskPath.addEllipse(in: frame.insetBy(dx: outerSize, dy: outerSize))
        
        let maskLayer      = CAShapeLayer()
        maskLayer.path     = maskPath
        maskLayer.fillRule = .evenOdd
        
        let layer          = CAGradientLayer()
        layer.mask         = maskLayer
        layer.colors       = [UIColor.white, .gray, .white, .darkGray].map { $0.cgColor }
        layer.endPoint     = CGPoint(x: -0.2, y: 1)
        layer.frame        = frame
        return layer
    }
    
    func lightLayer(size: CGSize) -> CALayer {
        let frame               = CGRect(origin: .zero, size: size)
        let sectorsNum          = 128
        let lightsNum           = 2
        let initAlpha: CGFloat  = 0.8
        
        let sectorColor = UIColor(red: initAlpha, green: initAlpha, blue: initAlpha, alpha: initAlpha).cgColor
        
        // Create single sector
        let sector = CAShapeLayer()
        
        //sector.strokeColor = sectorColor
        sector.fillColor = sectorColor
        let sectorPath  = CGMutablePath()
        sectorPath.move(to: .zero)
        
        let radius = frame.height / 2.0
        sectorPath.addLine(to: CGPoint(x: 0, y: radius))
        sectorPath.addArc(tangent1End: CGPoint(x: radius*sin(CGFloat.pi*2.0/CGFloat(sectorsNum))/2,
                                               y: radius),
                          tangent2End: CGPoint(x: radius*sin(CGFloat.pi*2.0/CGFloat(sectorsNum)),
                                               y: radius*cos(CGFloat.pi*2.0/CGFloat(sectorsNum))),
                          radius: radius)
        
        sectorPath.addLine(to: .zero)
        sector.path        = sectorPath
        sector.frame       = frame
        sector.anchorPoint = .zero
        sector.transform   = CATransform3DMakeRotation(CGFloat.pi/2, 0, 0, 1)
        
        // Replicate sectors with light modulation
        let sectorsInGroup               = sectorsNum/(2*lightsNum)
        let colorOffset                  = -Float(initAlpha)/Float(sectorsInGroup)
        
        let sectorsGroup                 = CAReplicatorLayer()
        sectorsGroup.frame               = frame
        sectorsGroup.instanceCount       = sectorsInGroup
        sectorsGroup.instanceTransform   = CATransform3DMakeRotation(-CGFloat.pi*2/CGFloat(sectorsNum), 0, 0, 1)
        sectorsGroup.instanceAlphaOffset = colorOffset
        sectorsGroup.instanceRedOffset   = colorOffset
        sectorsGroup.instanceGreenOffset = colorOffset
        sectorsGroup.instanceBlueOffset  = colorOffset
        sectorsGroup.addSublayer(sector)
        
        let sectorsGroup1                = CAReplicatorLayer()
        sectorsGroup1.frame              = frame
        sectorsGroup1.instanceCount      = 2
        sectorsGroup1.instanceTransform  = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        sectorsGroup1.addSublayer(sectorsGroup)
        
        let replicator                   = CAReplicatorLayer()
        replicator.frame                 = frame
        replicator.instanceCount         = Int(lightsNum)
        replicator.instanceTransform     = CATransform3DMakeRotation(CGFloat.pi*2/CGFloat(lightsNum), 0, 0, 1)
        replicator.addSublayer(sectorsGroup1)
        
        return replicator
    }
    
    func metallLayer(size: CGSize) -> CALayer {
        let frame             = CGRect(origin: .zero, size: size)
        let circlesNum        = 6
        let c0: CGFloat       = 0.7
        let c1                = c0 + 0.007
        let layer             = CAShapeLayer()
        layer.fillColor       = UIColor(red: c0, green: c0, blue: c0, alpha: 1).cgColor
        layer.backgroundColor = UIColor(red: c1, green: c1, blue: c1, alpha: 1).cgColor
        layer.frame           = frame
        layer.fillRule        = .evenOdd
        
        let path = CGMutablePath()
        for i in 0..<circlesNum {
            let ellipseW = frame.width*CGFloat(i)/CGFloat(circlesNum)
            let ellipseH = frame.height*CGFloat(i)/CGFloat(circlesNum)
            path.addEllipse(in:
                CGRect(x: frame.midX - ellipseW/2,
                       y: frame.midY - ellipseH/2,
                       width: ellipseW,
                       height: ellipseH))
        }
        layer.path = path
        
        let mask = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addEllipse(in: frame)
        mask.path = maskPath
        mask.fillColor = UIColor.black.cgColor
        
        layer.mask = mask
        return layer
    }
    
    func pointerLayer(size: CGSize) -> CALayer {
        let frame    = CGRect(origin: .zero, size: size)
        let barSize  = CGSize(width: frame.width/16, height: frame.height/3)
        let barOrig  = CGPoint(x: frame.midX - barSize.width/2, y: frame.height/30)
        let barFrame = CGRect(origin: barOrig, size: barSize)
        let corner   = barSize.width / 2.0
        
        let shadowMaskPath  = CGMutablePath()
        shadowMaskPath.addRoundedRect(in: barFrame, cornerWidth: corner, cornerHeight: corner)
        let shadowMask      = CAShapeLayer()
        shadowMask.path     = shadowMaskPath
        
        let path = CGMutablePath()
        path.addRoundedRect(in: barFrame, cornerWidth: corner, cornerHeight: corner)
        path.addRect(barFrame.insetBy(dx: -10, dy: -10))
        
        let layer           = CAShapeLayer()
        layer.frame         = frame
        layer.path          = path
        layer.mask          = shadowMask
        layer.strokeColor   = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).cgColor
        layer.fillRule      = .evenOdd
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = .zero
        layer.shadowRadius  = barSize.width/4
        layer.shadowOpacity = 1
        return layer
    }
}
