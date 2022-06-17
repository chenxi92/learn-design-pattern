import XCTest
import UIKit

protocol AuthService {
    func presentAuthFlow(from viewController: UIViewController)
}

class FacebookAuthSDK: AuthService {
    func presentAuthFlow(from viewController: UIViewController) {
        print("Facebook WebView has been shown.")
    }
}

class TwitterAuthSDK {
    func startAuthorization(from viewController: UIViewController) {
        print("Twitter WebView has been shown. Users will be happy :")
    }
}

extension TwitterAuthSDK : AuthService {
    func presentAuthFlow(from viewController: UIViewController) {
        print("The Adapter is called! Redirecting to the original method...")
        self.startAuthorization(from: viewController)
    }
}

class AdapterTest: XCTestCase {
    func testAdapter() {
        print("Starting an authorization via Facebook")
        startAuthorization(with: FacebookAuthSDK())
        
        print("Starting an authorization via Twitter")
        startAuthorization(with: TwitterAuthSDK())
    }
    
    func startAuthorization(with service: AuthService) {
        let topViewController = UIViewController()
        
        service.presentAuthFlow(from: topViewController)
    }
}

AdapterTest.defaultTestSuite.run()

