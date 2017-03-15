
import UIKit
import RealmSwift
import CoreActionSheetPicker


class SetTimeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum AdjustTimeType {
        case goBack
        case ahead
        case none
    }
    
    // ピンされた都市のID。 -1 = isSelectedな都市が1件もなく、テーブルセルが一行もない状態
    var pinedCityCell = -1

    // タイム調整バフ・デバフ
    var adjustTimeStat = 0
    
    
    // GMT標準時刻
    var GMT = Date()
    
    let realm = try! Realm()
    
    var cities: Results<City>!
    //  = try! Realm().objects(City.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
    
    
    /* UI Components */
    @IBOutlet weak var cityNameLabel:  UILabel!
    @IBOutlet weak var MDYLabel:       UILabel!
    @IBOutlet weak var timeLabel:      UILabel!
    @IBOutlet weak var timeAheadLabel: UILabel!
    
    @IBOutlet weak var tableView:      UITableView!
    
    @IBOutlet weak var adjustTimeBeforeLabel: UILabel!
    @IBOutlet weak var adjustTimeNowLabel:    UILabel!
    @IBOutlet weak var adjustTimeAheadLabel:  UILabel!
    
    
    @IBAction func adjustTimeBeforeButton(_ sender: Any) {
        renewAllTimeLabels(adjustType: .goBack)
    }
    
    
    @IBAction func adjustTimeAheadButton(_ sender: Any) {
        renewAllTimeLabels(adjustType: .ahead)
    }

    
    func renewAllTimeLabels(adjustType: AdjustTimeType) {
        
        if cities.isEmpty {
            print("なにもしない")
            return
        }
        
        switch adjustType {
            case .goBack:
                adjustTimeStat -= 1
            case .ahead:
                adjustTimeStat += 1
            case .none:
                adjustTimeStat += 0
        }
        
        print("バフレベル: \(adjustTimeStat)")
        
        let bef30 = 60 * 30 * (adjustTimeStat-1)
        let new   = 60 * 30 * (adjustTimeStat+0)
        let aft30 = 60 * 30 * (adjustTimeStat+1)
        
        let before30m = Date(timeInterval:  TimeInterval(bef30), since: GMT)
        let newtral   = Date(timeInterval:  TimeInterval(new), since: GMT)
        let after30m  = Date(timeInterval:  TimeInterval(aft30), since: GMT)
        
        
        MDYLabel.text = DateUtils.stringFromDate(
            date: newtral,
            format: "",
            tz: NSTimeZone(name: cities[pinedCityCell].timeZone) as! TimeZone
        )
        
        
        timeLabel.text = DateUtils.stringFromDate(
            date: newtral,
            format: "HH:mm",
            tz: NSTimeZone(name: cities[pinedCityCell].timeZone) as! TimeZone
        )       //tmpFormat2.string(from: newtral)
        
        
        adjustTimeBeforeLabel.text = DateUtils.stringFromDate(
            date: before30m,
            format: "HH:mm",
            tz: NSTimeZone(name: cities[pinedCityCell].timeZone) as! TimeZone
        )
        
        
        adjustTimeNowLabel.text = DateUtils.stringFromDate(
            date: newtral,
            format: "HH:mm",
            tz: NSTimeZone(name: cities[pinedCityCell].timeZone) as! TimeZone
        )
        
        
        adjustTimeAheadLabel.text = DateUtils.stringFromDate(
            date: after30m,
            format: "HH:mm",
            tz: NSTimeZone(name: cities[pinedCityCell].timeZone) as! TimeZone
        )
        
        
        let minusOrPlus  = adjustTimeStat > 0 ? "+ " : "- "
        let diffHour     = "\(abs(adjustTimeStat / 2)):"
        let diffMinutes  = adjustTimeStat % 2 == 0 ? "00 " : "30 "
        let pastOrFuture = adjustTimeStat > 0 ? "in the future" : "in the past"
        
        timeAheadLabel.text = minusOrPlus + diffHour + diffMinutes + pastOrFuture
        
        if adjustTimeStat == 0 {
            timeAheadLabel.text = "now"
        }
        
        // テーブル再描画
        tableView.reloadData()
    }
    
    
    
    ////////////////////
    // MARK: Life Cycle
    ////////////////////
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        
        // Realmのパス
        // print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //
        adjustTimeStat = 0
        timeAheadLabel.text = "now"
        //
        GMT = Date()
        
        cities = realm.objects(City.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
        
        print("画面2: will appear まさか　こっちのほうが　速いのか！？")
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        print("画面2: did appear まさか　こっちのほうが　速いのか！？????")
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "pinedCityCell") != nil {
            pinedCityCell = ud.integer(forKey: "pinedCityCell")
            print("データあり！ pinedCityCell は \(pinedCityCell)")
        }
        
        // ↓のreloadは、↑のUserDefaultを呼んだ後でないとダメ
        tableView.reloadData()
        
        
        // ラベルに表示する内容は、 viewWillAppearだと、早すぎる。こっちに書かないとだめ。
        if !cities.isEmpty {
            let pin = "\u{1F4CC} "
            cityNameLabel.text = pin + cities[pinedCityCell].name.uppercased()
        }
        cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        renewAllTimeLabels(adjustType: .none)
        
    }
    
    
    ///////////////////
    // MARK: Table View
    ///////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // case 1: バフ・デバフ != 0
        
        if adjustTimeStat != 0 {
            
            let interval = 60 * 30 * (adjustTimeStat+0)
            let newtral = Date(timeInterval:  TimeInterval(interval), since: self.GMT)
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InitialTableViewCell
            
            cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
            cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
            
            cell.yearAndMonthLabel.text = DateUtils.stringFromDate(
                date: newtral,
                format: "",
                tz: NSTimeZone(name: cities[indexPath.row].timeZone) as! TimeZone
            )
            
            cell.yearAndMonthLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
            
            
            cell.timeLabel.text = DateUtils.stringFromDate(
                date: newtral,
                format: "HH:mm",
                tz: NSTimeZone(name: cities[indexPath.row].timeZone) as! TimeZone
            )
            
            cell.timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
            cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
            
            return cell
            
        } // 特別時のセル設定 完了
        
        
        // case 2: バフ・デバフ == 0
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InitialTableViewCell
        
        
        // 2017/1/25修正
        cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
        cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        cell.yearAndMonthLabel.text = DateUtils.stringFromDate(
            date: self.GMT,
            format: "",
            tz: NSTimeZone(name: cities[indexPath.row].timeZone) as! TimeZone
        )

        cell.yearAndMonthLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
        
        
        cell.timeLabel.text = DateUtils.stringFromDate(
            date: self.GMT,
            format: "HH:mm",
            tz: NSTimeZone(name: cities[indexPath.row].timeZone) as! TimeZone
        )

        cell.timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        return cell
    }
    
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {
        
        if tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // 並び替え可能なセルの指定(今回は"すべて")
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // セルをdeleteするときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let delatingCity = cities[indexPath.row]
            
            try! realm.write {
                delatingCity.isSelected = false
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == pinedCityCell {
            return 0
        }
        return 75
    }
    
    
    // 3/10 タップアクション追加
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        for touch: UITouch in touches {
            
            let tag = touch.view!.tag
            switch tag {
                case 1, 2:
                    let v = touch.view
                    if let v = v {
                        tap(v)
                    }
                default:
                    break
            }
        }
    }
    
    
    func tap(_ view: UIView) {
        
        print("きたね。タグ番号は\(view.tag)")
        
        let pickerMode = (view.tag == 1) ? UIDatePickerMode.date : UIDatePickerMode.dateAndTime
        
        let fm = DateFormatter()
    
        let tz = NSTimeZone.system
        print("端末のtz: \(tz)")  // America/Vancouver (current)
        
        // abs(ピンされた都市 - 端末timeZoneの都市)で求められる
        let diff = abs(
            (NSTimeZone(name: cities[pinedCityCell].timeZone) as TimeZone!).secondsFromGMT()
            -
            tz.secondsFromGMT()
        )
        
        print("差: \(diff)")
        
        let t = Date(timeIntervalSinceNow: TimeInterval(diff))
        
        let datePicker = ActionSheetDatePicker(
            title: "Select date.",
            datePickerMode: pickerMode,

            selectedDate: t,
            
            doneBlock: { picker, value, index in
                
                print("value = \(value)"); print("index = \(index)"); print("picker = \(picker)")
                
                // ↑で作ったDate()をもとに生成されたvalue
                let tt = Date(timeInterval: TimeInterval(-diff), since: value as! Date)
                
                // たぶん　ここまではいいんよな・・・
                // cellForRowが問題
                self.GMT = tt
            
                self.tableView.reloadData()
                
                // 後始末　ここも慎重に書かないと即死だぞ
                self.adjustTimeStat = 0
                self.timeAheadLabel.text = "now"

                fm.dateFormat = "HH:mm"
                fm.timeZone = NSTimeZone(name: self.cities[self.pinedCityCell].timeZone) as TimeZone!
                
                
                self.renewAllTimeLabels(adjustType: .none)
                
                
//                self.timeLabel.text = fm.string(from: self.GMT)
//
//                let before30m = Date(timeInterval:  TimeInterval(60 * -30), since: self.GMT)
//                let newtral   = Date(timeInterval:  TimeInterval(0), since: self.GMT)
//                let after30m  = Date(timeInterval:  TimeInterval(60 * 30), since: self.GMT)
//                
//                self.adjustTimeBeforeLabel.text = fm.string(from: before30m)
//                self.adjustTimeNowLabel.text    = fm.string(from: newtral)
//                self.adjustTimeAheadLabel.text  = fm.string(from: after30m)
                
                
            },
            
            cancel: { ActionStringCancelBlock in return },
            origin: view
        )
        
        datePicker?.show()
    }
}
