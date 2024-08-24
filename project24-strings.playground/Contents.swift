import UIKit
import Foundation

var name = "Taylor"

let letter = name[name.index(name.startIndex, offsetBy: 3)]

name.isEmpty

let password = "12345"

password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    func capitalizedFirst() -> String {
        guard let firstLetter = self.first else { return self}
        return firstLetter.uppercased() + self.dropFirst()
    }
}


let congrat = "congratulation!"
print(congrat.capitalizedFirst())

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

extension String {
    func containsAny(of array: [String]) -> Bool {
        for elem in array {
            if self.contains(elem) {
                return true
            }
        }
        
        return false
    }
}

let languages = ["Python", "Scala", "Swift"]
input.containsAny(of: languages)

//input.contains(where: <#T##(Character) throws -> Bool#>)
languages.contains(where: input.contains)

let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

let attributedString = NSAttributedString(string: string, attributes: attributes)

let mutString = NSMutableAttributedString(string: string)
mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

let warning = "You SHOULD learn about SOLID principles, but SHOULD NOT take them for a dogme"
let attWarning = NSMutableAttributedString(string: warning)

extension String {
    func withPrefix(_ prefix: String) -> String {
        return prefix + self
    }
}

let base = "World"
let message = base.withPrefix("Hello ")

print(message)


extension String {
    func isNumeric() -> Bool {
        return Double(self) != nil
    }
}

let someNumber = "12.32"
let someMessage = "It's a nice day today"

print(someNumber.isNumeric())
print(someMessage.isNumeric())

extension String {
    func lines() -> [String] {
        return self.components(separatedBy: .newlines)
    }
}

let monolog = """
it's a nice day today
birds are singing
flowers are blooming
on days like these
kids like you
SHOULD BE BURNING IN HELL
"""

let lines = monolog.lines()

for line in lines {
    print(line)
}
