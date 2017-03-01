
import UIKit
import RealmSwift

class InitialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // ピンされた都市のID
    // -1 = isSelectedな都市が1件もなく、テーブルセルが一行もない状態
    var pinedCityCell = -1

    // タイム調整バフ・デバフ
    var adjustTimeStat = 0
    
    
    /* UI Components */
    @IBOutlet weak var cityNameLabel:  UILabel!
    @IBOutlet weak var MDYLabel:       UILabel!
    @IBOutlet weak var timeLabel:      UILabel!
    @IBOutlet weak var timeAheadLabel: UILabel!
    
    @IBOutlet weak var tableView:      UITableView!
    
    
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

        let bef30 = (60 * 30 * (adjustTimeStat-1))
        let new   = (60 * 30 * (adjustTimeStat+0))
        let aft30 = (60 * 30 * (adjustTimeStat+1))
        
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
    
    @IBOutlet weak var adjustTimeBeforeLabel: UILabel!
    @IBOutlet weak var adjustTimeNowLabel: UILabel!
    @IBOutlet weak var adjustTimeAheadLabel: UILabel!

    @IBAction func adjustTimeAheadButton(_ sender: Any) {
        
        if cities.isEmpty {
            print("なにもしない")
            return
        }
        
        adjustTimeStat += 1
        
        print("バフレベル: \(adjustTimeStat)")
        
        var tmpFormat2 = DateFormatter()
        
        setConfigToFormatter2(fm: &tmpFormat2, cellIdx: 0)
        
        tmpFormat2.dateFormat = "HH:mm"
        
        let bef30 = (60 * 30 * (adjustTimeStat-1))
        let new   = (60 * 30 * (adjustTimeStat+0))
        let aft30 = (60 * 30 * (adjustTimeStat+1))
        
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
    
    
    // 全都市リスト --> ユーザーにより追加された都市のみ抽出
//    let cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "id", ascending: true)

    var cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)

    
    // 昔、ここにボタンがあったときは、こんなメソッドをセットしていました...
//    @IBAction func LaunchTabVC(_ sender: AnyObject) {
//        let nex = self.storyboard!.instantiateViewController(withIdentifier: "TabBar")
//        self.present(nex, animated: true, completion: nil)
//    }
    
    // ステータスバーの表示 / 非表示 の切り替え
//    override var prefersStatusBarHidden: Bool {
//        //return true
//        return false
//    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        print("何度でも呼ばれるぜ！！")
        //

        // Realmのパス
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
        // 編集ボタンを左上に配置
        //navigationItem.leftBarButtonItem = editButtonItem
        
//        // フォーマッタの設定
//        setConfigToFormatter(fm: &formatter, cellIdx: 0)
//        setConfigToFormatter2(fm: &formatter2, cellIdx: 0)
//        
//        formatter.dateFormat = "HH:mm"
//        
//        formatter2.dateStyle = .medium
//        formatter2.timeStyle = .none
        
        
        // 初回起動時のみ
        //if cities.count == 0 {
            //print("初回起動だと 判定された！！！")
            //initialEnrollCities()
        //}
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //
        adjustTimeStat = 0
        timeAheadLabel.text = "now"
        //
        GMT = Date()
        
        cities = realm.objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
        
