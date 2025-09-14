//
//  BookmarksViewController.swift
//  NewsByte
//
//
//

import UIKit

class BookmarksViewController: UIViewController {
    
    @IBOutlet weak var searchVw: CustomSearch!
    @IBOutlet weak var bookmarksListTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    var articlesList:[NewsArticles]?{
        didSet{
            if let count =  articlesList?.count {
                self.bookmarksListTableView.isHidden = count == 0 ? true : false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchVw.searchTf?.text = EMPTY_STRING
        self.searchVw.crossBtn?.isHidden = true
        self.articlesList = CoreDataManager.fetchArticles(isBookmarked: true)
        self.bookmarksListTableView.reloadData()
    }
    
    private func setupUi(){
        self.refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.bookmarksListTableView.refreshControl = refreshControl
        self.bookmarksListTableView.register(UINib(nibName: TABLE_CELL_IDENTIFIER.NEWS_LIST, bundle: nil), forCellReuseIdentifier: TABLE_CELL_IDENTIFIER.NEWS_LIST)
        bookmarksListTableView.delegate = self
        bookmarksListTableView.dataSource = self
        self.searchVw.completionForSearch = { text in
            AppConsole.printLog("text got \(text)")
            if text.isEmpty{
                self.searchVw.crossBtn?.isHidden = true
                self.articlesList = CoreDataManager.fetchArticles(isBookmarked: true)
            } else {
                self.searchVw.crossBtn?.isHidden = false
                self.articlesList = CoreDataManager.fetchBookmarkedArticles(matching: text)
            }
            self.bookmarksListTableView.reloadData()
        }
        self.searchVw.completionForCrossBtn = {
            self.searchVw.searchTf?.text = EMPTY_STRING
            self.searchVw.searchTf?.resignFirstResponder()
            self.searchVw.crossBtn?.isHidden = true
            self.articlesList = CoreDataManager.fetchArticles(isBookmarked: true)
            self.bookmarksListTableView.reloadData()
        }
     }
    
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        self.searchVw.searchTf?.text = EMPTY_STRING
        self.searchVw.searchTf?.text = EMPTY_STRING
        self.searchVw.searchTf?.resignFirstResponder()
        self.searchVw.crossBtn?.isHidden = true
        self.articlesList = CoreDataManager.fetchArticles(isBookmarked: true)
        self.bookmarksListTableView.refreshControl?.endRefreshing()
        self.bookmarksListTableView.reloadData()
    }

}


//MARK: - EXTENSION FOR TABLEVIEW METHODS
extension BookmarksViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TABLE_CELL_IDENTIFIER.NEWS_LIST, for: indexPath) as! NewsListTableViewCell
        cell.selectionStyle = .none
        let article = articlesList?[indexPath.row]
        cell.descLbl.text = article?.descriptionGot
        cell.titleLbl.text = article?.title
        cell.bookmarkBtnOutlet.tag = indexPath.row
        if let isBookMart = article?.is_bookmark{
            cell.bookmarkBtnOutlet.setImage(UIImage(systemName: isBookMart ? "star.fill":"star"), for: .normal)
        }
        if let data = article?.imageData {
            cell.imgVw.image = UIImage(data: data)
        } else if let urlString = article?.imageUrl, let url = URL(string: urlString) {
            cell.imgVw.sd_setImage(with: url,
                                   placeholderImage:UIImage(named: "placeHolder") ) {  image, _, _, _ in
                guard let image = image else { return }
                // Save to Core Data once downloaded
                // All Core Data work stays inside backgroundContext
                CoreDataManager.backgroundContext.perform {
                    if let articles = CoreDataManager.fetchArticleByBackgroundContext(title: article?.title ?? EMPTY_STRING),
                       let updatingArticle = articles.first {
                        updatingArticle.imageData = image.pngData()
                        do {
                            try CoreDataManager.backgroundContext.save()   //save the background context itself so ui cannot hang
                        } catch {
                            print("Background save error:", error)
                        }
                    }
                }
            }
        } else {
            cell.imgVw.image = UIImage(named: "placeHolder")
        }
        cell.completionForBookmarkSelection = { [weak self] tag in
            let title = self?.articlesList?[tag].title ?? EMPTY_STRING
            if let articles = CoreDataManager.fetchArticleBy(title: title),let firstArticle = articles.first{
                firstArticle.is_bookmark.toggle()
                APP_DELEGATE.saveContext()
                if let isSearchNotContainsText = self?.searchVw.searchTf?.text?.isEmpty {
                    if isSearchNotContainsText {
                        self?.articlesList = CoreDataManager.fetchArticles(isBookmarked: true)
                    } else {
                        self?.articlesList = CoreDataManager.fetchBookmarkedArticles(matching: self?.searchVw.searchTf?.text ?? EMPTY_STRING)
                    }
                }
                self?.bookmarksListTableView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
