//
//  ViewController.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2015/12/23.
//  Copyright © 2015年 Japan Karaage Association. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var analysisResult :ChickenAnalyzer.Result = ChickenAnalyzer.Result()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        if didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage] != nil {

            let img = didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage] as? UIImage
            analysisResult = ChickenAnalyzer(image: img!).analyze()
            NSLog("%d : %s", analysisResult.score, analysisResult.msg)
            performSegueWithIdentifier("show_result", sender: self)
        }
        //写真選択後にカメラロール表示ViewControllerを引っ込める動作
        picker.dismissViewControllerAnimated(true, completion: nil)
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

