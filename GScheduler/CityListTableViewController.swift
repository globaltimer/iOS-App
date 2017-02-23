
import UIKit
import RealmSwift


//class CityListTableViewController: UITableViewController, UISearchBarDelegate {

class CityListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
        
    let realm = try! Realm()
    
    let cities = try! Realm().objects(StoredCity.self).sorted(byKeyPath: "id", ascending: true)
    
    var filteredCities: [StoredCity] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //
        
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

    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return filteredCities.count
        }
        
        return cities.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NeoCell    // as! AddCityViewCell
        
        if (searchBar.text?.characters.count)! > 0 {
            
            cell.cityNameLabel.text = filteredCities[indexPath.row].name
            cell.diffGMTLabel.text = "hogehoge-"

            return cell
        }
        
        cell.cityNameLabel.text = cities[indexPath.row].name.uppercased()
        cell.cityNameLabel.textColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        
        
        ////
        var formatter = DateFormatter()
        
        // フォーマッタの初期設定
        func setConfigToFormatter(fm: inout DateFormatter, cellIdx: Int) {
            // タイムゾーン
            let timeZone = cities[cellIdx].timeZone
            fm.dateFormat = "ZZZZ"
            fm.timeZone = TimeZone(abbreviation: timeZone)
        }
        
        setConfigToFormatter(fm: &formatter, cellIdx: indexPath.row)
        
        
        let boke = formatter.string(from: Date())
        
        cell.diffGMTLabel.text = boke
        
        if boke == "GMT" {
            cell.diffGMTLabel.text = "GMT ±00:00"
        }
        
        
        
        
        /////
    
        
        
        
        cell.diffGMTLabel.textColor = UIColor(red:0.77, green:0.42, blue:0.42, alpha:1.0)
        
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // modal時にしか効かないっぽい？ので、これはダメ
//        self.dismiss(animated: true, completion: nil)
        
        //Navigation Controllerを取得
        let nav = self.navigationController!
        
        //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
        // ここが "2"の理由がわからねえ。。。
        let InfoVc = nav.viewControllers[nav.viewControllers.count-2] as! ViewController
        
        if (searchBar.text?.characters.count)! > 0 {
                        
            InfoVc.selectedCity = filteredCities[indexPath.row]
            
        } else {
            InfoVc.selectedCity = cities[indexPath.row]
        }
        
        
        try! realm.write {
            
            if (searchBar.text?.characters.count)! == 0 {
                
                let id = indexPath.row
                
                let orderNo = realm.objects(StoredCity.self).filter("isSelected == true").count
                
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true, "orderNo": orderNo], update: true)
                
                print("\(cities[indexPath.row].name) was enrolled!")
                
            } else {  // フィルタされた状態でセルがクリックされた場合
                
                let id = filteredCities[indexPath.row].id
                
                let orderNo = realm.objects(StoredCity.self).filter("isSelected == true").count
                
                
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true, "orderNo": orderNo], update: true)
                
                print("\(filteredCities[indexPath.row].name) was enrolled!")
                
            }
        }
        
        //閉じる
        nav.popViewController(animated: true)
    }
    
    
    //var sections : [(index: Int, length :Int, title: String)] = Array()
    var sections = ["1", "2", "3"]
    

    /// セクションのタイトルを返す
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
     func sectionIndexTitles(
        for tableView: UITableView) -> [String]? {
        //return sections.map { $0.title }
        return ["A", "B", "C", "D"]
    }
    
    
     func tableView(_ tableView: UITableView,
                            sectionForSectionIndexTitle title: String,
                            at index: Int) -> Int {
        return index
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("hoge---")
        
        filteredCities = []
        
        let searchWord = searchBar.text
        
        // requiredCities = cities.filter{ $0.name.contains(searchWord!)} //$0が最初の引数を意味する。

        // 小文字・大文字を無視して検索
        filteredCities = cities.filter{ $0.name.lowercased().contains((searchWord?.lowercased())!) }
        
        tableView.reloadData()
    }
    
    
}


