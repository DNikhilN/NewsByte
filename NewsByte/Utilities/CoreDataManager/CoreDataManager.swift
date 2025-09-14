//
//  CoreDataManager.swift


import Foundation
import CoreData

class CoreDataManager{
    
    static let manager = CoreDataManager()
    static let context = APP_DELEGATE.persistentContainer.viewContext
    
    static func fetchAllArticles()->[NewsArticles]?{
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>
            // predicate
            let articles = try context.fetch(request)
            return articles
        } catch {
            print("getting error while fetching users",error)
            return nil
        }
    }
    
    static func fetchArticlesByTitle(title: String) -> [NewsArticles]? {
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
            request.predicate = predicate
            let sort = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [sort]
            let articles = try context.fetch(request)
            return articles
        } catch {
            print("getting error while fetching users", error)
            return nil
        }
    }
    
    static func fetchArticleBy(title: String) -> [NewsArticles]? {
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>

            request.predicate = NSPredicate(format: "title == %@", title)

            let articles = try context.fetch(request)
            return articles
        } catch {
            print("getting error while fetching users", error)
            return nil
        }
    }
    
    static func fetchArticleByBackgroundContext(title: String) -> [NewsArticles]? {
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>
            request.predicate = NSPredicate(format: "title == %@", title)
            return try backgroundContext.fetch(request)
        } catch {
            print("Error while fetching article:", error)
            return nil
        }
    }
    
    static let backgroundContext: NSManagedObjectContext = {
        let context = APP_DELEGATE.persistentContainer.newBackgroundContext()
        return context
    }()
    
    static func fetchArticles(isBookmarked: Bool) -> [NewsArticles]? {
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>
            request.predicate = NSPredicate(
                format: "is_bookmark == %@",
                NSNumber(value: isBookmarked)   
            )
            return try context.fetch(request)
        } catch {
            print("Error while fetching articles:", error)
            return nil
        }
    }
    
    
    static func fetchBookmarkedArticles(matching title: String) -> [NewsArticles]? {
        do {
            let request = NewsArticles.fetchRequest() as NSFetchRequest<NewsArticles>
            request.predicate = NSPredicate(
                format: "is_bookmark == %@ AND title CONTAINS[cd] %@",
                NSNumber(value: true),
                title
            )

            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            return try context.fetch(request)
        } catch {
            print("Error while fetching bookmarked articles:", error)
            return nil
        }
    }

}
