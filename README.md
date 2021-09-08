#Swift Recipes

Reference:
1. Swift Functional Programming

```bash
1. Threading
2. Functional Programming
3. Comparison
4. Data Types
5. Protocols
6. Network
7. Lazy Evaluation

```

1. Command Line Threading - Linux
```bash
$ mkdir CLThread
$ cd CLThread
$ swift package init --type executable
```
In the code listing, the contents of the print statement will not appear on the screen if the 
main thread does not wait until the background thread has finished executing. Since the background thread does not block the main thread, 
control is returned immediately to the main thread. Without the sleep delay, the main thread has
no further task to perform and so the program exits before the background thread completes the for-in loop. As a result, the print statement
may not execute.

```swift
import Foundation

let bkgThread = Thread {
    for i in 0...100 {
        print("loop: \(i)")
    }
}
bkgThread.start()

// The main thread sleeps for 2 second 
// allowing time for the for-in loop to execute.
Thread.sleep(forTimeInterval: 2)
```

Another option is to use the RunLoop to keep the main thread running.
```swift
import Foundation

let bkgThread = Thread {
    for i in 0...100 {
        print("loop: \(i)")
    }
}
bkgThread.start()

// Keep the main thread alive so that the program does not exit.
RunLoop.current.run()
```

2. Functional Programming

2.1 Higher Order Function

These are functions that take a function as the argument or that return a function as the result.

* .map {}
* .flapMap {}
* .compactMap {}
* .reduce {}
* .filter {}
* .sorted {}
* .forEach {}

3. Comparsion

3.1 Optional Binding vs Optional Chaining

3.2. ViewController vs View

3.3 try vs try? vs try!

3.4 as vs as? vs as!

3.5 Stored vs Computed Properties

3.6 Any vs Any? vs Any!

ViewControllers are classes with a lifecycle. The View, however, is a canvas for displaying UI components.

4. Data Types

4.1 Int / UInt
4.2 Float
4.3 Double
4.4 Bool
4.5 String
4.6 Character



4.7 Optional Data Type

```swift
enum Optional {
    case some(Wrapped)
    case none
}
```

Declaration
```swift
@frozen enum Optional<Wrapped>      /* frozen as immutable in the future */
```

Optional type used as an enum with cases some(Wrapped) and none.
```swift
let midName: Optional<String> = nil

// Optional binding of wrapped value midName to name using "if let"
if let name = midName {
    print("name: \(name)")
} else {
    print("No middle name.")
}

let firstName: String? = Optional.some("Mary")
if let firstName = firstName {
    print("first name: \(firstName)")
}

let lastName: String? = Optional.none
if let lastName = lastName {
    print("last name: \(lastName)")
} else {
    print("No last name.")
}

// Optional binding of wrapped value using "guard let"
func showMidName(_ midName: Optional<String>) {

    guard let name = midName else {
        print("No middle name.")
        return
    }
    print("name: \(name)")
}
showMidName(nil)

// Guard let using none-void return value
func showMidName(_ midName: Optional<String>) -> String {

    guard let name = midName else {
        return "No middle name"
    }
    return name.uppercased()
}

var name: String = showMidName("Warner")
print("name: \(name)")
```

Using guard let Optional binding in a class method
```swift
class Freshman {
    
    var id: Int
    var firstName: String
    var midName: String? = nil
    var lastName: String
 
    
    // title is read-only property
    var title: String {
        return "Freshman"
    }
    
    init(id: Int, firstName: String, midName: String?, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.midName = midName
        self.lastName = lastName
    }
    
    convenience init(id: Int, firstName: String, lastName: String) {
        self.init(id: id, firstName: firstName, midName: nil, lastName: lastName)
    }
    
    func fullName() -> String {
        guard let midName = midName else {
            return firstName + " " + lastName
        }
        return firstName + " " + midName + " " + lastName
    }
}

// Case - 1: All three names are available
let freshman = Freshman(id: 1, firstName: "Willy", midName: "James", lastName: "Escobar")
print("Title: \(freshman.title) - Full name: \(freshman.fullName())")


// Case - 2: Only first and last names are available
let freshman2 = Freshman(id: 2, firstName: "Jackie", lastName: "Kruger")
print("Title: \(freshman2.title) - Full name: \(freshman2.fullName())")
```

