
import Foundation
import RealmSwift

struct City {
    
    let name: String
    let timeZone: String
    
}


class Task: Object {
    
    // 管理用 ID。プライマリーキー
    dynamic var id = 0

    dynamic var name = ""
    
    dynamic var timeZone = ""

    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
