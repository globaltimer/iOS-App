
import UIKit
import RealmSwift


class CityListTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    let realm = try! Realm()
    let cities = try! Realm().objects(StoredCity.self).sorted(byKeyPath: "id", ascending: true)
    var filteredCities: [StoredCity] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        searchBar.delegate = self
    }

    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return filteredCities.count
        }
        
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddCityViewCell
        
        if (searchBar.text?.characters.count)! > 0 {
            
            cell.cityNameLabel.text = filteredCities[indexPath.row].name
            cell.diffGMTLabel.text = "hogehoge-"

            return cell
        }
        
        cell.cityNameLabel.text = cities[indexPath.row].name
        cell.diffGMTLabel.text = "こんにちは"

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        
        // Realmに保存
//        guard let selectedCity = selectedCity else {
//            print("city not set")
//            return
//        }
        
        try! realm.write {
            
            if (searchBar.text?.characters.count)! == 0 {
                let id = indexPath.row
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true], update: true)
                print("\(cities[indexPath.row].name) was enrolled!")
            } else {
                
                let id = filteredCities[indexPath.row].id
                realm.create(StoredCity.self, value: ["id": id, "isSelected": true], update: true)
                print("\(cities[indexPath.row].name) was enrolled!")
            }
        }
        
        //閉じる
        nav.popViewController(animated: true)
    }
    
    
    //セクション
    //let sectionIndex: [String] = ["A", "M", "Q", "Z"]
    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
//        return sectionIndex as [AnyObject]!
//    }

    
    
    //var sections : [(index: Int, length :Int, title: String)] = Array()
    var sections = ["1", "2", "3"]
    

    /// セクションのタイトルを返す
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String {
        return sections[section]
        
    }
    
    override func sectionIndexTitles(
        for tableView: UITableView) -> [String]? {
        //return sections.map { $0.title }
        return ["A", "B", "C", "D"]
    }
    
    
    override func tableView(_ tableView: UITableView,
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

