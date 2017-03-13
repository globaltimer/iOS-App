
import UIKit
import RealmSwift
import CoreActionSheetPicker


class InitialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // ピンされた都市のID。 -1 = isSelectedな都市が1件もなく、テーブルセルが一行もない状態
    var pinedCityCell = -1

    // タイム調整バフ・デバフ
    var adjustTimeStat = 0
    
    
    /* UI Components */
    @IBOutlet weak var cityNameLabel:  UILabel!
    @IBOutlet weak var MDYLabel:       UILabel!
    @IBOutlet weak var timeLabel:      UILabel!
    @IBOutlet weak var timeAheadLabel: UILabel!
    
    @IBOutlet weak var tableView:      UITableView!
    
    @IBOutlet weak var adjustTimeBeforeLabel: UILabel!
    @IBOutlet weak var adjustTimeNowLabel: UILabel!
    @IBOutlet weak var adjustTimeAheadLabel: UILabel!
    
    
    // 2/23追加
    @IBAction func adjustTimeBeforeButton(_ sender: Any) {
        
        if cities.isEmpty {
            print("なにもしない")
            return
        }
        
        adjustTimeStat -= 1
        
        print("バフレベル: \(adjustTimeStat)")
        
        var tmpFormat2 = DateFormatter()
        
        // setConfigToFormatter2(fm: &tmpFormat2, cellIdx: 0)

        if pinedCityCell > -1 {
           setConfigToFormatter2(fm: &tmpFormat2, cellIdx: pinedCityCell)
        }
        
        tmpFormat2.dateFormat = "HH:mm"

        let bef30 = 60 * 30 * (adjustTimeStat-1)
        let new   = 60 * 30 * (adjustTimeStat+0)
        let aft30 = 60 * 30 * (adjustTimeStat+1)
        
        let GMT = Date()
        
        let before30m = Date(timeInterval:  TimeInterval(bef30), since: GMT)
        let newtral   = Date(timeInterval:  TimeInterval(new), since: GMT)
        let after30m  = Date(timeInterval:  TimeInterval(aft30), since: GMT)
        
        adjustTimeBeforeLabel.text = tmpFormat2.string(from: before30m)
        adjustTimeNowLabel.text = tmpFormat2.string(from: newtral)
        adjustTimeAheadLabel.text = tmpFormat2.string(from: after30m)
        
        
        timeLabel.text = tmpFormat2.string(from: newtral)
        
        
        //tmpFormat2.dateFormat = "MM/dd YYYY"
        tmpFormat2.dateStyle = .medium
        tmpFormat2.timeStyle = .none
        
        MDYLabel.text = tmpFormat2.string(from: newtral)
        
        
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
    

    @IBAction func adjustTimeAheadButton(_ sender: Any) {
        
        if cities.isEmpty {
            print("なにもしない")
            return
        }
        
        adjustTimeStat += 1
        
        print("バフレベル: \(adjustTimeStat)")
        
        var tmpFormat2 = DateFormatter()
        
        setConfigToFormatter2(fm: &tmpFormat2, cellIdx: pinedCityCell)
        
        tmpFormat2.dateFormat = "HH:mm"
        
        let bef30 = 60 * 30 * (adjustTimeStat-1)
        let new   = 60 * 30 * (adjustTimeStat+0)
        let aft30 = 60 * 30 * (adjustTimeStat+1)
        
        let GMT = Date()
        
        let before30m = Date(timeInterval:  TimeInterval(bef30), since: GMT)
        let newtral   = Date(timeInterval:  TimeInterval(new), since: GMT)
        let after30m  = Date(timeInterval:  TimeInterval(aft30), since: GMT)
        
        adjustTimeBeforeLabel.text = tmpFormat2.string(from: before30m)
        adjustTimeNowLabel.text = tmpFormat2.string(from: newtral)
        adjustTimeAheadLabel.text = tmpFormat2.string(from: after30m)
        
        timeLabel.text = tmpFormat2.string(from: newtral)
        
        
        //tmpFormat2.dateFormat = "MM/dd YYYY"
        tmpFormat2.dateStyle = .medium
        tmpFormat2.timeStyle = .none
        
        MDYLabel.text = tmpFormat2.string(from: newtral)
        
        
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
    

    // GMT標準時刻
    var GMT = Date()
    
    let realm = try! Realm()
    
    /* フォーマッタ */
    var formatter = DateFormatter()
    // 左欄、日付と西暦を表示させるためのフォーマッタ
    var formatter2 = DateFormatter()
    
    var cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)

    
    ////////////////////
    // MARK: Life Cycle
    ////////////////////
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        print("何度でも呼ばれるぜ！！")
        // Realmのパス
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //
        adjustTimeStat = 0
        timeAheadLabel.text = "now"
        //
        GMT = Date()
        
        cities = realm.objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
        
        print("画面2: will appear まさか　こっちのほうが　速いのか！？")

        // フォーマッタの設定
        if !cities.isEmpty {
            setConfigToFormatter(fm: &formatter, cellIdx: 0)
            setConfigToFormatter2(fm: &formatter2, cellIdx: 0)
        }
        
        formatter.dateFormat = "HH:mm"
        
        formatter2.dateStyle = .medium
        formatter2.timeStyle = .none
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        print("画面2: did appear まさか　こっちのほうが　速いのか！？????")
        //
        //tableView.reloadData()
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "pinedCityCell") != nil {
            pinedCityCell = ud.integer(forKey: "pinedCityCell")
            print("データあり！ pinedCityCell は \(pinedCityCell)")
        }
        
        tableView.reloadData()
        
        // ラベルに表示する内容は、 viewWillAppearだと、早すぎる。こっちに書かないとだめ。
        if !cities.isEmpty {
            let pin = "\u{1F4CC} "
            cityNameLabel.text = pin + cities[pinedCityCell].name.uppercased()
        }
        cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        var tmpFormat = DateFormatter()
        
        if !cities.isEmpty {
            setConfigToFormatter2(fm: &tmpFormat, cellIdx: pinedCityCell)
        }
        
        tmpFormat.dateStyle = .medium
        tmpFormat.timeStyle = .none
        
        let GMT = Date()
        let before30m = Date(timeInterval: -60*30, since: GMT)
        let after30m  = Date(timeInterval:  60*30, since: GMT)
        
        if !cities.isEmpty {
            MDYLabel.text = tmpFormat.string(from: GMT)
            MDYLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        }
        
        tmpFormat.dateFormat = "HH:mm"
        
        if !cities.isEmpty {
            timeLabel.text = tmpFormat.string(from: GMT)
            timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        }
        
        // 2/23追記
        if !cities.isEmpty {
            adjustTimeBeforeLabel.text = tmpFormat.string(from: before30m)
            adjustTimeBeforeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
            adjustTimeNowLabel.text = tmpFormat.string(from: GMT)
            adjustTimeNowLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
            adjustTimeAheadLabel.text = tmpFormat.string(from: after30m)
            adjustTimeAheadLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        }
    }
    
    
    // -MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 時間調整がかかっているときのセル表示
        if adjustTimeStat != 0 {
            
            var tmpFormat = DateFormatter()
            
            setConfigToFormatter(fm: &tmpFormat, cellIdx: indexPath.row)
            
            tmpFormat.dateFormat = "HH:mm"
            
            let GMT = Date()
            let new = 60 * 30 * (adjustTimeStat+0)
            
            let newtral = Date(timeInterval:  TimeInterval(new), since: GMT)

//            adjustTimeBeforeLabel.text = tmpFormat.string(from: before30m)
//            adjustTimeNowLabel.text = tmpFormat.string(from: newtral)
//            adjustTimeAheadLabel.text = tmpFormat.string(from: after30m)
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InitialTableViewCell
            
            cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
            cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
//            if indexPath.row == pinedCityCell {
//                let a = "\u{1F4CC} "
//                cell.cityNameLabel.text = a + cities[indexPath.row].name.uppercased()
//            }
            
            cell.timeLabel.text = tmpFormat.string(from: newtral)
            cell.timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
            
//            tmpFormat.dateFormat = "HH:mm"
            tmpFormat.dateStyle = .medium
            tmpFormat.timeStyle = .none
            
            
            cell.yearAndMonthLabel.text = tmpFormat.string(from: newtral)
            cell.yearAndMonthLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
            
            cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
            
            return cell
            
        } // 特別時のセル設定 完了
        
        
        ////////////////////
        // バフデバフ = 0時 //
        ////////////////////
        
        
        // これないと　どんどん　ずれてくから　必要よ。
        //GMT = Date()

        // フォーマッタの初期設定
        setConfigToFormatter(fm: &formatter, cellIdx: indexPath.row)
        setConfigToFormatter2(fm: &formatter2, cellIdx: indexPath.row)
        
        // 1/25追記
        formatter.dateFormat = "HH:mm"
        
        formatter2.dateStyle = .medium
        formatter2.timeStyle = .none
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InitialTableViewCell
        
        
        // 2017/1/25修正
        cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
        cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        cell.yearAndMonthLabel.text = formatter2.string(from: GMT)
        cell.yearAndMonthLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
        
        cell.timeLabel.text = formatter.string(from: GMT)
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
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        
        //fm.timeZone = TimeZone(abbreviation: timeZone)
        fm.timeZone = NSTimeZone(name: timeZone) as TimeZone!
        
        fm.dateFormat = "MM/dd HH:mm"
    }
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter2(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        //fm.timeZone = TimeZone(abbreviation: timeZone)
        fm.timeZone = NSTimeZone(name: timeZone) as TimeZone!
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
        
        let tz = NSTimeZone(name: cities[pinedCityCell].timeZone)
        
        let fm = DateFormatter()
        fm.dateFormat = "yyyy/MM/dd HH:mm:ss"   // "MM/dd HH:mm"
        // なんと、「タイムゾーンを明示的に指定しないとGMT標準時を出力する」という死ぬほどだるかった罠がある。
        // タイムゾーンをきちんと指定しよう
        fm.timeZone = tz as TimeZone!   // ここにバンクーバー(GMT-7)をセットしておけば。。。
        
        let d = fm.string(from: Date())
        
        // これで、ちゃんと、[バンクーバーが 3/12 22:00のときのGMT時間 (= 3/13 5:00)が出力される]
        //let dateFromString = fm.date(from: "2017/3/12 22:00:00")!
        let dateFromString = fm.date(from: d)!
        print("ゴルァ！！ \(dateFromString)")
        
        // ここまで来たらOK.それを ↓ の selecetedDateに渡してあげればよい。
        
        let datePicker = ActionSheetDatePicker(
            title: "Select date.",
            datePickerMode: pickerMode,
            selectedDate: dateFromString as Date!,
            doneBlock: { picker, value, index in
                
                print("value = \(value)"); print("index = \(index)"); print("picker = \(picker)")
                
                self.GMT = value as! Date

                self.tableView.reloadData()
                
                // 後始末　ここも慎重に書かないと即死だぞ
            },
            
            cancel: { ActionStringCancelBlock in return },
            origin: view
        )
        
//        if view.tag == 1 {
//        datePicker?.minimumDate = NSDate(timeInterval: -secondsInWeek, since: NSDate() as Date) as Date!
//        datePicker?.maximumDate = NSDate(timeInterval: secondsInWeek, since: NSDate() as Date) as Date!
//        }
        
        datePicker?.minuteInterval = 1
        
        datePicker?.show()
    }
    
    
//    class DateUtils {
//        class func dateFromString(string: String, format: String) -> NSDate {
//            let formatter: DateFormatter = DateFormatter()
//            //formatter.calendar = NSGregorianCalendar
//            formatter.dateFormat = format
//            return formatter.date(from: string)! as NSDate
//        }
//        
//        class func stringFromDate(date: NSDate, format: String) -> String {
//            let formatter: DateFormatter = DateFormatter()
////            formatter.calendar = gregorianCalendar
//            formatter.dateFormat = format
//            return formatter.string(from: date as Date)
//        }
//    }
}


