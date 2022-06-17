/// https://refactoring.guru/design-patterns/builder
///
import XCTest
import Foundation

protocol DomainModel {
}

struct User: DomainModel {
    let id: Int
    let age: Int
    let email: String
}


class BaseQueryBuilder<Model: DomainModel> {
    typealias Predicate = (Model) -> (Bool)
    
    func limit(_ limit: Int) -> BaseQueryBuilder<Model> {
        return self
    }
    
    func filter(_ predicate: @escaping Predicate) -> BaseQueryBuilder<Model> {
        return self
    }
    
    func fetch() -> [Model] {
        preconditionFailure("Should be overridden in subclass")
    }
}

class RealmQueryBuilder<Model: DomainModel>: BaseQueryBuilder<Model> {
    enum Query {
        case filter(Predicate)
        case limit(Int)
    }
    
    fileprivate var operations = [Query]()
    
    @discardableResult
    override func limit(_ limit: Int) -> RealmQueryBuilder<Model> {
        operations.append(Query.limit(limit))
        return self
    }
    
    @discardableResult
    override func filter(_ predicate: @escaping Predicate) -> RealmQueryBuilder<Model> {
        operations.append(Query.filter(predicate))
        return self
    }
    
    override func fetch() -> [Model] {
        print("RealmQueryBuilder: Initializing CoreDataProvider with \(operations.count) operations")
        return RealmProvider().fetch(operations)
    }
}

class CoreDataQueryBuilder<Model: DomainModel>: BaseQueryBuilder<Model> {
    enum Query {
        case filter(Predicate)
        case limit(Int)
        case includesPropertyValues(Bool)
    }
    
    fileprivate var operations = [Query]()
    
    override func limit(_ limit: Int) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.limit(limit))
        return self
    }
    
    override func filter(_ predicate: @escaping Predicate) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.filter(predicate))
        return self
    }
    
    func includesPropertyValues(_ toggle: Bool) -> CoreDataQueryBuilder<Model> {
        operations.append(Query.includesPropertyValues(toggle))
        return self
    }
    
    override func fetch() -> [Model] {
        print("CoreDataQueryBuilder: Initializing CoreDataProvider with \(operations.count) operations.")
        return CoreDataProvider().fetch(operations)
    }
}


class RealmProvider {
    func fetch<Model: DomainModel>(_ operations: [RealmQueryBuilder<Model>.Query]) -> [Model] {
        print("RealmProvider: Retrieving data from Realm ...")
        for operation in operations {
            switch operation {
            case .filter(_):
                print("RealmProvider: executing the 'filter' operation")
                break
            case .limit(let count):
                print("RealmProvider: executing the 'limit' operation: \(count).")
                break
            }
        }
        return []
    }
}

class CoreDataProvider {
    func fetch<Model: DomainModel>(_ operations: [CoreDataQueryBuilder<Model>.Query]) -> [Model] {
        print("CoreDataProvider: Retrieving data from CoreData...")
        
        for operation in operations {
            switch operation {
            case .filter(_):
                print("CoreDataProvider: executing the 'filter' operation.")
                break
            case .limit(let count):
                print("CoreDataProvider: executing the 'limit' operation \(count).")
                break
            case .includesPropertyValues(let toggle):
                print("CoreDataProvider: executing the 'includesPropertyValues' operation \(toggle).")
                break
            }
        }
        return []
    }
}

class BuilderTest: XCTestCase {
    func testBuilder() {
        print("Client: Start fetching data from Realm")
        let result1 = RealmQueryBuilder<User>()
            .filter({ $0.age < 20 })
            .limit(1)
            .fetch()
        print("Client: I have fetched: " + String(result1.count) + " records.")
        print()
        
        print("Client: Start fetching data from CoreData")
        let result2 =  CoreDataQueryBuilder<User>()
            .filter({ $0.age < 20 })
            .includesPropertyValues(false)
            .limit(1)
            .fetch()
        print("Client: I have fetched: " + String(result2.count) + " records.")
    }
}

BuilderTest.defaultTestSuite.run()
