
import UIKit
import Realm


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 逆流してくる値
    var reverseStr: String?
    
    
    // GMT標準時刻
    let GMT: Date = Date()
    
    let cities = [City(name: "Vancouver", timeZone: "PST"),
                  City(name: "Tokyo",     timeZone: "JST"),
                  City(name: "Venice",    timeZone: "CET"),
                  City(name: "London",    timeZone: "GMT"),
                  ]
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
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
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
        
        // タイムゾーン
        let timeZone = cities[cellIdx].timeZone
        
        fm.dateFormat = "MM/dd HH:mm"
        
        fm.timeZone = TimeZone(abbreviation: timeZone)
        
    }
    
    
    func modalDidFinished(modalText: String){
        
        self.reverseStr = modalText
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
        
}













