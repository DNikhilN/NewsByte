//
//  NewsViewModel.swift
//  NewsByte
//
//  Created on 12/09/25.
//

import UIKit
import Alamofire

class NewsViewModel: NSObject {
    
    var newsListData: ((NewsListModel) -> Void)?
    var verifyailure: ((String) -> Void)?

    func fetchNewsData() {
        let urlString = NEWS_URL
        AF.request(urlString, method: .get, headers: nil)
            .validate() // checks for 200..<300 status codes
            .responseDecodable(of: NewsListModel.self) { response in
                switch response.result {
                case .success(let newsData):
                    AppConsole.printLog("✅ Articles count: \(String(describing: newsData.articles?.count))")
                    self.newsListData?(newsData)
                case .failure(let error):
                    AppConsole.printLog("❌ Error fetching data:", error)
                    self.verifyailure?(error.localizedDescription)
                }
            }
    }


}
