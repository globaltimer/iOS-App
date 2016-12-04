
import UIKit


class AddCityViewController: UIViewController, CityListTVCdelegate {
    
    let GMT: Date = Date()
    
    // 子を持つ
    // let cityListTVC = CityListTableViewController()
    
    

    // 次の画面から逆流してくる、選択された都市名
    var selectedCity: City? = nil
    
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
        
        print("hoge")
        
        //Navigation Controllerを取得
        let nav = self.navigationController!
        
        //閉じる
        nav.popViewController(animated: true)
        
    }
    
    
    
    // delegate method
    func modalDidFinished(selectedCity: City) {
        self.selectedCity = selectedCity
    }
    
    
    //
    //    @IBAction func comeHome(segue: UIStoryboardSegue) {
    //    }
    //

    
}
