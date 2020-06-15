//
//  String.swift
//  Wasfa
//
//  Created by MacAir on 12/22/18.
//  Copyright © 2018 MacAir. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func strikeThrough(size : CGFloat, color : UIColor) -> NSAttributedString {
        let regularfontname = "HelveticaNeue"
        let font =  UIFont(name:regularfontname,size:size)
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        let attrs1 = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        attributeString.addAttributes(attrs1 as [NSAttributedString.Key : Any], range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func attributeString(size : CGFloat, color : UIColor) -> NSAttributedString {
        //  let boldfontname = "HelveticaNeue-Bold"
        let regularfontname = "HelveticaNeue"
        //   let mediumfontname = "HelveticaNeue-Medium"
        //    let lightfontname = "HelveticaNeue-Light"
        //    let italicfontname = "HelveticaNeue-Italic"
        
        let font =  UIFont(name:regularfontname,size:size)
        let attrs1 = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
        let attributeString = NSMutableAttributedString(string:self, attributes:attrs1 as [NSAttributedString.Key : Any])
        return attributeString
    }
    
    func addtwoattributeString(str1:String,str2 : String) -> NSMutableAttributedString
    {
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:str1, attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:str2, attributes:attrs2)
        
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    func fontfamily()
    {
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
    }
    
    func attributefeature()
    {
        //        Text Color
        //        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ]
        
        //        Background Color
        //        let myAttribute = [ NSAttributedString.Key.backgroundColor: UIColor.yellow ]
        
        //       underline
        //        let myAttribute = [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
        
        //        shadow
        //        let myShadow = NSShadow()
        //        myShadow.shadowBlurRadius = 3
        //        myShadow.shadowOffset = CGSize(width: 3, height: 3)
        //        myShadow.shadowColor = UIColor.gray
        //
        //        let myAttribute = [ NSAttributedString.Key.shadow: myShadow ]
    }
}
extension String {
func height(constraintedWidth width: CGFloat) -> CGFloat {
    let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.font = label.font.withSize(15)
    label.text = self
    label.sizeToFit()
    return label.frame.height
 }
    func width(constraintedheight height: CGFloat,fontSize:CGFloat,text:String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude , height: height))
       label.numberOfLines = 1
       label.font = label.font.withSize(fontSize)
       label.text = text
       label.sizeToFit()
        return label.intrinsicContentSize.width
    }
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}


