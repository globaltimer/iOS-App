
import UIKit

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
                  City(name: "Vancouver", timeZone: "PST"),
                  City(name: "Tokyo",     timeZone: "JST"),
                  City(name: "Venice",    timeZone: "CET"),
                  City(name: "London",    timeZone: "GMT"),
                  City(name: "Vancouver", timeZone: "PST"),
                  City(name: "Tokyo",     timeZone: "JST"),
                  City(name: "Venice",    timeZone: "CET"),
                  City(name: "London",    timeZone: "GMT")
                 ]
    
    var requiredCities: [City] = []
    
    
    var delegate: CityListTVCdelegate?
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //
        searchBar.delegate = self
        

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
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
        
        InfoVc.selectedCity = cities[indexPath.row]
        
        //閉じる
        nav.popViewController(animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("hoge---")
        
        requiredCities = []
        
        requiredCities.append(contentsOf: [cities[0], cities[1], cities[3]])
        
        tableView.reloadData()
        
    }
    
   
}




















