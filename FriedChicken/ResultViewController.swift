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

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var karaageImage: UIImageView!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!

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
        scoreText.text = String(result.score)

        commentText.text = "この写真の唐揚げ力は\n"
            + String(result.score) + "点です\n" + result.msg
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
        let text = "この唐揚げ力は" + String(result.score) + "点! "
            + result.msg + "by 唐揚げアプリ"
        shareWithSocial(SLServiceTypeFacebook, initialText: text)
    }

    @IBAction func shareWithTwitter(sender: AnyObject) {
        let text = "この唐揚げ力は" + String(result.score) + "点! "
            + result.msg + "#唐揚げアプリ"
        shareWithSocial(SLServiceTypeTwitter, initialText: text)
    }


    @IBAction func shareWithLINE(sender: AnyObject) {
        let text = "唐揚げ力" + String(result.score) + "点! "
            + "写真の唐揚げ力を測れるアプリがオススメ！"

        let urlScheme = "line://msg//text/"
            + text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let url = NSURL(string: urlScheme)!

        if !UIApplication.sharedApplication().canOpenURL(url) {
            SCLAlertView().showError("エラー", subTitle: "LINEがインストールされていません", closeButtonTitle: "閉じる")
            return
        }

        UIApplication.sharedApplication().openURL(url)
    }

    func shareWithSocial(serviceType :String, initialText :String) {
        let composeViewController :SLComposeViewController = SLComposeViewController(forServiceType: serviceType)!
        composeViewController.setInitialText(initialText)
        composeViewController.addImage(result.img)

        self.presentViewController(composeViewController, animated: true, completion: nil)
    }
}
