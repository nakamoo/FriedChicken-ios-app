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
import RealmSwift

class ChickenAnalyzer {
    let loadCsvPromise: Promise<Void, ChickenAnalyzeError>

    var inputBias: [[Double]]?
    var inputWeight: [[Double]]?
    var outputBias: [[Double]]?
    var outputWeight: [[Double]]?

    init() {
        loadCsvPromise = Promise<Void, ChickenAnalyzeError>()
        Queue.global.async { () -> Void in
            self.loadCsvs()
            self.loadCsvPromise.success()
        }
    }
    
    /**
     非同期に解析するメソッド．Futureを返却する
     Realmオブジェクトはスレッド間の受け渡しが出来ないため，objectIdを返す
     */
    func asyncAnalyze(img: UIImage) -> Future<String, ChickenAnalyzeError> {
        let promise = Promise<String, ChickenAnalyzeError>()

        loadCsvPromise.future.onSuccess { () -> Void in
            Queue.global.async { () -> Void in
                let res = self.analyze(img)

                // 人工知能が解析してる感を出すためスリープ
                sleep(1)

                if res.hasError() {
                    promise.failure(ChickenAnalyzeError.UnknownError(res.msg))
                } else {
                    promise.success(res.objectId)
                }
            }
        }

        return promise.future
    }

    /**
     csvファイルに書かれた重みとバイアスを読み込む
     */
    func loadCsvs() -> Void {
        inputBias = readCsv("ib")
        inputWeight = readCsv("iw")
        outputBias = readCsv("ob")
        outputWeight = readCsv("ow")
    }

    /**
     同期で解析するメソッド
     */
    func analyze(img: UIImage) -> (ChickenAnalysisResult) {
        // 画像を正方形にクロップし、30×30にリサイズする
        let sq_img = cropImageToSquare(img)
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        sq_img!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 画像を配列に変換
        let imageRef = resizeImage.CGImage!
        let imageData = getByteArrayFromImage(imageRef)
        UIGraphicsEndImageContext()
        
        // ニューラルネットワークの各層を定義
        var input:[Double] = []
        var middle:[Double] = []
        var output:Double = 0.0

        // RGBAからBGRの順に配列を並べ替えて入力層に値を格納する
        for i in 0...899{
            let b:Int = numericCast(imageData[4*i])
            let g:Int = numericCast(imageData[4*i+1])
            let r:Int = numericCast(imageData[4*i+2])
            
            input.append(Double(b))
            input.append(Double(g))
            input.append(Double(r))
        }
        
        //　中間層を計算
        for (var i = 0; i < inputWeight!.count; i++) {
            var m = calInnerProduct(input, b:inputWeight![i])
            m += inputBias![0][i]
            m =  1 / (1 + pow(M_E, m))
            middle.append(m)
        }
        
        // 出力層を計算
        output = calInnerProduct(middle, b: outputWeight![0]) + outputBias![0][0]
        output = 1 / (1 + pow(M_E, output))
        
        
        var score = Int(output * 10000)
        
        
        var msg = "いい揚げっぷりですね！"
        
        if score < 1000 {msg = "ほ、ほんとにこれは唐揚げなのかな？"}
        else if score < 2000 {msg = "もっと油の声に耳を傾けてみましょう。"}
        else if score < 3000 {msg = "いまいち唐揚げだなー。。。"}
        else if score < 4000 {msg = "まぁまぁの唐揚げですね！"}
        else if score < 5000 {msg = "いい揚げっぷりですね！"}
        else if score < 6000 {msg = "よ、よだれが止まらない。。。"}
        else if score < 7000 {msg = "美味しそうだなあ。。。"}
        else if score < 8000 {msg = "こんな美味しそうな唐揚げは見たこと無い！"}
        else if score < 9000 {msg = "至極の逸品。。。"}
        else {
            msg = "この唐揚げの唐揚力は530000です。"
            score = 530000
        }

        let result = ChickenAnalysisResult(img: img, score: score, msg: msg)
        saveResult(result)
        
        return result
    }
    
    /**
     画像を配列に変換するメソッド
     */
    func getByteArrayFromImage(imageRef: CGImageRef) -> [UInt8] {
        let data = CGDataProviderCopyData(CGImageGetDataProvider(imageRef))
        let length = CFDataGetLength(data)
        var rawData = [UInt8](count: length, repeatedValue: 0)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        
        return rawData
    }
    
    /**
     csvを読み込み二次元配列に格納するメソッド
     */
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
    
    /**
     内積を計算するメソッド
     */
    func calInnerProduct(a:[Double], b:[Double]) -> Double {
        var answer = 0.0
        for (var i = 0; i < a.count; i++) {
            answer += a[i] * b[i]
        }
        return answer
    }
    
    /**
     画像を正方形にクロップするメソッド
     */
    func cropImageToSquare(image: UIImage) -> UIImage? {
        if image.size.width > image.size.height {
            // 横長
            let margin = image.size.height/6
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(image.size.width/2 - image.size.height/2 + margin,
                margin,
                image.size.height - margin * 2, image.size.height - margin * 2))
            
            return UIImage(CGImage: cropCGImageRef!)
        } else if image.size.width < image.size.height {
            // 縦長
            let margin = image.size.width/6
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(margin,
                image.size.height/2 - image.size.width/2 + margin,
                image.size.width - margin * 2, image.size.width - margin * 2))
            
            return UIImage(CGImage: cropCGImageRef!)
        } else {
            return image
        }
    }

    /**
     解析結果を保存する
     */
    func saveResult(result: ChickenAnalysisResult) -> Void {
        let realm = try! Realm()
        try! realm.write {
            realm.add(result)
        }

        let results = realm
            .objects(ChickenAnalysisResult)
            .sorted("createdAt", ascending: true)
            .map { $0 }

        if results.count > ChickenAnalysisResult.MAX_PERSISTENT_SIZE {
            try! realm.write {
                realm.delete(results[0..<(results.count - ChickenAnalysisResult.MAX_PERSISTENT_SIZE)])
            }
        }

    }
    
    enum ChickenAnalyzeError: ErrorType {
        case UnknownError(String)
        
        func getErrorMsg() -> String {
            switch self {
            case.UnknownError(let msg):
                return msg
            }
        }
    }
}