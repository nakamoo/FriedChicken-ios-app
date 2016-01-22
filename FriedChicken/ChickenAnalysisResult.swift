//
//  ChickenAnalysisResult.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/22.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import Foundation
import RealmSwift

class ChickenAnalysisResult: Object {
    dynamic var imgData :NSData?
    dynamic var score :Int
    dynamic var msg :String
    dynamic var generatedImg :UIImage? // 変換済みのUIImageを保存(Not saved properties

    override static func ignoredProperties() -> [String] {
        return ["generatedImg"]
    }

    // Default value
    required init() {
        self.score = 100
        self.msg = "まぁまぁの揚げっぷりですね"
        super.init()
    }
    
    init(errorMessage :String) {
        self.score = -1
        self.msg = errorMessage
        super.init()
    }
    
    init(img :UIImage, score :Int, msg :String) {
        self.imgData = UIImagePNGRepresentation(img)
        self.score = score
        self.msg = msg
        super.init()
    }

    func img() -> UIImage {
        if let image = generatedImg {
            // 既に変換済みの場合
            return image
        }

        if let data = imgData {
            return UIImage(data: data)!
        } else {
            return UIImage()
        }
    }
    
    /// エラーかどうかを返す
    func hasError() -> Bool {
        return self.score < 0
    }
}