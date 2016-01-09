//
//  ChickenAnalyzer.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/03.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures

class ChickenAnalyzer {
    let img :UIImage

    init(image: UIImage) {
        self.img = image
    }

    /**
     非同期に解析するメソッド．Futureを返却する
     */
    func asyncAnalyze() -> Future<Result, ChickenAnalyzeError> {

        let promise = Promise<Result, ChickenAnalyzeError>()
        Queue.global.async { () -> Void in
            let res = self.analyze()

            if (res.hasError()) {
                promise.failure(ChickenAnalyzeError.UnknownError(res.msg))
            } else {
                promise.success(self.analyze())
            }
        }
        return promise.future
    }

    /**
     同期で解析するメソッド
    */
    func analyze() -> (Result) {
        let score =  0
        let msg = "いい揚げっぷりですね！"
        return Result(img: img, score: score, msg: msg)
    }

    /// 解析結果を格納するオブジェクト
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

        init(errorMessage :String) {
            self.score = -1
            self.msg = errorMessage
            self.img = UIImage()
        }

        init(img :UIImage, score :Int, msg :String) {
            self.img = img
            self.score = score
            self.msg = msg
        }

        /// エラーかどうかを返す
        func hasError() -> Bool {
            return self.score < 0
        }
    }

    enum ChickenAnalyzeError: ErrorType {
        case UnknownError(String)
    }
}