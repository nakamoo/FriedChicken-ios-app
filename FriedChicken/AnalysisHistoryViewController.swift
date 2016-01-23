//
//  AnalysisHistoryViewController.swift
//  FriedChicken
//
//  Created by JunyaOgasawara on 2016/01/22.
//  Copyright © 2016年 Japan Karaage Association. All rights reserved.
//

import UIKit
import RealmSwift

class AnalysisHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let MAX_ROW_COUNT_OF_ENTRIES = 20

    @IBOutlet weak var tableView: UITableView!

    var analysisResults: Array<ChickenAnalysisResult> = []
    var selectedResult: ChickenAnalysisResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        analysisResults = getInitialEntries()
    }

    func getInitialEntries() -> Array<ChickenAnalysisResult> {
        let realm = try! Realm()
        return realm.objects(ChickenAnalysisResult)
            .sorted("createdAt", ascending: false)
            .map { $0 }
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(analysisResults.count, MAX_ROW_COUNT_OF_ENTRIES)
    }

    // セルのテキストを追加
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("analysis_result_table_view_cell",
            forIndexPath: indexPath) as! AnalysisResultTableViewCell
        let result = analysisResults[indexPath.row]

        cell.titleLabel.text = "唐揚力 \(String(result.score))点"
        cell.imgView.contentMode = UIViewContentMode.ScaleToFill
        cell.imgView.image = result.img()

        cell.dateLabel.text = dateToString(result.createdAt)
        return cell
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        selectedResult = analysisResults[indexPath.row]
        self.performSegueWithIdentifier("show_history_result", sender: self)
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        footerView.backgroundColor = UIColor.whiteColor()
        footerView.textAlignment = NSTextAlignment.Center
        footerView.text = "最新20件まで表示します"
        return footerView
    }


    func dateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja")
        dateFormatter.dateFormat = "yyyy/MM/dd H:mm:ss"
        return dateFormatter.stringFromDate(date)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "show_history_result":
            if let result = selectedResult {
                let resultController = segue.destinationViewController as! ResultViewController
                resultController.result = result
            }
            break
        default: break
        }
    }

    @IBAction func onClickToggleOrderBtn(sender: UIBarButtonItem) {
        switch sender.title! {
        case "得点順":
            sender.title = "日付順"
            analysisResults.sortInPlace {
                (a: ChickenAnalysisResult, b: ChickenAnalysisResult) -> Bool in
                return a.score > b.score
            }
        case "日付順":
            sender.title = "得点順"
            analysisResults.sortInPlace {
                (a: ChickenAnalysisResult, b: ChickenAnalysisResult) -> Bool in
                return a.createdAt.timeIntervalSince1970 > b.createdAt.timeIntervalSince1970
            }
        default: break
        }
        tableView.reloadData()
    }

}