//
//  ResultViewController.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/03.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import UIKit
import Social
import SCLAlertView

class ResultViewController: UIViewController {
    let MAX_NUMEBR_OF_DIGITS = 6
    let DIGIT_ORDER_ONES_PLACE = 0
    let DIGIT_ORDER_TENS_PLACE = 1
    let DIGIT_ORDER_HUNDREDS_PLACE = 2
    let DIGIT_ORDER_THOUSANDS_PLACE = 3
    let DIGIT_ORDER_TENTHOUSANDS_PLACE = 4
    let DIGIT_ORDER_ONEHUNDREDTHOUSANDS_PLACE = 5

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var karaageImage: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var commentText: UITextView!

    //Score Texts
    @IBOutlet weak var oneHundredThousandImg: UIImageView!
    @IBOutlet weak var tenThousandImg: UIImageView!
    @IBOutlet weak var thousandImg: UIImageView!
    @IBOutlet weak var hundredImg: UIImageView!
    @IBOutlet weak var tenImg: UIImageView!
    @IBOutlet weak var oneImg: UIImageView!

    var numberImgArray: Array<UIImageView> = []
    var scoreDigitArray: Array<Int> = []
    var scoreNumberOfDigits: Int = 0

    var result :ChickenAnalysisResult = ChickenAnalysisResult()

    override func viewDidLoad() {
        super.viewDidLoad()

        commentText.layer.borderWidth = 1
        commentText.layer.borderColor
            = UIColor(colorLiteralRed: 218.0 / 255.0, green: 218.0 / 255.0, blue: 218 / 255.0, alpha: 1).CGColor
        commentText.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 0)
        commentText.sizeToFit()

        setImagesArray()
        setScoreDigitArray()
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

    func setImagesArray() {
        numberImgArray.append(oneImg)
        numberImgArray.append(tenImg)
        numberImgArray.append(hundredImg)
        numberImgArray.append(thousandImg)
        numberImgArray.append(tenThousandImg)
        numberImgArray.append(oneHundredThousandImg)
    }

    func setResult() {
        karaageImage.image = fitToResultImageView(result.img())

        animateNumbers()
        showScoreImage(0)
    }

    func animateNumbers() {
        let imageListArray: Array<UIImage> = [1,2,3,4,5,6,7,8,9,0].map { UIImage(named: String($0))! }

        numberImgArray.forEach { (view: UIImageView!) -> Void in
            view.animationImages = imageListArray.shuffled()
            view.animationDuration = 0.1
            view.startAnimating()
        }
    }

    /**
     再帰的に下の桁から順にスコアをセット
     digitOrder: 下から何桁目か
     */
    func showScoreImage(digitOrder: Int) {
        let delay = 0.75 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            let imgView = self.numberImgArray[digitOrder]
            imgView.stopAnimating()

            imgView.image = self.generateScoreImage(self.scoreDigitArray[digitOrder],
                isZeroAllowed: self.isZeroAllowed(digitOrder))

            if digitOrder < self.scoreNumberOfDigits - 1 && digitOrder < self.MAX_NUMEBR_OF_DIGITS - 1 {
                self.showScoreImage(digitOrder + 1)
            } else {
                self.hideNonNeedDigits(digitOrder + 1)
                self.showCommentMessage()
            }
        })
    }

    func hideNonNeedDigits(digitOrder: Int) {
        var i = digitOrder
        while (i < self.MAX_NUMEBR_OF_DIGITS) {
            numberImgArray[i].stopAnimating()
            numberImgArray[i].image = UIImage()
            i++
        }
    }

    func showCommentMessage() {
        commentText.text = "この写真の唐揚力は\n"
            + String(result.score) + "点です\n" + result.msg
    }

    /**
     現在のスコアで，digitOrderの位が0を表示していいかを返す
     */
    func isZeroAllowed(digitOrder: Int) -> Bool {
        switch digitOrder {
        case DIGIT_ORDER_ONES_PLACE:
            return true
        case DIGIT_ORDER_ONEHUNDREDTHOUSANDS_PLACE:
            return false
        default:
            return scoreDigitArray[digitOrder - 1] != 0
        }
    }

    /**
     スコアを1桁ごとにArrayに格納
     桁数を返却
     */
    func setScoreDigitArray() {
        let score = result.score
        let onesPlace = score % 10
        let tensPlace = score % 100 / 10
        let hundredsPlace = score % 1000 / 100
        let thousandsPlace = score % 10000 / 1000
        let tenThousandsPlace = score % 100000 / 10000
        let oneHundredThousandsPlace = score % 1000000 / 100000
        scoreDigitArray = [onesPlace, tensPlace, hundredsPlace, thousandsPlace, tenThousandsPlace, oneHundredThousandsPlace]
        scoreNumberOfDigits = String(score).characters.count
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


    @IBAction func shareWithFB(sender: AnyObject) {
        let text = "この唐揚力は" + String(result.score) + "点! "
            + result.msg + "by日本唐揚協会「唐揚力診断」"
        // FBの場合はスクショをシェア
        shareWithSocial(SLServiceTypeFacebook, initialText: text, img: contentView.captureImage())
    }

    @IBAction func shareWithTwitter(sender: AnyObject) {
        let text = "この唐揚力は" + String(result.score) + "点! "
            + result.msg + "#日本唐揚協会 #唐揚力診断"
        shareWithSocial(SLServiceTypeTwitter, initialText: text, img: result.img())
    }

    @IBAction func shareWithLINE(sender: AnyObject) {
        let text = "唐揚力" + String(result.score) + "点! "
            + "写真の唐揚力を測れるアプリがオススメ！ #日本唐揚協会 #唐揚力診断 http://karaage.ne.jp/"

        let urlScheme = "line://msg/text/"
            + text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: urlScheme)!

        if !UIApplication.sharedApplication().canOpenURL(url) {
            SCLAlertView().showError("エラー", subTitle: "LINEがインストールされていません", closeButtonTitle: "閉じる")
            return
        }

        UIApplication.sharedApplication().openURL(url)
    }

    /**
     FB, Twitterへポストする．
     FBでimgは付与できなくなった．（FBのポリシー変更による
     */
    func shareWithSocial(serviceType :String, initialText :String, img :UIImage) {
        let composeViewController :SLComposeViewController = SLComposeViewController(forServiceType: serviceType)!
        composeViewController.setInitialText(initialText)
        composeViewController.addImage(img)

        self.presentViewController(composeViewController, animated: true, completion: nil)
    }
}