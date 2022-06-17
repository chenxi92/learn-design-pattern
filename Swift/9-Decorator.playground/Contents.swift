/// https://refactoring.guru/design-patterns/decorator
///
import XCTest
import UIKit

protocol ImageEditor: CustomStringConvertible {
    func apple() -> UIImage
}

class ImageDecorator: ImageEditor {
    private var editor: ImageEditor
    
    required init(_ editor: ImageEditor) {
        self.editor = editor
    }
    
    func apple() -> UIImage {
        print(editor.description + " applies changes")
        return editor.apple()
    }
    
    var description: String {
        return "ImageDecorator"
    }
}

extension UIImage: ImageEditor {
    func apple() -> UIImage {
        return self
    }
    
    open override var description: String {
        return "Image"
    }
}

class BaseFilter: ImageDecorator {
    fileprivate var filter: CIFilter?
    
    init(editor: ImageEditor, filterName: String) {
        self.filter = CIFilter(name: filterName)
        super.init(editor)
    }
    
    required init(_ editor: ImageEditor) {
        super.init(editor)
    }
    
    override func apple() -> UIImage {
        let image = super.apple()
        let context = CIContext(options: nil)
        
        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        
        guard let output = filter?.outputImage else { return image }
        guard let coreImage = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: coreImage)
    }
    
    override var description: String {
        return "BaseFilter"
    }
}

class BlurFilter: BaseFilter {
    required init(_ editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIGaussianBlue")
    }
    
    func update(radius: Double) {
        filter?.setValue(radius, forKey: "inputRadius")
    }
    
    override var description: String {
        return "BlurFilter"
    }
}

class ColorFilter: BaseFilter {
    required init(_ editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIColorControls")
    }
    
    func update(saturation: Double) {
        filter?.setValue(saturation, forKey: "inputSaturation")
    }
    
    func update(brightness: Double) {
        filter?.setValue(brightness, forKey: "inputBrightness")
    }
    
    func update(contrast: Double) {
        filter?.setValue(contrast, forKey: "inputContrast")
    }
    
    override var description: String {
        return "ColorFilter"
    }
}

class Resizer: ImageDecorator {
    private var xScale: CGFloat = 0
    private var yScale: CGFloat = 0
    private var hasAlpha = false
    
    convenience init(_ editor: ImageEditor, xScale: CGFloat = 0, yScale: CGFloat = 0, hasAlpha: Bool = false) {
        self.init(editor)
        self.xScale = xScale;
        self.yScale = yScale
        self.hasAlpha = hasAlpha
    }
    
    required init(_ editor: ImageEditor) {
        super.init(editor)
    }
    
    override func apple() -> UIImage {
        let image = super.apple()
        
        print("Resizer applying x: \(xScale), y: \(yScale)")
        let size = image.size.applying(CGAffineTransform(scaleX: xScale, y: yScale))
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? image
    }
    
    override var description: String {
        return "Resizer"
    }
}

class DecoratorTest: XCTestCase {
    
    func testDecorator() {
        let image = loadImage()
        
        print("Client: set up an editors stack")
        let resizer = Resizer(image, xScale: 0.2, yScale: 0.2)
        
        let blurFilter = BlurFilter(resizer)
        blurFilter.update(radius: 2)
        
        let corlorFilter = ColorFilter(blurFilter)
        corlorFilter.update(contrast: 0.53)
        corlorFilter.update(brightness: 0.12)
        corlorFilter.update(saturation: 4)
        
        clientCode(editor: corlorFilter)
    }
    
    func clientCode(editor: ImageEditor) {
        let image = editor.apple()
        
        print("Client: all changes have been applied for \(image)")
    }
    
    func loadImage() -> UIImage {

        let urlString = "https://refactoring.guru/images/content-public/logos/logo-new-3x.png"

        /// Note:
        /// Do not download images the following way in a production code.

        guard let url = URL(string: urlString) else {
            fatalError("Please enter a valid URL")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Cannot load an image")
        }

        guard let image = UIImage(data: data) else {
            fatalError("Cannot create an image from data")
        }
        return image
    }
}

DecoratorTest.defaultTestSuite.run()
