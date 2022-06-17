/// https://refactoring.guru/design-patterns/bridge
/// 
import XCTest

protocol Content: CustomStringConvertible {
    var title: String { get }
    var images: [UIImage] { get }
}

protocol SharingService {
    func share(content: Content)
}

class FacebookSharingService: SharingService {
    func share(content: Content) {
        print("Service: \(content) was posted to the Facebook")
    }
}

class InstagramSharingService: SharingService  {
    func share(content: Content) {
        print("Service: \(content) was posted to the Instagram", terminator: "\n\n")
    }
}

struct FoodDomainModel: Content {
    var title: String
    var images: [UIImage]
    var calories: Int
    
    var description: String {
        return "Food Model"
    }
}

protocol SharingSupportable {
    func accept(service: SharingService)
    func update(content: Content)
}

class BaseViewController: UIViewController, SharingSupportable {
    fileprivate var shareService: SharingService?
    
    func update(content: Content) {
        print("\(description): user selected a \(content) to share")
        
        shareService?.share(content: content)
    }
    
    func accept(service: SharingService) {
        shareService = service
    }
}

class PhotoViewController: BaseViewController {
    override var description: String {
        return "PhotoViewController"
    }
}

class FeedViewController: BaseViewController {
    override var description: String {
        return "FeedViewController"
    }
}


class BridgeTest: XCTestCase {
    
    func testBridge() {
        print("Client: Pushing Photo View Controller ...")
        push(PhotoViewController())
        
        print()
        
        print("Client: Pushing Feed View Controller ...")
        push(FeedViewController())
    }
    
    func push(_ container: SharingSupportable) {
        let instagram = InstagramSharingService()
        let facebook = FacebookSharingService()
        
        container.accept(service: instagram)
        container.update(content: foodModel)
        
        container.accept(service: facebook)
        container.update(content: foodModel)
    }
    
    var foodModel: Content {
        return FoodDomainModel(title: "This food is so various and delicious",
                               images: [UIImage(), UIImage()],
                               calories: 47)
    }
}

BridgeTest.defaultTestSuite.run()
