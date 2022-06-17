/// https://refactoring.guru/design-patterns/facade
///

import XCTest

private extension UIImageView {
    
    func downloadImage(at url: URL?) {
        print("Start downloading...")
        
        let placeholder = UIImage(named: "placeholder")
        
        ImageDownloader().loadImage(at: url, placeholder: placeholder) { image, error in
            print("Handle an image...")
            
            self.image = image
        }
    }
}

private class ImageDownloader {
    typealias Completion = (UIImage, Error?) -> ()
    typealias Progress = (Int, Int) -> ()
    
    func loadImage(at url: URL?, placeholder: UIImage? = nil, progress: Progress? = nil, completion: Completion) {
        /// ... Set up a network stack
        /// ... Downloading an image
        /// ....
        completion(UIImage(), nil)
    }
}

class FacadeTest: XCTestCase {
    
    func testFacede() {
        let imageView = UIImageView()
        
        print("Let's set an image for the image over")
        
        clientCode(imageView)
        
        print("Image has been set")
        
        XCTAssert(imageView.image != nil)
    }
    
    fileprivate func clientCode(_ imageView: UIImageView) {
        let url = URL(string: "www.example.com/logo")
        imageView.downloadImage(at: url)
    }
}

FacadeTest.defaultTestSuite.run()

