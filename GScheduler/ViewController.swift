
import UIKit
import RealmSwift


extension UILabel {
    func kern(kerningValue:CGFloat) {
        self.attributedText =  NSAttributedString(string: self.text ?? "", attributes: [NSKernAttributeName:kerningValue, NSFontAttributeName:font, NSForegroundColorAttributeName:self.textColor])
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // GMT標準時刻
    var GMT = Date()
    
    let realm = try! Realm()
//    let cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "id", ascending: true)

    var cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
    
    // ピンされたcityのセル番号
    var pinedCityCell = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "cityTable")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        //
        tableView.delegate = self
        tableView.dataSource = self
        //
        //tabBarController?.tabBar.delegate = self
        
        // 編集ボタンを左上に配置
//        if cities.count > 0 {
            navigationItem.leftBarButtonItem = editButtonItem
//        }
        
        // 初回起動時のみ
        if cities.count == 0 {
            print("初回起動だと 判定された！！！")
            initialEnrollCities()
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        GMT = Date()
        
        cities = realm.objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "orderNo", ascending: true)
        
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        //
        // ビュー消滅時、編集モードを解除しているけど、ボタンの設定が解除されない
        tableView.isEditing = false
        
        print("画面1: will disappear")
        
//        // 現在の ピンされた都市を保存
        let ud = UserDefaults.standard
        ud.set(pinedCityCell, forKey: "pinedCityCell")
        ud.synchronize()
        print("シンクロしました")
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        tableView.isEditing = editing
        
