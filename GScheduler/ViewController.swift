
import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    // GMT標準時刻
    let GMT: Date = Date()
    
    //let cities = [City(name: "Vancouver", timeZone: "PST"),
//                  City(name: "Tokyo",     timeZone: "JST"),
//                  City(name: "Venice",    timeZone: "CET"),
//                  City(name: "London",    timeZone: "GMT"),
//                  ]
    
    
    let realm = try! Realm()
    
    let cities = try! Realm().objects(StoredCity.self).sorted(byProperty: "id", ascending: true)
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //
        tableView.reloadData()
        
        print(cities)
        
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
        return .delete
    }
    
    
    // セルをdeleteするときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.cities[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
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
        return 150
    }
        
}













