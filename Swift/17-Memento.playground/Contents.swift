/// https://refactoring.guru/design-patterns/memento
///
import XCTest


protocol Memento: CustomStringConvertible {
    var text: String { get }
    var date: Date { get }
}

extension UITextView {
    struct TextViewMemonto: Memento {
        let text: String
        let date: Date = Date()
        
        let textColor: UIColor?
        let selectedRange: NSRange
        
        var description: String {
            let time = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
            let color = String(describing: textColor)
            return "Text: \(text)\n" + "Date: \(time.description)\n" + "Color: \(color)\n" + "Range: \(selectedRange)\n\n"
        }
    }
    
    var memento: Memento {
        return TextViewMemonto(text: text, textColor: textColor, selectedRange: selectedRange)
    }
    
    func restore(with memento: Memento) {
        guard let textViewMemento = memento as? TextViewMemonto else { return }
        
        text = textViewMemento.text
        textColor = textViewMemento.textColor
        selectedRange = textViewMemento.selectedRange
    }
}

class UndoStack: CustomStringConvertible {
    private lazy var mementos = [Memento]()
    private let textView: UITextView
    
    init(_ textView: UITextView) {
        self.textView = textView
    }
    
    func save() {
        mementos.append(textView.memento)
    }
    
    func undo() {
        guard !mementos.isEmpty else  { return }
        textView.restore(with: mementos.removeLast())
    }
    
    var description: String {
        return mementos.reduce("", { $0 + $1.description })
    }
}

class MementoTest: XCTestCase {
    func testMemento() {
        let textView = UITextView()
        let undoStack = UndoStack(textView)
        
        textView.text = "First Change"
        undoStack.save()
        
        textView.text = "Second Change"
        undoStack.save()
        
        textView.text = (textView.text ?? "") + " & Third Change"
        textView.textColor = .red
        undoStack.save()
        
        print(undoStack)
        
        print("Client: Perfom Undo operation 2 times\n")
        undoStack.undo()
        undoStack.undo()
        
        print(undoStack)
    }
}

MementoTest.defaultTestSuite.run()

