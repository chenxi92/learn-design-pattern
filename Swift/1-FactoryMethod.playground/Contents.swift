/// https://refactoring.guru/design-patterns/factory-method

import XCTest

protocol Projector {
    var currentPage: Int { get }
    func present(info: String)
    func sync(with projector: Projector)
    func update(with page: Int)
}
extension Projector {
    func sync(with projector: Projector) {
        projector.update(with: currentPage)
    }
}

class WifiProjector: Projector {
    var currentPage = 0
    
    func present(info: String) {
        print("Info is presented over Wifi: \(info)")
    }
    
    func update(with page: Int) {
        currentPage = page
    }
}

class BluetoothProjector: Projector {
    var currentPage = 0
    
    func present(info: String) {
        print("Info is presented over Bluetooth: \(info)")
    }
    
    func update(with page: Int) {
        currentPage = page
    }
}


protocol ProjectorFactory {
    func createProjector() -> Projector
    func syncedProjector(with projector: Projector) -> Projector
}
extension ProjectorFactory {
    func syncedProjector(with projector: Projector) -> Projector {
        let newProjector = createProjector()
        newProjector.sync(with: projector)
        return newProjector
    }
}

class WifiFactory: ProjectorFactory {
    func createProjector() -> Projector {
        return WifiProjector()
    }
}

class BluetoothFactory: ProjectorFactory {
    func createProjector() -> Projector {
        return BluetoothProjector();
    }
}

private class ClientCode {
    private var currentProjector: Projector?
    
    func present(info: String, with factory: ProjectorFactory) {
        guard let projector = currentProjector else {
            let projector = factory.createProjector()
            projector.present(info: info)
            self.currentProjector = projector
            return
        }
        self.currentProjector = factory.syncedProjector(with: projector)
        self.currentProjector?.present(info: info)
    }
}

class FatoryMethodTest: XCTestCase {
    func testFactoryMethod() {
        let info = "Very important info of the presentation"

        let clientCode = ClientCode()

        clientCode.present(info: info, with: WifiFactory())

        clientCode.present(info: info, with: BluetoothFactory())
    }
}


FatoryMethodTest.defaultTestSuite.run()
