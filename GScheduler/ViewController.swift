
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
        
//        let vc = CityListTableViewController()
        let vc = storyboard?.instantiateViewController(withIdentifier: "cityTable")
            

        self.present(vc!, animated: true, completion: nil)

        
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad( )
        //
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
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
        //
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
        
        print("hoge---")
        
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
            
            for cell in tableView.visibleCells {
                (cell as! TableViewCell).timeLabel.isHidden = false
            }
            
            
            
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
        
        print("はいはいおわり！　結果は")
        print(citiesAry)
        
        try! realm.write {
            for city in citiesAry {
                self.realm.add(city, update: true)
                print("\(city.name) was saved!")
            }
        }
        
    } // 初期化処理
    
        
//        let IANAtimeZones = ["GMT","Europe/Andorra","Asia/Dubai","Asia/Kabul","America/Antigua","America/Anguilla","Europe/Tirane","Asia/Yerevan","Africa/Luanda","Antarctica/McMurdo","Antarctica/Rothera","Antarctica/Palmer","Antarctica/Mawson","Antarctica/Davis","Antarctica/Casey","Antarctica/Vostok","Antarctica/DumontDUrville","Antarctica/Syowa","Antarctica/Troll","America/Argentina/Buenos_Aires","America/Argentina/Cordoba","America/Argentina/Salta","America/Argentina/Jujuy","America/Argentina/Tucuman","America/Argentina/Catamarca","America/Argentina/La_Rioja","America/Argentina/San_Juan","America/Argentina/Mendoza","America/Argentina/San_Luis","America/Argentina/Rio_Gallegos","America/Argentina/Ushuaia","Pacific/Pago_Pago","Europe/Vienna","Australia/Lord_Howe","Antarctica/Macquarie","Australia/Hobart","Australia/Currie","Australia/Melbourne","Australia/Sydney","Australia/Broken_Hill","Australia/Brisbane","Australia/Lindeman","Australia/Adelaide","Australia/Darwin","Australia/Perth","Australia/Eucla","America/Aruba","Europe/Mariehamn","Asia/Baku","Europe/Sarajevo","America/Barbados","Asia/Dhaka","Europe/Brussels","Africa/Ouagadougou","Europe/Sofia","Asia/Bahrain","Africa/Bujumbura","Africa/Porto-Novo","America/St_Barthelemy","Atlantic/Bermuda","Asia/Brunei","America/La_Paz","America/Kralendijk","America/Noronha","America/Belem","America/Fortaleza","America/Recife","America/Araguaina","America/Maceio","America/Bahia","America/Sao_Paulo","America/Campo_Grande","America/Cuiaba","America/Santarem","America/Porto_Velho","America/Boa_Vista","America/Manaus","America/Eirunepe","America/Rio_Branco","America/Nassau","Asia/Thimphu","Africa/Gaborone","Europe/Minsk","America/Belize","America/St_Johns","America/Halifax","America/Glace_Bay","America/Moncton","America/Goose_Bay","America/Blanc-Sablon","America/Toronto","America/Nipigon","America/Thunder_Bay","America/Iqaluit","America/Pangnirtung","America/Resolute","America/Atikokan","America/Rankin_Inlet","America/Winnipeg","America/Rainy_River","America/Regina","America/Swift_Current","America/Edmonton","America/Cambridge_Bay","America/Yellowknife","America/Inuvik","America/Creston","America/Dawson_Creek","America/Fort_Nelson","America/Vancouver","America/Whitehorse","America/Dawson","Indian/Cocos","Africa/Kinshasa","Africa/Lubumbashi","Africa/Bangui","Africa/Brazzaville","Europe/Zurich","Africa/Abidjan","Pacific/Rarotonga","America/Santiago","Pacific/Easter","Africa/Douala","Asia/Shanghai","Asia/Urumqi","America/Bogota","America/Costa_Rica","America/Havana","Atlantic/Cape_Verde","America/Curacao","Indian/Christmas","Asia/Nicosia","Europe/Prague","Europe/Berlin","Europe/Busingen","Africa/Djibouti","Europe/Copenhagen","America/Dominica","America/Santo_Domingo","Africa/Algiers","America/Guayaquil","Pacific/Galapagos","Europe/Tallinn","Africa/Cairo","Africa/El_Aaiun","Africa/Asmara","Europe/Madrid","Africa/Ceuta","Atlantic/Canary","Africa/Addis_Ababa","Europe/Helsinki","Pacific/Fiji","Atlantic/Stanley","Pacific/Chuuk","Pacific/Pohnpei","Pacific/Kosrae","Atlantic/Faroe","Europe/Paris","Africa/Libreville","Europe/London","America/Grenada","Asia/Tbilisi","America/Cayenne","Europe/Guernsey","Africa/Accra","Europe/Gibraltar","America/Godthab","America/Danmarkshavn","America/Scoresbysund","America/Thule","Africa/Banjul","Africa/Conakry","America/Guadeloupe","Africa/Malabo","Europe/Athens","Atlantic/South_Georgia","America/Guatemala","Pacific/Guam","Africa/Bissau","America/Guyana","Asia/Hong_Kong","America/Tegucigalpa","Europe/Zagreb","America/Port-au-Prince","Europe/Budapest","Asia/Jakarta","Asia/Pontianak","Asia/Makassar","Asia/Jayapura","Europe/Dublin","Asia/Jerusalem","Europe/Isle_of_Man","Asia/Kolkata","Indian/Chagos","Asia/Baghdad","Asia/Tehran","Atlantic/Reykjavik","Europe/Rome","Europe/Jersey","America/Jamaica","Asia/Amman","Asia/Tokyo","Africa/Nairobi","Asia/Bishkek","Asia/Phnom_Penh","Pacific/Tarawa","Pacific/Enderbury","Pacific/Kiritimati","Indian/Comoro","America/St_Kitts","Asia/Pyongyang","Asia/Seoul","Asia/Kuwait","America/Cayman","Asia/Almaty","Asia/Qyzylorda","Asia/Aqtobe","Asia/Aqtau","Asia/Oral","Asia/Vientiane","Asia/Beirut","America/St_Lucia","Europe/Vaduz","Asia/Colombo","Africa/Monrovia","Africa/Maseru","Europe/Vilnius","Europe/Luxembourg","Europe/Riga","Africa/Tripoli","Africa/Casablanca","Europe/Monaco","Europe/Chisinau","Europe/Podgorica","America/Marigot","Indian/Antananarivo","Pacific/Majuro","Pacific/Kwajalein","Europe/Skopje","Africa/Bamako","Asia/Rangoon","Asia/Ulaanbaatar","Asia/Hovd","Asia/Choibalsan","Asia/Macau","Pacific/Saipan","America/Martinique","Africa/Nouakchott","America/Montserrat","Europe/Malta","Indian/Mauritius","Indian/Maldives","Africa/Blantyre","America/Mexico_City","America/Cancun","America/Merida","America/Monterrey","America/Matamoros","America/Mazatlan","America/Chihuahua","America/Ojinaga","America/Hermosillo","America/Tijuana","America/Bahia_Banderas","Asia/Kuala_Lumpur","Asia/Kuching","Africa/Maputo","Africa/Windhoek","Pacific/Noumea","Africa/Niamey","Pacific/Norfolk","Africa/Lagos","America/Managua","Europe/Amsterdam","Europe/Oslo","Asia/Kathmandu","Pacific/Nauru","Pacific/Niue","Pacific/Auckland","Pacific/Chatham","Asia/Muscat","America/Panama","America/Lima","Pacific/Tahiti","Pacific/Marquesas","Pacific/Gambier","Pacific/Port_Moresby","Pacific/Bougainville","Asia/Manila","Asia/Karachi","Europe/Warsaw","America/Miquelon","Pacific/Pitcairn","America/Puerto_Rico","Asia/Gaza","Asia/Hebron","Europe/Lisbon","Atlantic/Madeira","Atlantic/Azores","Pacific/Palau","America/Asuncion","Asia/Qatar","Indian/Reunion","Europe/Bucharest","Europe/Belgrade","Europe/Kaliningrad","Europe/Moscow","Europe/Simferopol","Europe/Volgograd","Europe/Samara","Asia/Yekaterinburg","Asia/Omsk","Asia/Novosibirsk","Asia/Novokuznetsk","Asia/Krasnoyarsk","Asia/Irkutsk","Asia/Chita","Asia/Yakutsk","Asia/Khandyga","Asia/Vladivostok","Asia/Sakhalin","Asia/Ust-Nera","Asia/Magadan","Asia/Srednekolymsk","Asia/Kamchatka","Asia/Anadyr","Africa/Kigali","Asia/Riyadh","Pacific/Guadalcanal","Indian/Mahe","Africa/Khartoum","Europe/Stockholm","Asia/Singapore","Atlantic/St_Helena","Europe/Ljubljana","Arctic/Longyearbyen","Europe/Bratislava","Africa/Freetown","Europe/San_Marino","Africa/Dakar","Africa/Mogadishu","America/Paramaribo","Africa/Juba","Africa/Sao_Tome","America/El_Salvador","America/Lower_Princes","Asia/Damascus","Africa/Mbabane","America/Grand_Turk","Africa/Ndjamena","Indian/Kerguelen","Africa/Lome","Asia/Bangkok","Asia/Dushanbe","Pacific/Fakaofo","Asia/Dili","Asia/Ashgabat","Africa/Tunis","Pacific/Tongatapu","Europe/Istanbul","America/Port_of_Spain","Pacific/Funafuti","Asia/Taipei","Africa/Dar_es_Salaam","Europe/Kiev","Europe/Uzhgorod","Europe/Zaporozhye","Africa/Kampala","Pacific/Johnston","Pacific/Midway","Pacific/Wake","America/New_York","America/Detroit","America/Kentucky/Louisville","America/Kentucky/Monticello","America/Indiana/Indianapolis","America/Indiana/Vincennes","America/Indiana/Winamac","America/Indiana/Marengo","America/Indiana/Petersburg","America/Indiana/Vevay","America/Chicago","America/Indiana/Tell_City","America/Indiana/Knox","America/Menominee","America/North_Dakota/Center","America/North_Dakota/New_Salem","America/North_Dakota/Beulah","America/Denver","America/Boise","America/Phoenix","America/Los_Angeles","America/Anchorage","America/Juneau","America/Sitka","America/Metlakatla","America/Yakutat","America/Nome","America/Adak","Pacific/Honolulu","America/Montevideo","Asia/Samarkand","Asia/Tashkent","Europe/Vatican","America/St_Vincent","America/Caracas","America/Tortola","America/St_Thomas","Asia/Ho_Chi_Minh","Pacific/Efate","Pacific/Wallis","Pacific/Apia","Asia/Aden","Indian/Mayotte","Africa/Johannesburg","Africa/Lusaka","Africa/Harare","Pacific/Truk","Pacific/Ponape","America/Montreal","Asia/Chongqing"]
        
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
//            (name: "Z",    timeZone: "GMT")
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
//   } // 初期化関数()の終了
} // class



