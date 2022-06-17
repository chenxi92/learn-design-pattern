/// https://refactoring.guru/design-patterns/singleton
///
import XCTest

struct Message {
    let id: Int
    let text: String
}

protocol MessageSubscriber {
    func accept(new messages: [Message])
    func accept(removed messages: [Message])
}

protocol MessageService {
    func add(subscriber: MessageSubscriber)
}

class FriendsChatService: MessageService {
    static let shared = FriendsChatService()
    private var subscribers = [MessageSubscriber]()
    
    func add(subscriber: MessageSubscriber) {
        subscribers.append(subscriber)
        
        startFetching()
    }
    
    func startFetching() {
        let newMessages = [
            Message(id: 0, text: "Text0"),
            Message(id: 5, text: "Text5"),
            Message(id: 10, text: "Text10")
        ]
        
        let removedMessages = [Message(id: 1, text: "Text0")]
        
        receivedNew(messages: newMessages)
        receivedRemoved(messages: removedMessages)
    }
}

private extension FriendsChatService {
    func receivedNew(messages: [Message]) {
        subscribers.forEach { item in
            item.accept(new: messages)
        }
    }
    
    func receivedRemoved(messages: [Message]) {
        subscribers.forEach { item in
            item.accept(removed: messages)
        }
    }
}

class BaseVC: UIViewController, MessageSubscriber {
    func accept(new messages: [Message]) {
        
    }
    func accept(removed messages: [Message]) {
        
    }
    
    func startReceiveMessages() {
        FriendsChatService.shared.add(subscriber: self)
    }
}

class MessagesListVC: BaseVC {
    override func accept(new messages: [Message]) {
        print("MessagesListVC accepted 'new messages'")
    }
    
    override func accept(removed messages: [Message]) {
        print("MessagesListVC accepted 'removed messages'")
    }
    
    override func startReceiveMessages() {
        print("MessagesListVC start receive messages")
        super.startReceiveMessages()
    }
}

class ChatVC: BaseVC {
    override func accept(new messages: [Message]) {
        print("ChatVC accepted 'new messages'")
    }
    
    override func accept(removed messages: [Message]) {
        print("ChatVC accepted 'removed messages'")
    }
    
    override func startReceiveMessages() {
        print("ChatVC start receive messages")
        super.startReceiveMessages()
    }
}

class SingletonTest: XCTestCase {
    func testSingleton() {
        let listVC = MessagesListVC()
        let chatVC = ChatVC()
        
        listVC.startReceiveMessages()
        chatVC.startReceiveMessages()
    }
}

SingletonTest.defaultTestSuite.run()
