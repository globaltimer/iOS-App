
import UIKit
import RealmSwift


class AddCityViewController: UIViewController {
    
    let GMT: Date = Date()
    
    let realm = try! Realm()
    
    // 子を持つ
    // let cityListTVC = CityListTableViewController()
    
    
    // 次の画面から逆流してくる、選択された都市名
    var selectedCity: StoredCity? = nil
    
    @IBOutlet weak var selectedCityLabel: UILabel!
    @IBOutlet weak var selectedCityTimeLabel: UILabel!
    
    
    
    // var delegate: AddCityViewControllerDelegate! = ViewController()
    
    
    override func viewDidLoad() {
        
        //cityListTVC.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectedCityLabel.text = selectedCity?.name
        
        // [TimeLabel]
        
        var formatter = DateFormatter()
        
        // フォーマッタの初期設定
        setConfigToFormatter(fm: &formatter)
        
        if let _ = selectedCity {
            selectedCityTimeLabel.text = formatter.string(from: GMT)
        }
    
    }
    
    
    // フォーマッタの初期設定
    func setConfigToFormatter(fm: inout DateFormatter) {
        
        // タイムゾーン
        let timeZone = selectedCity?.timeZone
        
        fm.dateFormat = "MM/dd HH:mm"
        
        if let timeZone = timeZone {
            fm.timeZone = TimeZone(abbreviation: timeZone)
        }
        
    }
    

    @IBAction func addButtonTouched(_ sender: AnyObject) {
        
        guard let selectedCity = selectedCity else {
            
            print("city not set")
            
            return
        }
        
//        let storedCityNo = try! Realm().objects(StoredCity.self).count

        try! realm.write {
            
//            let city = StoredCity(id: storedCityNo+1, name: selectedCity.name, timeZone: selectedCity.timeZone)
//                        
//            self.realm.add(city, update: true)
            
            selectedCity.isSelected = true
            
            print("\(selectedCity.name) was enrolled!")
        }
        
        //Navigation Controllerを取得
        let nav = self.navigationController!
        
        //閉じる
        nav.popViewController(animated: true)
        
    }
    
    
    
//    // delegate method
//    func modalDidFinished(selectedCity: City) {
//        self.selectedCity = selectedCity
//    }
    
    
    //
    //    @IBAction func comeHome(segue: UIStoryboardSegue) {
    //    }
    //

    
}
