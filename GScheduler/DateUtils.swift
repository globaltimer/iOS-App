
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
    
    class func stringFromDate(date: NSDate, format: String, tz: TimeZone) -> String {
        
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = format
        formatter.timeZone   = tz
        
        return formatter.string(from: date as Date)
    }
}
