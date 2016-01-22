//
//  HomeViewController.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2015/12/23.
//  Copyright © 2015年 Japan Karaage Association. All rights reserved.
//

import UIKit
import MRProgress
import SCLAlertView

class HomeViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageSelectBtn: UIButton!

    var progressView :MRProgressOverlayView?

    var selectedImage :UIImage? = nil
    var analysisResult :ChickenAnalysisResult = ChickenAnalysisResult()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageSelectBtn.layer.cornerRadius = 3
    }

    override func viewDidAppear(animated: Bool) {

        if selectedImage != nil {
            // 画像選択後，画面遷移してきた場合
            // ProgressDialogを出すために，ViewDidAppear以降で呼ぶ必要がある
            onSelectedImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     ライブラリから写真を選択する
     */
    func pickImageFromLibrary() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {

            let controller = UIImagePickerController()
            controller.delegate = self

            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary

            //新たに追加したカメラロール表示ViewControllerをpresentViewControllerにする
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

    // 写真選択後に呼ばれるCallback
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo: [String: AnyObject]) {
        //写真選択後にカメラロール表示ViewControllerを引っ込める動作
        picker.dismissViewControllerAnimated(true, completion: nil)

        if didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage] != nil {
            // 選択された画像をセットする
            selectedImage = didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }

    // 画像選択後の処理
    // ProgressDialogを表示するため，ViewDidAppear以降で呼ぶこと
    func onSelectedImage() {
        showProgress()

        ChickenAnalyzer(image: selectedImage!).asyncAnalyze()
            .onComplete { _ in
                self.hideProgress()
                // 画像解析後，選択済みの画像は解除
                self.selectedImage = nil
            }
            .onSuccess { result in
                self.analysisResult = result
                self.performSegueWithIdentifier("show_result", sender: self)
            }
            .onFailure { error in
                self.showError(error.getErrorMsg())
            }
    }

    func showProgress() {
         MRProgressOverlayView.showOverlayAddedTo(self.view,
            title: "人工知能が\n解析しています...",
            mode: MRProgressOverlayViewMode.Indeterminate,
            animated: true)
    }

    func hideProgress() {
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }

    func showError(errMsg :String) {
        SCLAlertView().showError("解析失敗...", subTitle: errMsg, closeButtonTitle: "閉じる")
    }

    @IBAction func onClickSelectImageBtn(sender: AnyObject) {
        pickImageFromLibrary()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_result" {
            let resultController = segue.destinationViewController as! ResultViewController
            resultController.result = analysisResult
        }
    }
}

