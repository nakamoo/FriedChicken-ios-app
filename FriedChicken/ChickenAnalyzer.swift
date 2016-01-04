//
//  ChickenAnalyzer.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/03.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import Foundation
import UIKit

class ChickenAnalyzer {
    let img :UIImage

    init(image: UIImage) {
        self.img = image
    }

    func analyze() -> (Result) {
        let score =  0
        let msg = "いい揚げっぷりですね！"
        return Result(img: img, score: score, msg: msg)
    }

    class Result {
        let img :UIImage
        let score :Int
        let msg :String

        // Default value
        init() {
            img = UIImage()
            score = 100
            msg = "まぁまぁの揚げっぷりですね"
        }

        init(img :UIImage, score :Int, msg :String) {
            self.img = img
            self.score = score
            self.msg = msg
        }
    }
}