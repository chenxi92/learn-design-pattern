/// https://refactoring.guru/design-patterns/strategy/swift/example
///
import XCTest

protocol DomainModel {
    var id: Int { get }
}

struct User: DomainModel {
    var id: Int
    var username: String
}

protocol DataSource {
    func loadModels<T: DomainModel>() -> [T]
}

class MemeoryStorage<Model>: DataSource {
    private lazy var items = [Model]()
    
    func add(_ items: [Model]) {
        self.items.append(contentsOf: items)
    }
    
    func loadModels<T>() -> [T] where T : DomainModel {
        guard T.self == User.self else { return [] }
        return items as! [T]
    }
}

class CoreDataStorage: DataSource {
    func loadModels<T>() -> [T] where T : DomainModel {
        guard T.self == User.self else { return [] }
        
        let firstUser = User(id: 3, username: "username3")
        let secondUser = User(id: 4, username: "username4")
        return [firstUser, secondUser] as! [T]
    }
}

class RealmStorage: DataSource {
    func loadModels<T: DomainModel>() -> [T] {
        guard T.self == User.self else { return [] }

        let firstUser = User(id: 5, username: "username5")
        let secondUser = User(id: 6, username: "username6")

        return [firstUser, secondUser] as! [T]
    }
}

class ListController {
    private var dataSource: DataSource?
 
    func update(dataSource: DataSource) {
        /// ... reset current states ...
        self.dataSource = dataSource
    }
    
    func displayModels() {
        guard let dataSource = dataSource else {
            return
        }
        let models = dataSource.loadModels() as [User]
        
        print("\nListController: Displaying models....")
        models.forEach({ print($0) })
    }
}

class StragetyTest: XCTestCase {
    func test() {
        let controller = ListController()
        
        let memoryStorage = MemeoryStorage<User>()
        memoryStorage.add(usersFromNetwork())
        
        clientCode(use: controller, with: memoryStorage)
        clientCode(use: controller, with: CoreDataStorage())
        clientCode(use: controller, with: RealmStorage())
    }
    
    func clientCode(use controller: ListController, with dataSource: DataSource) {
        controller.update(dataSource: dataSource)
        controller.displayModels()
    }
    
    private func usersFromNetwork() -> [User] {
       let firstUser = User(id: 1, username: "username1")
       let secondUser = User(id: 2, username: "username2")
       return [firstUser, secondUser]
   }
}

StragetyTest.defaultTestSuite.run()

