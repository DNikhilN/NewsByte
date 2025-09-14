
import UIKit
import Alamofire

/// App constants
let APP_NAME = "News Byte"
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

let NEWS_KEY = "99fffc7417424fc7a6556c5109ceed64"
let NEWS_URL = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(NEWS_KEY)"

let EMPTY_STRING = ""

/// Api response constants
let SERVICE_NAME = "BEGIN:NEWS BYTE ======> ServiceName :"
let SERVICE_PARAMS = "BEGIN:NEWS BYTE ======> Parameters :"
let SERVICE_HEADERS = "BEGIN:NEWS BYTE ======> Headers :"
let SERVICE_ERROR = "BEGIN:NEWS BYTE ======> ERROR :"

let INTERNET_ERROR = "Please check your internet connection"

struct TABLE_CELL_IDENTIFIER {
    static let NEWS_LIST = "NewsListTableViewCell"
}

struct METHODS{
    static let POST = "POST"
    static let GET = "GET"
}

///Checking for internet connectivity
class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}