        for cell in tableView.visibleCells {
            if tableView.isEditing {
                (cell as! TableViewCell).timeLabel.isHidden = true
            } else {
                (cell as! TableViewCell).timeLabel.isHidden = false
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var formatter = DateFormatter()
        // 左欄、日付と西暦を表示させるためのフォーマッタ
        var formatter2 = DateFormatter()
        
        // フォーマッタの初期設定
        setConfigToFormatter(fm: &formatter, cellIdx: indexPath.row)
        setConfigToFormatter2(fm: &formatter2, cellIdx: indexPath.row)

        // 1/25追記
        formatter.dateFormat = "HH:mm"
        
        formatter2.dateStyle = .medium
        formatter2.timeStyle = .none
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
//        cell.cityNameLabel.text = cities[indexPath.row].name
//        cell.timeLabel.text = formatter.string(from: GMT)
        
        
        // 2017/1/25修正
        cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
        cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        
        if indexPath.row == pinedCityCell {
            let a = "\u{1F4CC} "
            cell.cityNameLabel.text = a + cities[indexPath.row].name.uppercased()
        }
        
        
        cell.DayYearLabel.text  = formatter2.string(from: GMT)
        cell.DayYearLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
        
        cell.timeLabel.text     = formatter.string(from: GMT)
        cell.timeLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        cell.timeLabel.kern(kerningValue: 2)

        
        
        if indexPath.row % 2 == 0 {
//            cell.backgroundColor = UIColor(hue: 0.61, saturation: 0.09, brightness: 0.99, alpha: 1.0)
            cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        } else {
//            cell.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        }
        
        if isEditing == true {
            cell.timeLabel.isHidden = true
        } else {
            cell.timeLabel.isHidden = false
        }

        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if indexPath.row == pinedCityCell {
//            
//            // パターン1: モーダル遷移なので、ナビゲーションバーがない
////            let storyboard = UIStoryboard(name: "Main", bundle: nil)
////            let controller = storyboard.instantiateViewController(withIdentifier: "setTime")
////            self.present(controller, animated: true, completion: nil)
////            return
//            
//            // パターン2: delegateセットするとこで落ちる
//            
//            //let second = InitialViewController()
//            //second.modalTransitionStyle = .crossDissolve
//            // 変数に任意の値を渡せる
//            //second.myMessasge = "トップ画面からの遷移"
//            // 画像データも渡せるので、撮影した画像をアルバムに保存しなくて良い
//            //second.myImage = UIImage(...)
//            // 遷移履歴に追加する形で画面遷移
//            //navigationController?.pushViewController(second as UIViewController, animated: true)
//            
//            // パターン3: セグだからそもそも無理
//            // self.performSegue(withIdentifier: "setTime", sender: nil)
//
//            
//            // アニメで遷移したいときは、この6行をカットインしろ
////            let view = tabBarController?.view.subviews[0]
////            UIView.beginAnimations(nil, context: nil)
////            UIView.setAnimationDuration(0.75)
////            UIView.setAnimationCurve(.easeInOut)
////            UIView.setAnimationTransition(.flipFromRight, for: view!, cache: true)
////            UIView.commitAnimations()
        
//        print("")
//
//            
//            // 現在の ピンされた都市を保存
//            let ud = UserDefaults.standard
//            ud.set(pinedCityCell, forKey: "pinedCityCell")
//            ud.synchronize()
//            
//            // 遷移したければ　これコメントインして
//            // self.tabBarController?.selectedIndex = 1
//            
//            return
//        }
//        

        // ピン都市を更新
        pinedCityCell = indexPath.row
        
        tableView.reloadData()
    }
    
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {

        print("きたきた")
        
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
    
    // セルの並び替えが発動した時の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath == destinationIndexPath {
            print("とんだ罠だったな")
            return
        }
        
        try! realm.write {
            
            print("ターゲットのセル: \(sourceIndexPath.row)")
            print("移動先: \(destinationIndexPath.row)")
            
            let indexFrom = sourceIndexPath.row
            let indexTo   = destinationIndexPath.row
            
            for city in cities {
                
                // case1: from > to(上に行く場合)
                if indexFrom > indexTo {
                    
                    // なにも処理せず次のセルの判定へ
                    if indexFrom < city.orderNo {
                        print("\(city.name)はスルーで。")
                        continue
                    }
                    
                    // もうひとつ、
                    if city.orderNo < indexTo {
                        print("\(city.name)はスルーで。")
                        continue
                    }
                    
                }
                
                // case2: from < to(下に行く場合)
                if indexFrom < indexTo {
                    // なにも処理せず次のセルの判定へ
                    if indexFrom > city.orderNo {
                        print("\(city.name)はスルーで。")
                        continue
                    }
                    
                    // もうひとつ、
                    if indexTo < city.orderNo {
                        print("\(city.name)はスルーで。")
                        continue
                    }

                }
                
                let tmp = city.orderNo
                
                if city.orderNo < indexFrom {
                    city.orderNo += 1
                } else if city.orderNo > indexFrom {
                    city.orderNo -= 1
                } else if city.orderNo == indexFrom {
                    city.orderNo = indexTo
                }
                
                print("\(city.name)は、\(tmp)から \(city.orderNo)に 移動しました")
            }
            
            // 文字のピンを再設定するためだ、致し方ない。。
            tableView.reloadData()
        }
    }
    
    
    // セルをdeleteするときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            try! realm.write {
                
                for city in cities {
                    
                    if city.orderNo < indexPath.row {
                        // 何もなし
                        print("\(city.name)は なにもなし！")
                    } else if city.orderNo > indexPath.row {
                        city.orderNo -= 1
                        print("\(city.name)の orderNoが \(city.orderNo)に なった！")
                    } else if city.orderNo == indexPath.row {
                        city.orderNo = -1
                        city.isSelected = false
                        print("\(city.name)が 削除！")
                    }
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        fm.dateFormat = "MM/dd HH:mm"
        
        fm.timeZone =  NSTimeZone(name: timeZone) as TimeZone!
    }
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter2(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        //fm.dateFormat = "YYYY / MM / dd"
        
        fm.timeZone =  NSTimeZone(name: timeZone) as TimeZone!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func initialEnrollCities() {
        
        var citiesAry: [StoredCity] = []
        
        let csvFilePath = Bundle.main.path(forResource: "CityNameSeed", ofType: "csv")
        
        let csvStringData = try! String(contentsOfFile: csvFilePath!, encoding: String.Encoding.utf8)
        
        var id = 0
        
        // csvを1行ずつ読み込む
        csvStringData.enumerateLines(invoking: { (line, stop) -> () in
            
            // カンマ区切りで分割
            let cityDataArray = line.components(separatedBy: ",")
            citiesAry.append(
                StoredCity(id: id, name: cityDataArray[0], timeZone: cityDataArray[1], isSelected: false)
            )
            id += 1
            
        })
        
        print("はいはいおわり！")
        print(citiesAry)
        
        try! realm.write {
            for city in citiesAry {
                self.realm.add(city, update: true)
                print("\(city.name)")
            }
        }
        
        // 都市の初期設定(いくつかの都市をあらかじめプリセット)
        setInitCities()
        
        
    } // 初期化処理
    
    func setInitCities() {

        try! realm.write {
            
            var dynamicOrderNo = 0
            
            var localTimeZoneName: String {
                return TimeZone.current.identifier
            }
            
            // 端末の現在位置の都市のID
            let currentCityID = realm.objects(StoredCity.self).filter("timeZone == '\(localTimeZoneName)'").first?.id
            
            // 端末のタイムゾーンをもとにしたプリセット
            if let currentCityID = currentCityID {
                realm.create(StoredCity.self, value: ["id": currentCityID, "isSelected": true, "orderNo": dynamicOrderNo], update: true)
                    dynamicOrderNo += 1
            }
            
            if currentCityID != 201 {
                // 東京
                realm.create(StoredCity.self, value: ["id": 201, "isSelected": true, "orderNo": dynamicOrderNo], update: true)
                dynamicOrderNo += 1
            }
            
            if currentCityID != 202 {
                // ナイロビ
                realm.create(StoredCity.self, value: ["id": 202, "isSelected": true, "orderNo": dynamicOrderNo], update: true)
                dynamicOrderNo += 1
            }
            
            if currentCityID != 108 {
                // バンクーバー
                realm.create(StoredCity.self, value: ["id": 108, "isSelected": true, "orderNo": dynamicOrderNo], update: true)
            }
        }
    }
} // class







