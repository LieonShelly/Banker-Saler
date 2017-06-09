//
//  MD5.swift
//  AdForMerchant
//
//  Created by Kuma on 3/16/16.
//  Copyright © 2016 Windward. All rights reserved.
// swiftlint:disable function_parameter_count

import Foundation

extension String {
    var md5: String! {
        guard let str = self.cString(using: String.Encoding.utf8) else { return "" }
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }

    func attributedString(_ color: UIColor = UIColor.black, fontSize: CGFloat, strikethrough: Bool = false) -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize), NSStrikethroughStyleAttributeName: strikethrough])
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.append(right)
    return result
}

extension NSAttributedString {
    
    // 前半部分和后半部分字体不同
    convenience init(leftString: String, rightString: String, leftColor: UIColor, rightColor: UIColor, leftFontSize: CGFloat, rightFoneSize: CGFloat) {
        let string: NSAttributedString
        let left = leftString.attributedString(leftColor, fontSize: leftFontSize)
        let right = rightString.attributedString(rightColor, fontSize: rightFoneSize)
        string = left + right
        self.init(attributedString: string)
   }
}
