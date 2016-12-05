
import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    // GMT標準時刻
    let GMT = Date()
    
    
    let realm = try! Realm()
    
    let cities = try! Realm().objects(StoredCity.self).filter("isSelected == true").sorted(byProperty: "id", ascending: true)
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //
        tableView.delegate = self
        tableView.dataSource = self
        
        // 編集ボタンを左上に配置
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        // 初回起動時のみ
        if try! Realm().objects(StoredCity.self).count == 0 {
        
            print("初回起動だと 判定された！！！")
            
            initialEnrollCities()
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //
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
        
        // フォーマッタの初期設定
        setConfigToFormatter(fm: &formatter, cellIdx: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        cell.cityNameLabel.text = cities[indexPath.row].name
        cell.timeLabel.text = formatter.string(from: GMT)
        
        if indexPath.row % 2 == 0 {
        
            cell.backgroundColor = UIColor(hue: 0.61, saturation: 0.09, brightness: 0.99, alpha: 1.0)
            
        } else {
            cell.backgroundColor = UIColor.cyan
        }
        
        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {

//        return .delete
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
    
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // 初回アプリ起動時に1回のみ、すべての都市をデータベースに登録
    func initialEnrollCities() {
        
        let citySeed = [
            (name: "Vancouver", timeZone: "PST"),
            (name: "Tokyo",     timeZone: "JST"),
            (name: "Venice",    timeZone: "CET"),
            (name: "London",    timeZone: "GMT")
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













