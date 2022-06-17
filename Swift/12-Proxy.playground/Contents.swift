/// https://refactoring.guru/design-patterns/proxy
///
import XCTest
import Foundation

enum AccessField {
    case basic
    case bankAccount
}

protocol ProfileService {
    typealias Success = (Profile) -> ()
    typealias Failure = (LocalizedError) -> ()
    
    func loadProfile(with fields: [AccessField], success: Success, failure: Failure)
}

class ProfileProxy: ProfileService {
    private let keychain = Keychain()
    
    func loadProfile(with fields: [AccessField], success: (Profile) -> (), failure: (LocalizedError) -> ()) {
        if let error = checkAccess(for: fields) {
            failure(error)
        } else {
            keychain.loadProfile(with: fields, success: success, failure: failure)
        }
    }
    
    private func checkAccess(for fields: [AccessField]) -> LocalizedError? {
        if fields.contains(.bankAccount) {
            switch BiometricsService.checkAccess() {
            case .authorized: return nil
            case .denied: return ProfileError.accessDenied
            }
        }
        return nil
    }
}

class Keychain: ProfileService {
    func loadProfile(with fields: [AccessField], success: (Profile) -> (), failure: (LocalizedError) -> ()) {
        var profile = Profile()
        
        for field in fields {
            switch field {
            case .basic:
                let info = loadBasicProfile()
                profile.firstName = info[Profile.Keys.firstName.raw]
                profile.lastName = info[Profile.Keys.lastName.raw]
                profile.email = info[Profile.Keys.email.raw]
            case .bankAccount:
                profile.bankAccount = loadBankAccount()
            }
        }
        
        success(profile)
    }
    
    private func loadBasicProfile() -> [String: String] {
        return [
            Profile.Keys.firstName.raw: "Vasya",
            Profile.Keys.lastName.raw: "Pupkin",
            Profile.Keys.email.raw: "vasya.pupkin@gmail.com"
        ]
    }
    
    private func loadBankAccount() -> Bankaccount {
        return Bankaccount(id: 12345, amount: 999)
    }
}

class BiometricsService {
    enum Access {
        case authorized
        case denied
    }
    
    static func checkAccess() -> Access {
        /// The service uses Face ID, Touch ID or a plain old password to
        /// determin whether the current user is an owner of the device.
        
        /// Let's assume that in our example a user forgot a passowrd :)
        return .denied
    }
}

struct Profile {
    enum Keys: String {
        case firstName
        case lastName
        case email
    }
    
    var firstName: String?
    var lastName: String?
    var email: String?
    
    var bankAccount: Bankaccount?
}

struct Bankaccount {
    var id: Int
    var amount: Double
}

enum ProfileError: LocalizedError {
    case accessDenied
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access is denied. Please enter a valid password"
        }
    }
}

extension RawRepresentable {
    var raw: Self.RawValue {
        return rawValue
    }
}

extension LocalizedError {
    var localizedSummary: String {
        return errorDescription ?? ""
    }
}

class ProxyTest: XCTestCase {
    func testProxy() {
        print("Client: Loading a profile WITHOUT proxy")
        loadBasicProfile(with: Keychain())
        loadProfileWithBankAccount(with: Keychain())
        
        print("\nClient: Let's load a profile WITH proxy")
        loadBasicProfile(with: ProfileProxy())
        loadProfileWithBankAccount(with: ProfileProxy())
    }
    
    func loadBasicProfile(with service: ProfileService) {
        service.loadProfile(with: [.basic]) { profile in
            print("Client: Basic profile is loaded")
        } failure: { error in
            print("Client: Cannot load a basic profile")
            print("Client: Error: " + error.localizedSummary)
        }
    }
    
    func loadProfileWithBankAccount(with service: ProfileService) {
        service.loadProfile(with: [.basic, .bankAccount]) { profile in
            print("Client: Basic profile with a bank account is loaded")
        } failure: { error in
            print("Client: Cannot load a profile with a bank account")
            print("Client: Error: " + error.localizedSummary)
        }

    }
}

ProxyTest.defaultTestSuite.run()