//        let ud = UserDefaults.standard
//        if ud.object(forKey: "pinedCityCell") != nil {
//            pinedCityCell = ud.integer(forKey: "pinedCityCell")
//            print("データあり！ pinedCityCell は \(pinedCityCell)")
//        }
        
        print("画面2: will appear まさか　こっちのほうが　速いのか！？")

        // tableView.reloadData()
        
        
        // フォーマッタの設定
        if !cities.isEmpty {
            setConfigToFormatter(fm: &formatter, cellIdx: 0)
            setConfigToFormatter2(fm: &formatter2, cellIdx: 0)
        }
        
        formatter.dateFormat = "HH:mm"
        
        formatter2.dateStyle = .medium
        formatter2.timeStyle = .none
        

        if !cities.isEmpty {
            
            print("フォーマットしろや")
            
            // cityNameLabel.text = cities[pinedCityCell].name.uppercased()
            
            //cityNameLabel.text = cities[0].name.uppercased()
//            cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
//            
//            var tmpFormat = DateFormatter()
//            setConfigToFormatter2(fm: &tmpFormat, cellIdx: 0)
//            tmpFormat.dateStyle = .medium
//            tmpFormat.timeStyle = .none
//            
//            let GMT = Date()
//            let before30m = Date(timeInterval: -60*30, since: GMT)
//            let after30m  = Date(timeInterval:  60*30, since: GMT)
//            
//            MDYLabel.text = tmpFormat.string(from: GMT)
//            MDYLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
//            
//            tmpFormat.dateFormat = "HH:mm"
//            
//            timeLabel.text = tmpFormat.string(from: GMT)
//            timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
//            
//            // 2/23追記
//            
//            adjustTimeBeforeLabel.text = tmpFormat.string(from: before30m)
//            adjustTimeBeforeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
//            
//            adjustTimeNowLabel.text = tmpFormat.string(from: GMT)
//            adjustTimeNowLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
//            
//            adjustTimeAheadLabel.text = tmpFormat.string(from: after30m)
//            adjustTimeAheadLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        }
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("画面2: did appear まさか　こっちのほうが　速いのか！？????")
        //
        tableView.reloadData()
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "pinedCityCell") != nil {
            pinedCityCell = ud.integer(forKey: "pinedCityCell")
            print("データあり！ pinedCityCell は \(pinedCityCell)")
        }
        
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
    
    // テーブルを編集可能にするメソッド
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        
//        super.setEditing(editing, animated: animated)
//        //tableView.isEditing = editing
//        tableView.isEditing = false
//    }
    
    
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
            
            let newtral   = Date(timeInterval:  TimeInterval(new), since: GMT)

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
        
        // これないと　どんどん　ずれてくから　必要よ。
        GMT = Date()

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
        
//        if indexPath.row == pinedCityCell {
//            let a = "\u{1F4CC} "
//            cell.cityNameLabel.text = a + cities[indexPath.row].name.uppercased()
//        }
        
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
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        fm.timeZone = TimeZone(abbreviation: timeZone)
        
        fm.dateFormat = "MM/dd HH:mm"
    }
    
    // フォーマッタの初期設定
    func setConfigToFormatter2(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        fm.timeZone = TimeZone(abbreviation: timeZone)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    // -MARK: Initial Setting
    
    // 初回アプリ起動時に1回のみ、すべての都市をデータベースに登録
//    func initialEnrollCities() {
//        
//        let citySeed = [
//            (name: "Vancouver", timeZone: "PST"),
//            (name: "Tokyo",     timeZone: "JST"),
//            (name: "Venice",    timeZone: "CET"),
//            (name: "London",    timeZone: "GMT"),
//            //
//            (name: "A", timeZone: "PST"),
//            (name: "B",     timeZone: "JST"),
//            (name: "C",    timeZone: "CET"),
//            (name: "D",    timeZone: "GMT"),
//            (name: "E", timeZone: "PST"),
//            (name: "F",     timeZone: "JST"),
//            (name: "G",    timeZone: "CET"),
//            (name: "H", timeZone: "PST"),
//            (name: "I",     timeZone: "JST"),
//            (name: "J",    timeZone: "CET"),
//            (name: "K",    timeZone: "GMT"),
//            (name: "L", timeZone: "PST"),
//            (name: "M",     timeZone: "JST"),
//            (name: "N",    timeZone: "CET"),
//            // O, P
//            (name: "Q",    timeZone: "GMT"),
//            // R
//            (name: "S", timeZone: "PST"),
//            (name: "T",     timeZone: "JST"),
//            (name: "U",    timeZone: "CET"),
//            (name: "V",    timeZone: "GMT"),
//            (name: "W", timeZone: "PST"),
//            (name: "X",     timeZone: "JST"),
//            (name: "Y",    timeZone: "CET"),
//            (name: "Z",    timeZone: "GMT"),
//            
//            
//        ]
//        
//        var cities: [StoredCity] = []
//        
//        for (idx, value) in citySeed.enumerated() {
//            cities.append(StoredCity(id: idx, name: value.name, timeZone: value.timeZone, isSelected: false))
//        }
//        
//        try! realm.write {
//            for city in cities {
//                self.realm.add(city, update: true)
//                print("\(city.name) was saved!")
//            }
//        }
//    }
}




