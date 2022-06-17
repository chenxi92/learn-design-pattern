/// https://refactoring.guru/design-patterns/mediator
import XCTest

struct News: Equatable {
    let id: Int
    let title: String
    var likesCount: Int
    
    static func ==(left: News, right: News) -> Bool {
        return left.id == right.id
    }
}

protocol ScreenUpdatable: AnyObject {
    func likeAdded(to news: News)
    func likeRemoved(from news: News)
}

class NewsFeedViewController: ScreenUpdatable {
    private var newsArray: [News]
    private weak var mediator: ScreenUpdatable?
    
    init(_ mediator: ScreenUpdatable?, _ newsArray: [News]) {
        self.newsArray = newsArray
        self.mediator = mediator
    }
    
    func likeAdded(to news: News) {
        print("News Feed: Received a likes nes model with id: \(news.id)")
        
        for var item in newsArray {
            if item == news {
                item.likesCount += 1
            }
        }
    }
    
    func likeRemoved(from news: News) {
        print("News Feed: Received a disliked news model with id: \(news.id)")
        for var item in newsArray {
            if item == news {
                item.likesCount -= 1
            }
        }
    }
    
    func userLikedAllNes() {
        print("\n\nNews Feed: User LIKED all news models")
        print("News Feed: I am telling to mediator about it...\n")
        
        newsArray.forEach { new in
            mediator?.likeAdded(to: new)
        }
    }
    
    func userDislikedAllNes() {
        print("\n\nNews Feed: User IDSLIKED all news models")
        print("News Feed: I am telling to mediator about it...\n")

        newsArray.forEach { new in
            mediator?.likeRemoved(from: new)
        }
    }
}

class NewsDetailViewController: ScreenUpdatable {
    private var news: News
    private weak var mediator: ScreenUpdatable?
    
    init(_ mediator: ScreenUpdatable?, _ news: News) {
        self.news = news
        self.mediator = mediator
    }
    
    func likeAdded(to news: News) {
        print("News Detail: Received a liked news model with id: \(news.id)")
        if self.news == news {
            self.news.likesCount += 1
        }
    }
    
    func likeRemoved(from news: News) {
        print("News Detail: Received a disliked news model with id: \(news.id)")
        if self.news == news {
            self.news.likesCount -= 1
        }

    }
}

class ProfileViewController: ScreenUpdatable {
    private var numberOfGivenLikes: Int
    private weak var mediator: ScreenUpdatable?
    
    init(_ mediator: ScreenUpdatable?, _ numberOfGivenLies: Int) {
        self.numberOfGivenLikes = numberOfGivenLies
        self.mediator = mediator
    }
    
    func likeAdded(to news: News) {
        print("Profile: Received a liked news model with id: \(news.id)")
        numberOfGivenLikes += 1
    }
    
    func likeRemoved(from news: News) {
        print("Profile: Received a idsliked news model with id: \(news.id)")
        numberOfGivenLikes -= 1
    }
}

class ScreenMediator: ScreenUpdatable {
    private var screens: [ScreenUpdatable]?
    
    func update(_ screens: [ScreenUpdatable]) {
        self.screens = screens
    }
    
    func likeAdded(to news: News) {
        print("ScreenMediator: Received a liked news model with id: \(news.id)")
        screens?.forEach({ $0.likeAdded(to: news) })
    }
    
    func likeRemoved(from news: News) {
        print("ScreenMediator: Received a disliked news model with id: \(news.id)")
        screens?.forEach({ $0.likeRemoved(from: news) })
    }
}

class MediatorTest: XCTestCase {
    func testMediator() {
        let newsArray = [
            News(id: 1, title: "News1", likesCount: 1),
            News(id: 2, title: "News2", likesCount: 2)
        ]
        
        let numberOfGivenLikes = newsArray.reduce(0, { $0 + $1.likesCount })
        
        let mediator = ScreenMediator()
        
        let feedVC = NewsFeedViewController(mediator, newsArray)
        let newsDetailVC = NewsDetailViewController(mediator, newsArray.first!)
        let profileVC = ProfileViewController(mediator, numberOfGivenLikes)
        
        mediator.update([feedVC, newsDetailVC, profileVC])
        
        feedVC.userLikedAllNes()
        feedVC.userDislikedAllNes()
    }
}

MediatorTest.defaultTestSuite.run()
