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
//        CalFCPower.CalFCPower(img)
        // 入力画像を正方形に
        var sq_img = cropImageToSquare(img)
        
        // 30×30にリサイズ
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        sq_img!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        
        let imageRef = resizeImage.CGImage!
//        let imageRef = img.CGImage!
        let imageData = getByteArrayFromImage(imageRef)
        
        
        var input:[Double] = []
        var middle:[Double] = []
        var output:Double = 0.0
        
        // RGBAからBGRの順に配列を並べ替える
        for i in 0...899{
            let b:Int = numericCast(imageData[4*i])
            let g:Int = numericCast(imageData[4*i+1])
            let r:Int = numericCast(imageData[4*i+2])

            input.append(Double(b))
            input.append(Double(g))
            input.append(Double(r))
        }
        
        // csvファイルに書かれた重みとバイアスを読み込む
        // シュミレータだと少し重い
        let input_bias = readCsv("ib")
        let input_weight = readCsv("iw")
        let output_bias = readCsv("ob")
        let output_weight = readCsv("ow")
        
        //　中間層を計算
        for (var i = 0; i < input_weight.count; i++) {
            var m = calInnerProduct(input, b:input_weight[i])
            m += input_bias[0][i]
            m =  1 / (1 + pow(M_E, m))
            middle.append(m)
        }
        
        // 出力層を計算
        output = calInnerProduct(middle, b: output_weight[0]) + output_bias[0][0]
        output = 1 / (1 + pow(M_E, output))
        
        
        
        let msg = "いい揚げっぷりですね！"
        let score = Int(output * 10000)
        return Result(img: img, score: score, msg: msg)
    }
    
    func getByteArrayFromImage(imageRef: CGImageRef) -> [UInt8] {
        let data = CGDataProviderCopyData(CGImageGetDataProvider(imageRef))
        let length = CFDataGetLength(data)
        var rawData = [UInt8](count: length, repeatedValue: 0)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        
        return rawData
    }
    
    func readCsv(name:String) -> [[Double]] {
        var result: [[Double]] = []
        if let csvPath = NSBundle.mainBundle().pathForResource(name, ofType: "csv") {
            var csvString = ""
            do {
                csvString = try String(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            csvString.enumerateLines { (line, stop) -> () in
                var arr:[Double] = []
                for num in line.componentsSeparatedByString(",") {
                    arr.append(atof(num))
                }
                result.append(arr)
            }
        }
        return result
    }
    
    func calInnerProduct(a:[Double], b:[Double]) -> Double {
        var answer = 0.0
        for (var i = 0; i < a.count; i++) {
            answer += a[i] * b[i]
        }
        return answer
    }
    
    func cropImageToSquare(image: UIImage) -> UIImage? {
        if image.size.width > image.size.height {
            // 横長
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(image.size.width/2 - image.size.height/2, 0, image.size.height, image.size.height))
            
            return UIImage(CGImage: cropCGImageRef!)
        } else if image.size.width < image.size.height {
            // 縦長
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, image.size.width, image.size.width))
            
            return UIImage(CGImage: cropCGImageRef!)
        } else {
            return image
        }
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