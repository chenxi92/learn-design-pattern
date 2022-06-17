/// https://refactoring.guru/design-patterns/visitor
///
import XCTest

protocol Notification: CustomStringConvertible {
    func accept(visitor: NotificationPolicy) -> Bool
}

struct Email {
    let emailOfSender: String
    
    var description: String {
        return "Email"
    }
}

struct SMS {
    let phoneNumberOfSender: String
    
    var description: String {
        return "SMS"
    }
}

struct Push {
    let usernameOfSender: String
    
    var description: String {
        return "Push"
    }
}

extension Email: Notification {
    func accept(visitor: NotificationPolicy) -> Bool {
        return visitor.isTurnedOn(for: self)
    }
}

extension SMS: Notification {
    func accept(visitor: NotificationPolicy) -> Bool {
        return visitor.isTurnedOn(for: self)
    }
}

extension Push: Notification {
    func accept(visitor: NotificationPolicy) -> Bool {
        return visitor.isTurnedOn(for: self)
    }
}

protocol NotificationPolicy: CustomStringConvertible {
    func isTurnedOn(for email: Email) -> Bool
    func isTurnedOn(for sms: SMS) -> Bool
    func isTurnedOn(for push: Push) -> Bool
}

class NightPolicyVisitor: NotificationPolicy {
    func isTurnedOn(for email: Email) -> Bool {
        return false
    }
    
    func isTurnedOn(for sms: SMS) -> Bool {
        return true
    }
    
    func isTurnedOn(for push: Push) -> Bool {
        return false
    }
    
    var description: String {
        return "Night Policy Visitor"
    }
}

class DefaultPolicyVisitor: NotificationPolicy {
    func isTurnedOn(for email: Email) -> Bool {
        return true
    }
    
    func isTurnedOn(for sms: SMS) -> Bool {
        return true
    }
    
    func isTurnedOn(for push: Push) -> Bool {
        return true
    }
    
    var description: String {
        return "Default Policy Visitor"
    }
}

class BlackListVisitor: NotificationPolicy {
    
    private var bannedEmails = [String]()
    private var bannedPhotos = [String]()
    private var bannedUsernames = [String]()
    
    init(emails: [String], phones: [String], usernames: [String]) {
        self.bannedEmails = emails
        self.bannedPhotos = phones
        self.bannedUsernames = usernames
    }
    
    func isTurnedOn(for email: Email) -> Bool {
        return bannedEmails.contains(email.emailOfSender)
    }
    
    func isTurnedOn(for sms: SMS) -> Bool {
        return bannedPhotos.contains(sms.phoneNumberOfSender)
    }
    
    func isTurnedOn(for push: Push) -> Bool {
        return bannedUsernames.contains(push.usernameOfSender)
    }
    
    var description: String {
        return "Black List Visitor"
    }
}

class VisitorTest: XCTestCase {
    func test() {
        let email = Email(emailOfSender: "some@email.com")
        let sms = SMS(phoneNumberOfSender: "+3806700000")
        let push = Push(usernameOfSender: "Spammer")
        
        let notifications: [Notification] = [email, sms, push]
        
        clientCode(handle: notifications, with: DefaultPolicyVisitor())
        clientCode(handle: notifications, with: NightPolicyVisitor())
    }
    
    func clientCode(handle notifications: [Notification], with policy: NotificationPolicy) {
        let blackList = createBlackList()
        print("\nClient: Using \(policy.description) and \(blackList.description)")
        
        notifications.forEach { notification in
            guard !notification.accept(visitor: blackList) else {
                print("\tWARNING: " + notification.description + " is in a black list")
                return
            }
            
            if notification.accept(visitor: policy) {
                print("\t" + notification.description + " notification will be shown")
            } else {
                print("\t" + notification.description + " notification will be silenced")
            }
        }
    }
    
    private func createBlackList() -> BlackListVisitor {
        return BlackListVisitor(emails: ["banned@email.com"], phones: ["000000000", "123425232"], usernames: ["Spammer"])
    }
}

VisitorTest.defaultTestSuite.run()
