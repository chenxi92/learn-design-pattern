/// https://refactoring.guru/design-patterns/flyweight
///

import XCTest
import UIKit
enum Type: String {
    case cat
    case dog
}


struct Animal: Equatable {
    let name: String
    let country: String
    let type: Type
    
    var appearance: Appearance {
        return AppearanceFactory.appearance(for: type)
    }
}

struct Appearance: Equatable {
    let photos: [UIImage]
    let backgroundColor: UIColor
}

extension Animal: CustomStringConvertible {

    var description: String {
        return "\(name), \(country), \(type.rawValue)"
    }
}

extension Appearance: CustomStringConvertible {

    var description: String {
        return "photos: \(photos.count), \(backgroundColor)"
    }
}

class AppearanceFactory {
    
    private static var cache = [Type: Appearance]()
    
    static func appearance(for key: Type) -> Appearance {
        guard cache[key] == nil else {
            print("AppearanceFactory: Reusing an existing \(key.rawValue)-appearance.")
            return cache[key]!
        }
        
        print("AppearanceFactory: Can't find a cached \(key.rawValue)-object, creating a new one.")
        
        switch key {
        case .cat:
            cache[key] = catInfo
        case .dog:
            cache[key] = dogInfo
        }
        
        return cache[key]!
    }
}

extension AppearanceFactory {
    
    private static var catInfo: Appearance {
        return Appearance(photos: [UIImage()], backgroundColor: .red)
    }
    
    private static var dogInfo: Appearance {
        return Appearance(photos: [UIImage(), UIImage()], backgroundColor: .blue)
    }
}

class Cell {
    private var animal: Animal?
    
    func update(with animal: Animal) {
        self.animal = animal
        let type = animal.type.rawValue
        let photos = "photos \(animal.appearance.photos.count)"
        print("Cell: Updating an appearance of a \(type)-cell: \(photos)\n")
    }
}

class FlyweightTest: XCTestCase {
    func testFlyweight() {
        let maineCoon = Animal(name: "Maine Coon", country: "USA", type: .cat)
        let sphynx = Animal(name: "Sphynx", country: "Egypt", type: .cat)
        let bulldog = Animal(name: "Bulldog", country: "England", type: .dog)
        
        print("Client: I created a number of objects to display")

        print("Client: Let's show animals for the 1st time\n")
        display(animals: [maineCoon, sphynx, bulldog])

        print("\nClient: I have a new dog, let's show it the same way!\n")

        let germanShepherd = Animal(name: "German Shepherd", country: "Germany", type: .dog)
        display(animals: [germanShepherd])
    }
    
    func display(animals: [Animal]) {
        let cells = loadCells(count: animals.count)
        
        for index in 0..<animals.count {
            cells[index].update(with: animals[index])
        }
    }
    
    func loadCells(count: Int) -> [Cell] {
        return Array(repeating: Cell(), count: count)
    }
}

//Cell()
FlyweightTest.defaultTestSuite.run()

