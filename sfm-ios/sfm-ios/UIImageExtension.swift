//
//  UIImageExtension.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/27.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import Foundation

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
