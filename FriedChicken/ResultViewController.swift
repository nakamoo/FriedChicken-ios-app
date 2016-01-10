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
}
