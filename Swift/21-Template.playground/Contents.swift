/// https://refactoring.guru/design-patterns/template-method
///
import XCTest
import AVFoundation
import CoreLocation
import Photos

class PermissionAccessor: CustomStringConvertible {
    typealias Completion = (Bool) -> ()
    
    func requestAccessIfNeeded(_ completion: @escaping Completion) {
        guard !hasAccess() else {
            completion(true)
            return
        }
        
        willReceiveAccess()
        
        requestAccess { status in
            status ? self.didReceiveAccess() : self.didRejectAccess()
            
            completion(status)
        }
    }
    
    func requestAccess(_ completion: @escaping Completion) {
        fatalError("Should be overridden")
    }
    
    func hasAccess() -> Bool {
        fatalError("Should be overridden")
    }
    
    var description: String {
        return "PermissionAccessor"
    }
    
    /// Hooks
    func willReceiveAccess() {}
    func didReceiveAccess() {}
    func didRejectAccess() {}
}

class CameraAccessor: PermissionAccessor {
    
    override func requestAccess(_ completion: @escaping Completion) {
        AVCaptureDevice.requestAccess(for: .video) { status in
            completion(status)
        }
    }
    
    override func hasAccess() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    override var description: String {
        return "Camera"
    }
}

class MicrophoneAccessor: PermissionAccessor {
    override func requestAccess(_ completion: @escaping Completion) {
        AVAudioSession.sharedInstance().requestRecordPermission { status in
            completion(status)
        }
    }
    
    override func hasAccess() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    override var description: String {
        return "Microphone"
    }
}

class PhotoLibraryAccessor: PermissionAccessor {
    override func requestAccess(_ completion: @escaping Completion) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(status == .authorized)
        }
    }
    
    override func hasAccess() -> Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
    }
    
    override var description: String {
        return "PhotoLibrary"
    }
    
    override func didReceiveAccess() {
        print("PhotoLibrary Accessor: Receive access. Updating analytics...")
    }
    
    override func didRejectAccess() {
        print("PhotoLibrary Accessor: Rejected with access. Updating analytics...")
    }
}

class TemplateMethodTest: XCTestCase {
    func test() {
        let accessors = [CameraAccessor(), MicrophoneAccessor(), PhotoLibraryAccessor()]
        accessors.forEach { accessor in
            accessor.requestAccessIfNeeded { status in
                let message = status ? "You have access to " : "You do not have access to "
                print(message + accessor.description + "\n")
            }
        }
    }
}

TemplateMethodTest.defaultTestSuite.run()
