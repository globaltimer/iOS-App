
import UIKit

class DateUtils {
    
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
//        formatter.calendar = gregorianCalendar
        formatter.dateFormat = format
        return formatter.date(from: string)! as Date
    }

//    class func stringFromDate(date: NSDate, format: String) -> String {
//        let formatter: DateFormatter = DateFormatter()
////            formatter.calendar = gregorianCalendar
//        formatter.dateFormat = format
//        return formatter.string(from: date as Date)
//    }
    
    class func stringFromDate(date: Date, format: String, tz: TimeZone) -> String {
        
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = format
        formatter.timeZone   = tz
        
        formatter.dateFormat = format
        
        // 空文字 → Yearラベル(左のラベル)設定時の実行
        if format == "" {
            formatter.dateStyle = .medium
            //formatter.timeStyle = .none
        }
        
        return formatter.string(from: date as Date)
    }
}
