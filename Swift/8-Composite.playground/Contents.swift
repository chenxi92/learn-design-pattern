/// https://refactoring.guru/design-patterns/composite
///
import XCTest

protocol Theme: CustomStringConvertible {
    var backgroundColor: UIColor { get }
}
protocol ButtonTheme: Theme {
    var textColor: UIColor { get }
    var highlightedColor: UIColor { get }
}
protocol LabelTheme: Theme {
    var textColor: UIColor { get }
}

struct DefaultButtonTheme: ButtonTheme {
    var textColor: UIColor = .red
    
    var highlightedColor: UIColor = .white
    
    var backgroundColor: UIColor = .black
    
    var description: String {
        return "Default Button Theme"
    }
}
struct NightButtonTheme: ButtonTheme {
    var textColor: UIColor = .white
    var highlightedColor: UIColor = .red
    var backgroundColor: UIColor = .black
    var description: String {
        return "Night Button Theme"
    }
}

struct DefaultLabelTheme: LabelTheme {
    var textColor: UIColor = .red
    var backgroundColor: UIColor = .black
    var description: String {
        return "Default Label Theme"
    }
}
struct NightLabelTheme: LabelTheme {
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    var description: String {
        return "Night Label Theme"
    }
}

protocol Component {
    func accept<T: Theme>(theme: T)
}

extension Component where Self: UIViewController {
    func accept<T: Theme>(theme: T) {
        view.accept(theme: theme)
        view.subviews.forEach({ $0.accept(theme: theme)})
    }
}
extension UIView: Component {}
extension UIViewController: Component {}

extension Component where Self: UIView {
    
    func accept<T>(theme: T) where T : Theme {
        print("\t\(description): has applied \(theme.description)")
        
        backgroundColor = theme.backgroundColor
    }
}

extension Component where Self: UILabel {
    
    func accept<T>(theme: T) where T : LabelTheme {
        print("\t\(description): has applied \(theme.description)")
        
        backgroundColor = theme.backgroundColor
        textColor = theme.textColor
    }
}

extension Component where Self: UIButton {
    func accept<T>(theme: T) where T : ButtonTheme {
        print("\t\(description): has aplied \(theme.description)")
        
        backgroundColor = theme.backgroundColor
        setTitleColor(theme.textColor, for: .normal)
        setTitleColor(theme.highlightedColor, for: .highlighted)
    }
}

class WelcomeViewController: UIViewController {
    class ContentView: UIView {
        var titleLabel = UILabel()
        var actionButton = UIButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        func setup() {
            addSubview(titleLabel)
            addSubview(actionButton)
        }
    }
    
    override func loadView() {
        view = ContentView()
    }
}

extension WelcomeViewController {
    override var description: String {
        return "WelcomeViewController"
    }
}

extension WelcomeViewController.ContentView {
    override var description: String { return "ContentView" }
}

extension UIButton {

    open override var description: String { return "UIButton" }
}

extension UILabel {

    open override var description: String { return "UILabel" }
}

class CompositeTest: XCTestCase {
    func testComposite() {
        print("\nClient: Applying 'default' theme for 'UIButton'")
        apply(theme: DefaultButtonTheme(), for: UIButton())
        
        print("\nClient: Applying 'night' theme for 'UIButton'")
        apply(theme: NightButtonTheme(), for: UIButton())
        
        print("\nClient: Let's use View Controller as a composite!")
        
        print("\nClient: Applying 'night button' theme for 'WelcomeViewController'")
        apply(theme: NightButtonTheme(), for: WelcomeViewController())
        print()
        
        print("\nClient: Applying 'night label' theme for 'WelcomeViewController'...")
        apply(theme: NightLabelTheme(), for: WelcomeViewController())
        print()

        /// Default Theme
        print("\nClient: Applying 'default button' theme for 'WelcomeViewController'...")
        apply(theme: DefaultButtonTheme(), for: WelcomeViewController())
        print()

        print("\nClient: Applying 'default label' theme for 'WelcomeViewController'...")
        apply(theme: DefaultLabelTheme(), for: WelcomeViewController())
        print()
    }
    
    func apply<T: Theme>(theme: T, for component: Component) {
        component.accept(theme: theme)
    }
}

CompositeTest.defaultTestSuite.run()
