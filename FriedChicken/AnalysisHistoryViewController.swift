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

    var listEntries: Array<DataHolder> = []
    var selectedResult: ChickenAnalysisResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        listEntries = getInitialEntries()
    }

    func getInitialEntries() -> Array<DataHolder> {
        let realm = try! Realm()
        return realm.objects(ChickenAnalysisResult)
            .sorted("createdAt", ascending: false)
            .map { result in
                return DataHolder(objectId: result.objectId,
                    img: result.img(),
                    score: result.score,
                    date: result.createdAt)
        }
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(listEntries.count, MAX_ROW_COUNT_OF_ENTRIES)
    }

    // セルのテキストを追加
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("analysis_result_table_view_cell",
            forIndexPath: indexPath) as! AnalysisResultTableViewCell
        let holder = listEntries[indexPath.row]

        cell.titleLabel.text = "\(String(holder.score))点の唐揚げ"
        cell.imgView.image = holder.img
        cell.dateLabel.text = dateToString(holder.date)
        return cell
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {

        let realm = try! Realm()
        if let result = realm.objectForPrimaryKey(ChickenAnalysisResult.self,
            key: listEntries[indexPath.row].objectId) {
            selectedResult = result
            self.performSegueWithIdentifier("show_history_result", sender: self)
        }
    }

    class DataHolder {
        let objectId: String
        let img: UIImage
        let score: Int
        let date: NSDate

        init(objectId: String, img: UIImage, score: Int, date: NSDate) {
            self.objectId = objectId
            self.img = img
            self.score = score
            self.date = date
        }
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