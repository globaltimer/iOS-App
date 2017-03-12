
import UIKit
import RealmSwift

class CityListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
        
    let realm = try! Realm()
    
    let cities = try! Realm().objects(StoredCity.self).sorted(byKeyPath: "name", ascending: true)
    var filteredCities: [StoredCity] = []
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        print("un")
        //
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        searchBar.barTintColor = UIColor(red:0.14, green:0.68, blue:0.73, alpha:1.0)
        
        for subView in searchBar.subviews {
            for secondSubView in subView.subviews {
                if secondSubView.isKind(of: UITextField.self) {
                    secondSubView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0).withAlphaComponent(1)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NeoCell
        
        // リアルタイムサーチ時の挙動
        if (searchBar.text?.characters.count)! > 0 {
            
            cell.cityNameLabel.text = filteredCities[indexPath.row].name
            
            let fmt = DateFormatter()
            
            let timeZone = filteredCities[indexPath.row].timeZone
            fmt.dateFormat = "ZZZZ"
            //fmt.timeZone = TimeZone(abbreviation: timeZone)
            fmt.timeZone = NSTimeZone(name: timeZone) as TimeZone!
            
            
            cell.diffGMTLabel.text = fmt.string(from: Date())
            
            if cell.diffGMTLabel.text == "GMT" {
                cell.diffGMTLabel.text = "GMT ±00:00"
            }

            return cell
        }
        
        
        let head_character = sections[indexPath.section]
        
        print("都市のインデックスは、\(head_character)")
        
        let cities = self.cities.filter("name BEGINSWITH '\(head_character)'")
        
        
        cell.cityNameLabel.text =  cities[indexPath.row].name
        cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        ////
        var formatter = DateFormatter()
        
        // フォーマッタの初期設定
        func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
            // タイムゾーン
            
            let timeZone = cities[cellIdx].timeZone
            fm.dateFormat = "ZZZZ"
            
            // 3/1 修正！！
            // fm.timeZone = TimeZone(abbreviation: timeZone)
            fm.timeZone = NSTimeZone(name: timeZone) as TimeZone!
        }
        
        setConfigToFormatter(fm: &formatter, cellIdx: indexPath.row)
        
        
        let boke = formatter.string(from: Date())
        
        cell.diffGMTLabel.text = boke
        
        if boke == "GMT" {
            cell.diffGMTLabel.text = "GMT ±00:00"
        }
        
        cell.diffGMTLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
        
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        try! realm.write {
            
            if (searchBar.text?.characters.count)! == 0 {
                
                let selectedCN = ((tableView.cellForRow(at: indexPath)) as! NeoCell).cityNameLabel.text
                
                let selectedCityName = selectedCN!
                
                print("タッチされた都市名はーーー、\(selectedCityName)")
                
                let tmp_id = realm.objects(StoredCity.self).filter("name == '\(selectedCityName)'").first?.id
                
                let id = tmp_id!
                
                print("タッチされた都市名のIDはーーー、\(id)")
                
                let orderNo: Int
                
                // もしまだユーザーによってaddされていなければ、orderNo付与
                if realm.object(ofType: StoredCity.self, forPrimaryKey: id)?.orderNo == -1 {
                    orderNo = realm.objects(StoredCity.self).filter("isSelected == true").count
                } else { // 既にaddされている都市がまた選ばれたら、OrderNoはそのまま
                    orderNo = (realm.object(ofType: StoredCity.self, forPrimaryKey: id)?.orderNo)!
                }
                
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true, "orderNo": orderNo], update: true)
                
                print("\(cities.filter("id == \(id)").first?.name) was enrolled!")
                
            } else {  // フィルタされた状態でセルがクリックされた場合
                
                let id = filteredCities[indexPath.row].id
                
                let orderNo = realm.objects(StoredCity.self).filter("isSelected == true").count
                
                
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true, "orderNo": orderNo], update: true)
                
                print("\(filteredCities[indexPath.row].name) was enrolled!")
                
            }
        }
        
        //閉じる(ナビゲーションバーで遷移してきたなら、こうすれば戻れるんだよ)
        // nav.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    ///////////////
    // MARK: Index
    ///////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return 1
        }
        
        return sections.count // 26だよ
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return filteredCities.count
        }
        
        let head_character = sections[section]
        let cityStartFromABC = cities.filter("name BEGINSWITH '\(head_character)'")

        return cityStartFromABC.count
        
    }
    
    var sections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        //return sections.map { $0.title }
        
        // searchBarに文字があればインデックスは表示しない
        if (searchBar.text?.characters.count)! > 0 {
            return nil
        }
        
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    
    /// セクションのタイトルを返す
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (searchBar.text?.characters.count)! > 0 {
            return nil
        }
        
        print("セクションのタイトル: \(sections[section])")
        return sections[section]
    }
    
    
    // インデックスリストをタップ時のコールバック
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title:String, at index: Int) -> Int {
        return index
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredCities = []
        
        let searchWord = searchBar.text
        
        // requiredCities = cities.filter{ $0.name.contains(searchWord!)} //$0が最初の引数を意味する。

        // 小文字・大文字を無視して検索
        filteredCities = cities.filter{ $0.name.lowercased().contains((searchWord?.lowercased())!) }
        
        print("まず、filteredCitiesのフィルタリングが行われる")
        
        tableView.reloadData()
    }
    
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        self.tableView.reloadData()
    }
}

