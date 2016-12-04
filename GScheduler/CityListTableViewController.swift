
import UIKit
import RealmSwift

// ちなもうこのデリゲートメソッド使ってないから消せ。ちくしょう、delegateの設定の仕方がわからねえ...
//protocol CityListTVCdelegate {
//    func modalDidFinished(selectedCity: City)
//}


class CityListTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!

    let realm = try! Realm()

    let cities = try! Realm().objects(StoredCity.self).sorted(byProperty: "id", ascending: true)
    
    var filteredCities: [StoredCity] = []
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        searchBar.delegate = self
        

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchBar.text?.characters.count)! > 0 {
            return filteredCities.count
        }
        
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if (searchBar.text?.characters.count)! > 0 {
            
            cell.textLabel?.text = filteredCities[indexPath.row].name
            
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
                        
            InfoVc.selectedCity = filteredCities[indexPath.row]
            
        } else {
            InfoVc.selectedCity = cities[indexPath.row]
        }
        
        //閉じる
        nav.popViewController(animated: true)
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




















