/// https://refactoring.guru/design-patterns/observer
/// 
import XCTest


/// The Subject owns some important state and notifies observers when the state change.
class Subject {
    var state: Int = { return Int(arc4random_uniform(10)) }()
    
    private lazy var observers = [Observer]()
    
    func attach(_ observer: Observer) {
        print("Subject: Attached an observer.\n")
        observers.append(observer)
    }
    
    func detach(_ observer: Observer) {
        if let idx = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: idx)
            print("Subject: Detachech an observer.\n")
        }
    }
    
    func notify() {
        print("Subject: Notifying observers...\n")
        observers.forEach({ $0.update(subject: self) })
    }
    
    func someBusinessLogic() {
        print("Subject: I'm doing something important.")
        state = Int(arc4random_uniform(10))
        print("Subject: My state has just changed to: \(state)")
        notify()
    }
}

protocol Observer: AnyObject {
    func update(subject: Subject)
}

class ConcreteObserverA: Observer {
    func update(subject: Subject) {
        if subject.state < 3 {
            print("ConcreteObsserverA: Reacted to the event.\n")
        }
    }
}

class ConcreteObserverB: Observer {
    func update(subject: Subject) {
        if subject.state >= 3 {
            print("ConcreteObserverB: Reacted to the event.\n")
        }
    }
}

class ObserverTest: XCTestCase {
    func testObserver() {
        let subject = Subject()
        
        let observer1 = ConcreteObserverA()
        let observer2 = ConcreteObserverB()
        
        subject.attach(observer1)
        subject.attach(observer2)
        
        subject.someBusinessLogic()
        subject.someBusinessLogic()
        subject.detach(observer2)
        subject.someBusinessLogic()
    }
}

ObserverTest.defaultTestSuite.run()
