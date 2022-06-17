/// https://refactoring.guru/design-patterns/prototype
/// 
import XCTest

class Author {
    private var id: Int
    private var username: String
    private var pages = [Page]()
    
    init(id: Int, username: String) {
        self.id = id
        self.username = username
    }
    
    func add(page: Page) {
        pages.append(page)
    }
    
    var pagesCount: Int {
        return pages.count
    }
}

class Page: NSCopying {
    private(set) var title: String
    private(set) var contents: String
    private(set) var author: Author?
    private(set) var comments = [Comment]()
    
    init(title: String, contents: String, author: Author?) {
        self.title = title
        self.contents = contents
        self.author = author
        author?.add(page: self)
    }
    
    func add(comment: Comment) {
        comments.append(comment)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Page(title: "Copy of '" + title + "'", contents: contents, author: author)
    }
}

struct Comment {
    let date = Date()
    let message: String
}

class PrototypeTest: XCTestCase {
    
    func testPrototype() {
        let author = Author(id: 10, username: "Ivan_83")
        let page = Page(
            title: "My First Page",
            contents: "Hellow world!",
            author: author)
        
        page.add(comment: Comment(message: "Keep it up!"))

        guard let anotherPage = page.copy() as? Page else {
            XCTFail("Page was not copied")
            return
        }
        
        XCTAssert(anotherPage.comments.isEmpty)
        
        XCTAssert(author.pagesCount == 2)
        
        print("Original title: " + page.title)
        print("Copied title: " + anotherPage.title)
        print("count of pages: " + String(author.pagesCount))
    }
}

PrototypeTest.defaultTestSuite.run()
