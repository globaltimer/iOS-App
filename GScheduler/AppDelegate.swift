
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // フォント
        let megrim = "Quicksand"
        
//       UILabel.appearance().font = UIFont(name: megrim, size: 14)
        //UITabBar.appearance().backgroundColor = UIColor.blue
        
        // タブバーのアイコン(フォーカス(=選択された状態)時)
        UITabBar.appearance().tintColor =  UIColor(red:0.13, green:0.55, blue:0.83, alpha:1.0)
        
        // タブバーのテキストのラベル
        UITabBarItem.appearance().setTitleTextAttributes(
            [ NSFontAttributeName: UIFont(name: megrim, size: 12) as Any,
              NSForegroundColorAttributeName: UIColor(red:0.13, green:0.55, blue:0.83, alpha:1.0) as Any
            ]
            , for: .normal)
        
        
        // ナビゲーションバーのタイトル
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0),
             NSFontAttributeName: UIFont(name: megrim, size: 18) as Any
        ]
        
        //
        
        
        //tintColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        
        //backgroundColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        
        
        // ナビゲーションバーのボタン
//        UINavigationBar.appearance().tintColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        
        // 右のボタンはなぜかきかないため、SBで直接指定している
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: megrim, size: 18) as Any,
//            NSForegroundColorAttributeName: UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0),
//        ], for: .normal)
        
        
        // ナビゲーションバーの背景色
        UINavigationBar.appearance().barTintColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        return true
    }
}
