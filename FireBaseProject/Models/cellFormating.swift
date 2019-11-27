

import Foundation
import UIKit

struct CustomLayer{
    
    static let shared = CustomLayer()
    func createCustomlayer(layer:CALayer, shadowOpacity: Float,borderWidth:Double){
        layer.borderWidth = CGFloat(borderWidth)
        layer.borderColor = UIColor.black.cgColor
       // layer.masksToBounds = true
       layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
       layer.shadowRadius = 5.0
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
        //layer.cornerRadius = 20
    }
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor,newView:UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = newView.bounds

        newView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    func setGradientBackgroundArray(colorTop: UIColor, colorBottom: UIColor,newView:[UIView]) {
        for i in newView {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = i.bounds

        i.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    
}
