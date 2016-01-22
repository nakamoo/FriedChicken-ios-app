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
    dynamic var objectId: String = ""
    dynamic var imgData :NSData?
    dynamic var score :Int = 100
    dynamic var msg :String = "まぁまぁの揚げっぷりですね"
    var generatedImg :UIImage? // 変換済みのUIImageを保存(Not saved properties

    override static func ignoredProperties() -> [String] {
        return ["generatedImg"]
    }

    override static func primaryKey() -> String? {
        return "objectId"
    }

    convenience init(errorMessage :String) {
        self.init(imgData: NSData(), score: -1, msg: errorMessage)
    }

    convenience init(img :UIImage, score :Int, msg :String) {
        self.init(imgData: UIImagePNGRepresentation(img)!, score: score, msg: msg)
    }

    convenience init(imgData :NSData, score :Int, msg :String) {
        self.init()
        self.objectId = NSUUID().UUIDString
        self.imgData = imgData
        self.score = score
        self.msg = msg
    }

    func img() -> UIImage {
        if let image = generatedImg {
            // 既に変換済みの場合
            return image
        }

        if let data = imgData {
            if let img = UIImage(data: data) {
                return img
            }
        }

        return UIImage()
    }
    
    /// エラーかどうかを返す
    func hasError() -> Bool {
        return self.score < 0
    }
}