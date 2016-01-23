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
    let MAX_ROW_COUNT_OF_ENTRIES = 10

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

        cell.titleLabel.text = "\(String(result.score))点の唐揚げ"
        cell.imgView.image = result.img()
        cell.dateLabel.text = dateToString(result.createdAt)
        return cell
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        selectedResult = analysisResults[indexPath.row]
        self.performSegueWithIdentifier("show_history_result", sender: self)
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
}