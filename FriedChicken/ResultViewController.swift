//
//  ResultViewController.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/03.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var karaageImage: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!

    //Score Texts
    @IBOutlet weak var oneHundredThousandImg: UIImageView!
    @IBOutlet weak var tenThousandImg: UIImageView!
    @IBOutlet weak var thousandImg: UIImageView!
    @IBOutlet weak var hundredImg: UIImageView!
    @IBOutlet weak var tenImg: UIImageView!
    @IBOutlet weak var oneImg: UIImageView!


    var result :ChickenAnalyzer.Result = ChickenAnalyzer.Result()

    override func viewDidLoad() {
        super.viewDidLoad()

        setResult()
    }

    override func viewDidLayoutSubviews() {
        // ScrollViewを有効にするための記述
        self.scrollView.contentSize = self.contentView.bounds.size
        self.scrollView.flashScrollIndicators()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setResult() {
        karaageImage.image = fitToResultImageView(result.img)

        setScoreImages()

        commentText.text = "この写真の唐揚げ力は\n"
            + String(result.score) + "点です\n" + result.msg
    }

    // スコア画像を設定する
    func setScoreImages() {
        let score = result.score
        let onesPlace = score % 10
        let tensPlace = score % 100 / 10
        let hundredsPlace = score % 1000 / 100
        let thousandsPlace = score % 10000 / 1000
        let tenThousandsPlace = score % 100000 / 10000
        let oneHundredThousandsPlace = score % 1000000 / 100000

        oneHundredThousandImg.image = generateScoreImage(oneHundredThousandsPlace, isZeroAllowed: false)
        tenThousandImg.image = generateScoreImage(tenThousandsPlace, isZeroAllowed: oneHundredThousandsPlace != 0)
        thousandImg.image = generateScoreImage(thousandsPlace, isZeroAllowed: tenThousandsPlace != 0)
        hundredImg.image = generateScoreImage(hundredsPlace, isZeroAllowed: thousandsPlace != 0)
        tenImg.image = generateScoreImage(tensPlace, isZeroAllowed: hundredsPlace != 0)
        oneImg.image = generateScoreImage(onesPlace, isZeroAllowed: true)
    }

    // スコア用数字のUIImageを生成
    // isZeroAllowed=falseの時に，numが0だと空白画像返却
    func generateScoreImage(num :Int, isZeroAllowed :Bool) -> UIImage {
        if !isZeroAllowed && num == 0 {
            // Empty Image
            return UIImage()
        }
        if num < 0 || 9 < num {
            // Empty image
            return UIImage()
        }
        return UIImage(named: String(num))!
    }

    /**
     結果の画像サイズを補正する
     */
    func fitToResultImageView(img :UIImage) -> (UIImage) {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)
        img.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }

    @IBAction func onClickCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}