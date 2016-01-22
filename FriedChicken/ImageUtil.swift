//
//  ImageUtil.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/22.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import UIKit

class ImageUtil {
    static func resizeImage(img: UIImage, size: CGSize) -> UIImage {
        let widthRatio = size.width / img.size.width
        let heightRatio = size.height / img.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (img.size.width * ratio), height: (img.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        img.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}