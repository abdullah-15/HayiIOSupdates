//
//  UIView.swift
//  NoqoodyPal
//

//

import Foundation
import UIKit


extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    
    @IBInspectable var ViewcornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    @IBInspectable var ViewborderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    @IBInspectable var ViewborderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var ViewshadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var ViewshadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
}

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#56992F")
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#82BD2C")
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

@IBDesignable
class HoriGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#D5205A")
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#EE8546")
    
    override func draw(_ rect: CGRect) {
        //  layer.sublayers?.first?.removeFromSuperlayer()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x:0.0, y:0.5);
        gradient.endPoint = CGPoint(x:1.0,y: 0.5);
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
}

@IBDesignable
class DiagonalGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#000000" ,alpha : 0.1)
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#000000" ,alpha : 0.8)
    
    override func draw(_ rect: CGRect) {
        let angle : Float = 150.0
        let gradientLayerView: UIView = UIView(frame: CGRect(x:0, y: 0, width: bounds.width, height: bounds.height))
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientLayerView.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        
        let alpha: Float = angle / 360
        let startPointX = powf(
            sinf(2 * Float.pi * ((alpha + 0.75) / 2)),
            2
        )
        let startPointY = powf(
            sinf(2 * Float.pi * ((alpha + 0) / 2)),
            2
        )
        let endPointX = powf(
            sinf(2 * Float.pi * ((alpha + 0.25) / 2)),
            2
        )
        let endPointY = powf(
            sinf(2 * Float.pi * ((alpha + 0.5) / 2)),
            2
        )
        
        gradient.endPoint = CGPoint(x: CGFloat(endPointX),y: CGFloat(endPointY))
        gradient.startPoint = CGPoint(x: CGFloat(startPointX), y: CGFloat(startPointY))
        
        gradientLayerView.layer.insertSublayer(gradient, at: 0)
        layer.insertSublayer(gradientLayerView.layer, at: 0)
    }
    
}


@IBDesignable
class HoriCancelGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#535D66")
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#6B7880")
    
    override func draw(_ rect: CGRect) {
        //  layer.sublayers?.first?.removeFromSuperlayer()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x:0.0, y:0.5);
        gradient.endPoint = CGPoint(x:1.0,y: 0.5);
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
}


@IBDesignable
class VerGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(hexString: "#6BA916", alpha : 0.3)
    @IBInspectable var endColor: UIColor = UIColor(hexString: "#6BA916"  , alpha : 1.0)
    
    override func draw(_ rect: CGRect) {
        //  layer.sublayers?.first?.removeFromSuperlayer()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0) // vertical gradient start
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0) // vertical gradient end
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
    
}

