
import UIKit
import RealmSwift

// ちなもうこのデリゲートメソッド使ってないから消せ。ちくしょう、delegateの設定の仕方がわからねえ...
protocol CityListTVCdelegate {
    func modalDidFinished(selectedCity: City)
}


class CityListTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cities = [
                  City(name: "Vancouver", timeZone: "PST"),
                  City(name: "Tokyo",     timeZone: "JST"),
                  City(name: "Venice",    timeZone: "CET"),
                  City(name: "London",    timeZone: "GMT"),
                  City(name: "Varcerona", timeZone: "PST"),
                  City(name: "New York",  timeZone: "JST"),
                  City(name: "China",     timeZone: "CET"),
                  City(name: "Hoe",       timeZone: "GMT"),
                  City(name: "China2",    timeZone: "PST"),
                  City(name: "itaky",     timeZone: "JST"),
                  City(name: "spain",     timeZone: "CET"),
                  City(name: "america",   timeZone: "GMT")
                 ]
    
    var requiredCities: [City] = []
    
    var delegate: CityListTVCdelegate?
    
    let realm = try! Realm()
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        searchBar.delegate = self
        

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return requiredCities.count
        }
        
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if (searchBar.text?.characters.count)! > 0 {
            
            cell.textLabel?.text = requiredCities[indexPath.row].name
            
            return cell
            
        }
        
        cell.textLabel?.text = cities[indexPath.row].name

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // modal時にしか効かないっぽい？ので、これはダメ
//        self.dismiss(animated: true, completion: nil)
        
        //Navigation Controllerを取得
        let nav = self.navigationController!
        
        //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
        // ここが "2"の理由がわからねえ。。。
        let InfoVc = nav.viewControllers[nav.viewControllers.count-2] as! AddCityViewController
        
        if (searchBar.text?.characters.count)! > 0 {
                        
            InfoVc.selectedCity = requiredCities[indexPath.row]
            
        } else {
            InfoVc.selectedCity = cities[indexPath.row]
        }
        
        //閉じる
        nav.popViewController(animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("hoge---")
        
        requiredCities = []
        
        let searchWord = searchBar.text
        
        // requiredCities = cities.filter{ $0.name.contains(searchWord!)} //$0が最初の引数を意味する。

        // 小文字・大文字を無視して検索
        requiredCities = cities.filter{ $0.name.lowercased().contains((searchWord?.lowercased())!) }
        
        tableView.reloadData()
        
    }
    
   
}




