Long form of type Optional shows that Optional types are generic data types. The wrapped type in the example below is of type String.
```swift
let midName: Optional<String> = nil

if let name = midName {
    print("name: \(name)")
} else {
    print("No middle name.")
}
```

Shortened form of type Optional.
```swift
let midName: String? = nil

if let name = midName {
    print("name: \(name)")
} else {
    print("No middle name.")
}
```
4.8 Tuple

5. Protocols

Per Apple's Swift Programming Languge Guide - A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality.

Subclassing provides and inheritance class hierarchy relationship between classes. A child class inherits all the properties, methods and class initializers of its parent class. Note that a struct can conform to protocols thus giving it features similar to classes. Structs however and be passed in to functions as value types thus reducing side-effects.

5.1 Property requirements for Protocol Declaration

* Property type
* Property is read only / read-write { get set } property
* Property is stored / computed type
* Static modifier where applicable

5.2 Method Requirements for Protocol Declaration

* Cannot have default parameter values
* Static modifier where applicable

```swift
/*
* Mutating - Prefix a method with keyword "mutating" if the 
* method within the struct can modify struct instance properties. 
*/

import Foundation

protocol ColorPalet {
    var sheetColor: String { get set }
    
    mutating func updateColorPref(sColor: String) -> String
}

struct myPalet: ColorPalet {
    var sheetColor: String
    
    mutating func updateColorPref(sColor: String) -> String {
        sheetColor = sColor + " Green"
        return sheetColor
    }
}

var colorPalet = myPalet(sheetColor: "Satin ")
let color = colorPalet.updateColorPref(sColor: "Blue")
print(color)
```


5.3 Optional property and functions in Protocols

```swift
// UIColor extension:
// https://stackoverflow.com/questions/44672594/is-it-possible-to-get-color-name-in-swift

import UIKit

extension UIColor {
    var name: String? {
        switch self {
            case UIColor.black: return "black"
            case UIColor.darkGray: return "darkGray"
            case UIColor.lightGray: return "lightGray"
            case UIColor.white: return "white"
            case UIColor.gray: return "gray"
            case UIColor.red: return "red"
            case UIColor.green: return "green"
            case UIColor.blue: return "blue"
            case UIColor.cyan: return "cyan"
            case UIColor.yellow: return "yellow"
            case UIColor.magenta: return "magenta"
            case UIColor.orange: return "orange"
            case UIColor.purple: return "purple"
            case UIColor.brown: return "brown"
            default: return nil
        }
    }
}

@objc protocol CarProtocol {
    var make: String { get set }
    var model: String { get set }
    var color: UIColor { get set }
    @objc optional var cylinders: Int { get set }
    
    func drive()
    @objc optional func race()
}

class Sedan: CarProtocol {
    var make: String
    var model: String
    var color: UIColor
    
    init(make: String, model: String, color: UIColor) {
        self.make = make
        self.model = model
        self.color = color
    }
    
    func drive() {
        print("I am driving the \(color.name ?? "") company car of make \(make) and model \(model).")
    }
}

class SportCar: CarProtocol {
    var make: String
    var model: String
    var cylinders: Int
    var color: UIColor
    
    init(make: String, model: String, cylinders: Int, color: UIColor) {
        self.make = make
        self.model = model
        self.cylinders = cylinders
        self.color = color
    }
    
    func drive() {
        print("I am driving the \(color.name ?? "") company car of make \(make) and model \(model).")
    }
    
    func race() {
        print("I am racing the \(color.name ?? "") car of make \(make) and model \(model) with \(cylinders) cylinders.")
    }
}

let companyCar = Sedan(make: "Ford", model: "Fiesta", color: .white)
companyCar.drive()

let sportCar = SportCar(make: "Jaguar", model: "XJR", cylinders: 8, color: .green)
sportCar.race()
```




6. Network

6.1 HTTP Method

* Get
* Post
* Put
* Patch         // Analogous with update
* Delete


7. Lazy Evaluation

Use the map function to multiple each value in an array by 3, then extract the last element. Eager evaluation results in all elements being processed
then the last element is returned.
```swift
let array = [11, 22, 33, 44]
let first = array.map({$0 * 3}).last!
print(first)
```

Use the map function to multiply only the last element in the array by 3, then return the last element. Lazy evaluation results in only the last element
being processed and returned.
```swift
let array = [1, 2, 3, 4]
let last = array.lazy.map({$0 * 3}).last!
print(last)
```