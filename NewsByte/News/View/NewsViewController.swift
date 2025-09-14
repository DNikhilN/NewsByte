//
//  HomeViewController.swift
//  News Byte
//
//  Created on 11/09/25.
//

import UIKit
import SDWebImage

class NewsViewController: UIViewController {
    
    @IBOutlet weak var searchVw: CustomSearch!
    @IBOutlet weak var newsListTableView: UITableView!
    
    var articlesList:[NewsArticles]?{
        didSet{
            if let count =  articlesList?.count {
                self.newsListTableView.isHidden = count == 0 ? true : false
            }
        }
    }
    var viewModel = NewsViewModel()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchVw.searchTf?.text = EMPTY_STRING
        self.searchVw.crossBtn?.isHidden = true
        if  !Connectivity.isConnectedToInternet() {
            self.articlesList = CoreDataManager.fetchAllArticles()
            self.newsListTableView.reloadData()
        } else {
            LoaderManager.shared.show(in: self.view)
            self.viewModel.fetchNewsData()
        }
    }
    
   private func setupUi(){
       self.bindViewModel()
       self.refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
       self.newsListTableView.refreshControl = refreshControl
       self.newsListTableView.register(UINib(nibName: TABLE_CELL_IDENTIFIER.NEWS_LIST, bundle: nil), forCellReuseIdentifier: TABLE_CELL_IDENTIFIER.NEWS_LIST)
       newsListTableView.delegate = self
       newsListTableView.dataSource = self
       self.searchVw.completionForSearch = { text in
           AppConsole.printLog("text got \(text)")
           if text.isEmpty{
               self.searchVw.crossBtn?.isHidden = true
               self.articlesList = CoreDataManager.fetchAllArticles()
           } else {
               self.searchVw.crossBtn?.isHidden = false
               self.articlesList = CoreDataManager.fetchArticlesByTitle(title: text)
           }
           self.newsListTableView.reloadData()
       }
       self.searchVw.completionForCrossBtn = {
           self.searchVw.searchTf?.text = EMPTY_STRING
           self.searchVw.searchTf?.resignFirstResponder()
           self.searchVw.crossBtn?.isHidden = true
           self.articlesList = CoreDataManager.fetchAllArticles()
           self.newsListTableView.reloadData()
       }
    }
    
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        self.searchVw.searchTf?.text = EMPTY_STRING
        if  !Connectivity.isConnectedToInternet() {
            self.articlesList = CoreDataManager.fetchAllArticles()
            DispatchQueue.main.async {
                self.newsListTableView.reloadData()
                self.newsListTableView.refreshControl?.endRefreshing()
            }
        } else {
            self.viewModel.fetchNewsData()
        }
    }

}

//MARK: - EXTENSION FOR TABLEVIEW METHODS
extension NewsViewController:UITableViewDelegate,UITableViewDataSource{
    
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
            AppConsole.printLog("mort image ",article?.title,article?.imageUrl)
            cell.imgVw.image = UIImage(named: "placeHolder")
        }
        cell.completionForBookmarkSelection = { [weak self] tag in
            let title = self?.articlesList?[tag].title ?? EMPTY_STRING
            if let articles = CoreDataManager.fetchArticleBy(title: title),let firstArticle = articles.first{
                firstArticle.is_bookmark.toggle()
                APP_DELEGATE.saveContext()
                if let isSearchNotContainsText = self?.searchVw.searchTf?.text?.isEmpty {
                    if isSearchNotContainsText {
                        self?.articlesList = CoreDataManager.fetchAllArticles()
                    } else {
                        self?.articlesList = CoreDataManager.fetchArticlesByTitle(title: self?.searchVw.searchTf?.text ?? EMPTY_STRING)
                    }
                }
                self?.newsListTableView.reloadData()
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

//MARK: - EXTENSION FOR ADDING METHODS TO COREDATA
extension NewsViewController{
    
    func addingArticlesToCoreData(atricle:Articles?){
        let newArticle = NewsArticles(context:APP_DELEGATE.persistentContainer.viewContext)
        newArticle.title = atricle?.title ?? EMPTY_STRING
        newArticle.descriptionGot = atricle?.description ?? EMPTY_STRING
        newArticle.imageUrl = atricle?.urlToImage ?? EMPTY_STRING
        APP_DELEGATE.saveContext()
    }
    
}

//MARK: - EXTENSION FOR API METHODS
extension NewsViewController{
    
    func bindViewModel() {
        viewModel.newsListData = { response in
            LoaderManager.shared.hide()
            guard let articles = response.articles else {
                return
            }
            for article in articles {
                if let title = article.title,let articleGot = CoreDataManager.fetchArticlesByTitle(title: title){
                    if articleGot.isEmpty {
                        self.addingArticlesToCoreData(atricle: article)
                    } else {
                        AppConsole.printLog(articleGot.first?.title ?? EMPTY_STRING)
                    }
                }
            }
            self.articlesList = CoreDataManager.fetchAllArticles()
            DispatchQueue.main.async {
                self.newsListTableView.reloadData()
                self.newsListTableView.refreshControl?.endRefreshing()
            }
        }
        
        viewModel.verifyailure = { message in
            LoaderManager.shared.hide()
            //Need to add alert to show any error
        }
    }
    
}
