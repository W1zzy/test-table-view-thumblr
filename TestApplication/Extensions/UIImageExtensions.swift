//
//  UIImageExtensions.swift
//  TestApplication
//
//  Created by Антон Братчик on 26.09.17.
//  Copyright © 2017 Антон Братчик. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(pixelWidth: CGFloat) -> UIImage? {
        let screenScale: CGFloat = UIScreen.main.scale
        let pointWidth = pixelWidth / screenScale
        let scale = pointWidth / self.size.width
        let size = self.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

