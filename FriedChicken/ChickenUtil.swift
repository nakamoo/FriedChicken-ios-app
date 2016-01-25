//
//  ChickenUtil.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/24.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i {
                swap(&self[i], &self[j])
            }
        }
    }

    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Element] {
        var list = self
        list.shuffle()
        return list
    }
}

extension UIView {

    func captureImage() -> UIImage{

        // キャプチャする範囲を取得.
        let rect = self.bounds

        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContextRef! = UIGraphicsGetCurrentContext()

        // 対象のview内の描画をcontextに複写する.
        self.layer.renderInContext(context)

        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()

        // contextを閉じる.
        UIGraphicsEndImageContext()

        return capturedImage
    }
}

class ChickenUtil {
    static func shuffle<T>(inout array: [T]) {
        for var j = array.count - 1; j > 0; j-- {
            let k = Int(arc4random_uniform(UInt32(j + 1))) // 0 <= k <= j
            swap(&array[k], &array[j])
        }
    }

    static func shuffled<S: SequenceType>(source: S) -> [S.Generator.Element] {
        var copy = Array<S.Generator.Element>(source)
        shuffle(&copy)
        return copy
    }
}