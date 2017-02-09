
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
    let cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byKeyPath: "id", ascending: true)
    
    
    // 次の画面から逆流してくる、選択された都市名
    var selectedCity: StoredCity? = nil
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        
        tableView.delegate = self
        tableView.dataSource = self
        
        // 編集ボタンを左上に配置
        navigationItem.leftBarButtonItem = editButtonItem
        //        
        
        // 初回起動時のみ
        if try! Realm().objects(StoredCity.self).count == 0 {
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
        tableView.reloadData()
        print(cities)
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
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
        cell.cityNameLabel.text = cities[indexPath.row].name
        cell.DayYearLabel.text  = formatter2.string(from: GMT)
        cell.timeLabel.text     = formatter.string(from: GMT)
        
        cell.timeLabel.kern(kerningValue: 2)

        
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(hue: 0.61, saturation: 0.09, brightness: 0.99, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nex = self.storyboard!.instantiateViewController(withIdentifier: "Initial")
        self.present(nex, animated: true, completion: nil)
        
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("こんにちは")
        
    }
    
    
    // セルをdeleteするときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let delatingCity = cities[indexPath.row]
            
            //
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
        fm.dateFormat = "MM/dd HH:mm"
        fm.timeZone = TimeZone(abbreviation: timeZone)
    }
    
    // フォーマッタの初期設定
    func setConfigToFormatter2(fm: inout DateFormatter, cellIdx: Int) {
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        //fm.dateFormat = "YYYY / MM / dd"
        fm.timeZone = TimeZone(abbreviation: timeZone)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // 初回アプリ起動時に1回のみ、すべての都市をデータベースに登録
    func initialEnrollCities() {
        
        let citySeed = [
            (name: "Vancouver", timeZone: "PST"),
            (name: "Tokyo",     timeZone: "JST"),
            (name: "Venice",    timeZone: "CET"),
            (name: "London",    timeZone: "GMT"),
            //
            (name: "Vuver", timeZone: "PST"),
            (name: "Tofdfkyo",     timeZone: "JST"),
            (name: "Venfasdice",    timeZone: "CET"),
            (name: "Longsfadon",    timeZone: "GMT"),
            (name: "Vafgfsdancouver", timeZone: "PST"),
            (name: "Tofaskyo",     timeZone: "JST"),
            (name: "Vengsice",    timeZone: "CET"),
            (name: "Lon  svggsdfdon",    timeZone: "GMT"),
            (name: "Vansdscouver", timeZone: "PST"),
            (name: "Tosgrekyo",     timeZone: "JST"),
            (name: "Vegsfnice",    timeZone: "CET"),
            (name: "Lovndon",    timeZone: "GMT"),
            (name: "V456ancouver", timeZone: "PST"),
            (name: "To56vkyo",     timeZone: "JST"),
            (name: "Vevegfdvnice",    timeZone: "CET"),
            (name: "Losaghvwendon",    timeZone: "GMT")
        ]
        
        var cities: [StoredCity] = []
        
        for (idx, value) in citySeed.enumerated() {
            
            cities.append(StoredCity(id: idx, name: value.name, timeZone: value.timeZone))
            
        }
        
        try! realm.write {
            
            for city in cities {
                self.realm.add(city, update: true)
                print("\(city.name) was saved!")
            }
        }
    }
}



