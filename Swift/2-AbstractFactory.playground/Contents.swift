/// https://refactoring.guru/design-patterns/abstract-factory
///
import XCTest

enum AuthType {
    case login
    case signUp
}

protocol AuthView {
    typealias AuthAction = (AuthType) -> ()
    
    var contentView: UIView { get }
    var authHandler: AuthAction? { get set }
    
    var description: String { get }
}

class StudentSignUpView: UIView, AuthView {
    private class StudentSignUpContentView: UIView {
    }
    
    var contentView: UIView = StudentSignUpContentView()
    
    var authHandler: AuthAction?
    
    override var description: String {
        return "Student-SignUp-View"
    }
}

class StudentLoginView: UIView, AuthView {
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let signUpButton = UIButton()
    
    var contentView: UIView {
        return self
    }
    
    var authHandler: AuthAction?
    
    override var description: String {
        return "Student-Login-View"
    }
}

class TeacherSignUpView: UIView, AuthView {
    private class TeacherSignUpContentView: UIView {
    }
    
    var contentView: UIView = TeacherSignUpContentView()
    
    var authHandler: AuthAction?
    
    override var description: String {
        return "Teacher-SignUp-View"
    }
}

class TeacherLoginView: UIView, AuthView {
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let signUpButton = UIButton()
    
    var contentView: UIView {
        return self
    }
    
    var authHandler: AuthAction?
    
    override var description: String {
        return "Teacher-Login-View"
    }
}

class AuthViewController: UIViewController {
    fileprivate var contentView: AuthView
    
    init(contentView: AuthView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

class StudentAuthViewController: AuthViewController {
    
}
class TeacherAuthViewController: AuthViewController {
}

protocol AuthViewFactory {
    static func authView(for type: AuthType) -> AuthView
    static func authController(for type: AuthType) -> AuthViewController
}

class StudentAuthViewFactory: AuthViewFactory {
    static func authView(for type: AuthType) -> AuthView {
        print("Student View has been created")
        switch type {
        case .login: return StudentLoginView()
        case .signUp: return StudentSignUpView()
        }
    }
    
    static func authController(for type: AuthType) -> AuthViewController {
        let controller = StudentAuthViewController(contentView: authView(for: type))
        print("Student View Controller has been created")
        return controller
    }
}

class TeacherAuthViewFactory: AuthViewFactory {
    static func authView(for type: AuthType) -> AuthView {
        print("Teacher View has been created")
        switch type {
        case .login: return TeacherLoginView()
        case .signUp: return TeacherSignUpView()
        }
    }
    
    static func authController(for type: AuthType) -> AuthViewController {
        let controller = TeacherAuthViewController(contentView: authView(for: type))
        print("Teacher View Controller has been created")
        return controller
    }
}


class ClientCode {
    private var currentController: AuthViewController?
    
    private lazy var navigationController: UINavigationController = {
        guard let vc = currentController else { return UINavigationController() }
        return UINavigationController(rootViewController: vc )
    }()
    
    private let factoryType: AuthViewFactory.Type
    
    init(factoryType: AuthViewFactory.Type) {
        self.factoryType = factoryType
    }
    
    func presentLogin() {
        let controller = factoryType.authController(for: .login)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func presentSignUp() {
        let controller = factoryType.authController(for: .signUp)
        navigationController.pushViewController(controller, animated: true)
    }
}

class AbstractFactoryTest: XCTestCase {
    func testAbstractFactory() {
        #if teacherMode
            let clientCode = ClientCode(factoryType: TeacherAuthViewFactory.self)
        #else
            let clientCode = ClientCode(factoryType: StudentAuthViewFactory.self)
        #endif
        
        clientCode.presentLogin()
        print("Login screen has been presented")
        
        print()
        
        clientCode.presentSignUp()
        print("Sign up screen has been presented")
    }
}

AbstractFactoryTest.defaultTestSuite.run()

