#Swift Recipes

References:
```bash
1. Swift Functional Programming
2. Programming in Smalltalk, TR87-023, April 15, 1987
```

```bash
1. Threading
2. Functional Programming
3. Comparison
4. Data Types
5. Protocols
5.1 Protocol Declaration
5.2 Protocol Extension
5.2.1 Protocol Extension - Computed Properties
6. Network
6.1 URLSession
6.2 URLRequest
6.3 URLSessionDataTask
6.2 Network Layer Design
7. Lazy Evaluation
8. Algorithms
8.1 Sorts
8.2 Search
9. Design Patterns
9.1 Singleton
9.2 Thread-safe Singleton
10. Properties
10.1 Stored Properties
10.2 Computed Properties
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


Reduce
```swift
// Sum array elements using higher order function

let score = [17, 3, 22, 19, 42]
let sum = score.reduce(0, +)
```

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

Per Apple's Swift Programming Languge Guide - A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. Going back to Objective-C root language Smalltalk "...groups of operations are called protocols".

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

// Protocol optional property and method
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

5.4 Protocol as Type
```swift
import Foundation

enum Powertrain {
    case gasoline
    case diesel
    case electric
    case hybrid
}

protocol Vehicle {
    var make: String { get set }
    var model: String { get set }
    var powertrain: Powertrain { get set }
    init(make: String, model: String, powertrain: Powertrain)
}

final class Sedan: Vehicle {
    var make: String
    var model: String
    var powertrain: Powertrain
    
    init(make: String, model: String, powertrain: Powertrain) {
        self.make = make
        self.model = model
        self.powertrain = powertrain
    }
}

class SUV: Vehicle {
    var make: String
    var model: String
    var powertrain: Powertrain
    
    // non-final class can only be satified by a required initializer
    required init(make: String, model: String, powertrain: Powertrain) {
        self.make = make
        self.model = model
        self.powertrain = powertrain
    }
}

class Truck: Vehicle {
    var make: String
    var model: String
    var powertrain: Powertrain
    
    // non-final class can only be satified by a required initializer
    required init(make: String, model: String, powertrain: Powertrain) {
        self.make = make
        self.model = model
        self.powertrain = powertrain
    }
}

func makeVehicle() {
    let suv = SUV(make: "Rover Tierra", model: "Del Fuego", powertrain: .diesel)
    let sedan = Sedan(make: "AMC", model: "Gremlin", powertrain: .gasoline)
    let truck = Truck(make: "Tesla", model: "Cyber Truck", powertrain: .electric)
    let econo = Sedan(make: "EcoDrive", model: "E-20", powertrain: .hybrid)
    
    var vehicles: [Vehicle] = []
    vehicles.append(suv)
    vehicles.append(sedan)
    vehicles.append(truck)
    vehicles.append(econo)
    
    // Use is to filter vehicle type
    for vehicle in vehicles {
        if vehicle is Truck {
            print("Make: \(vehicle.make)")
        }
    }
    
   // Use where to filter vehicle type
    for vehicle in vehicles where vehicle is Sedan {
        print("Sedan: \(vehicle.model)")
    }
    
    // Downcasting parent type to Sedan type with as keyword
    for vehicle in vehicles {
        if let sedan = vehicle as? Sedan {
            print("Sedan - make: \(sedan.make), model: \(sedan.model), powertrain: \(sedan.powertrain) ")
        }
    }

   // Use is to filter type
    for vehicle in vehicles {
        if vehicle is Sedan {
            print("Sedan - make: \(vehicle.make), model: \(vehicle.model), powertrain: \(vehicle.powertrain) ")
        }
    }
}

makeVehicle()
```


6. Network

6.1 HTTP Method

* Get
* Post
* Put
* Patch         // Analogous with update
* Delete

6.2 URLSession

6.3 URLRequest




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

8. Algorithms

8.1 Sorting

8.1.1 Sort Copy of Input

Algorithm:
* Create an empty array named sorted.
* Find the smallest element in the input array.
* Remove the smallest element from the input array.
* Append this element to the sorted array.
* Repeat until there are no more elements in the input array.

<p align="center">
  <img src="https://github.com/jaminyah/drawio/blob/master/img/sort/sort_copy.svg" alt="sort algo" /> 
</p>

Consider input array = [4, 9, 2, 6, 5] <br/>

end of loop - 1: <br/>
input array = [4, 9, 6, 5] <br/>
sorted array =  [ 2 ] <br/>

end of loop - 2: <br/>
input array = [ 9, 6, 5] <br/>
sorted array = [ 2, 4 ] <br/>

end of loop - 3: <br/>
input array = [ 9, 6 ] <br/>
sorted array = [ 2, 4, 5 ] <br/>

end of loop - 4: <br/>
input array = [ 9 ] <br/>
sorted array = [ 2, 4, 5, 6 ] <br/>

end of loop - 5: <br/>
input array = [] <br/>
sorted array = [ 2, 4, 5, 6, 9] <br/>

```swift
/*
 Language: Swift 4.2
 
 Sort Algorithm:
 1. Create an empty array named sorted.
 2. Find the smallest element in the input array.
 3. Remove the smallest element from the input array.
 4. Append this element to the sorted array.
 5. Repeat until there are no more elements in the input array.
 
 Performance:
 Time complexity: O(n^2)
 Space complexity: O(n)
 
*/

import Foundation

func sort_copy(array: [Int]) -> [Int] {
    var copy = array
    var sorted: [Int] = []
    var minIndex: Int
    
    while copy.count > 0 {
        minIndex = 0
        for i in (0 ..< copy.count) {
            if copy[i] < copy[minIndex] {
                minIndex = i
            }
        }
        sorted.append(copy[minIndex])
        copy.remove(at: minIndex)
    }
    return sorted
}

let a = [7, 4, 9, 2]
let result = sort_copy(array: a)
print(result)
```

8.1.2 Generic type format of sort_copy function
```swift
/*
 * Generic typing of sort_copy function
 * Comparable protocol for less than '<' comparison
 */
func sort_copy<T: Comparable>(array: [T]) -> [T] {
    var copy = array
    var sorted: [T] = []
    var minIndex: Int
    
    while copy.count > 0 {
        minIndex = 0
        for i in (0 ..< copy.count) {
            if copy[i] < copy[minIndex] {       // Comparable protocol
                minIndex = i
            }
        }
        sorted.append(copy[minIndex])
        copy.remove(at: minIndex)
    }
    return sorted
}

let a = [7, 4, 9, 2]
let result = sort_copy(array: a)
print(result)
```

8.1.3 Selection Sort

Algorithm <br/>
1. Compare element at index 0 with element at index 1 <br/>
1.1. If element at index 1 is less than element at index 0, swap the elements <br/>
1.2. Else, compare element at index 0 with element at index 2 ... array length <br/>

2. Compare element at index 1 with element at index 2 <br/>
2.1. If element at index 2 is less than element at index 1, swap the elements <br/>
2.2. Else, compare element at index 1 with element at index 3 ... array length <br/>

3. Compare element at index with element at index + 1 until to the array length <br/>

<p align="center">
  <img src="https://github.com/jaminyah/drawio/blob/master/img/sort/selection_sort.svg" alt="sort algo" /> 
</p>

Consider, input array = [25, 13, 41, 32, 66, 14, 50]

loop - 1: <br/>
25 and 13 are swapped <br/>
a = [13, 25, 41, 32, 66, 14, 50] <br/>

loop - 2: <br/>
25 and 14 are swapped <br/>
a = [13, 14, 41, 32, 66, 25, 50] <br/>

loop - 3: <br/> 
41 and 25 are swapped <br/>
a = [13, 14, 25, 32, 66, 41, 50] <br/>

loop - 4: <br/>
32 needs no swap <br/>
a = [13, 14, 25, 32, 66, 41, 50] <br/>

loop - 5: <br/>
66 and 41 are swapped <br/>
a = [13, 14, 25, 32, 41, 66, 50] <br/>

loop - 6: <br/>
66 and 50 are swapped <br/>
a = [13, 14, 25, 32, 41, 50, 66] <br/>

```swift
/*
 * Selection Sort Algorith
 *
 * Programming language: Swift 4.2
 */

func sort_selection(_ array: inout [Int]) {
    var temp: Int
    
    for i in (0 ..< array.count - 1) {
        for j in ( i+1 ..< array.count) {
            if array[j] < array[i] {
                temp = array[i]
                array[i] = array[j]
                array[j] = temp
            }
        }
    }
}

var a = [43, 11, 8, 23, 9]
sort_selection(&a)
print(a)
```

8.1.4 Selection Sort - Generic, Version 1
```swift
func sort_selection<T: Comparable>(_ array: inout [T]) {
    var temp: T
    
    for i in (0 ..< array.count - 1) {
        for j in (i + 1 ..< array.count) {
            if array[j] < array[i] {
                temp = array[i]
                array[i] = array[j]
                array[j] = temp
            }
        }
    }
}

var a = [40, 11, 8, 23, 9]
sort_selection(&a)
print(a)
```

8.1.5 Selection Sort - Generic, Version 2
```swift
func sort_selection<T: Comparable>(_ array: inout [T]) {
    var temp: T
    var j: Int
    
    for i in (0 ..< array.count - 1) {
        j = i + 1
        while ( j < array.count) {
            if array[j] < array[i] {
                temp = array[i]
                array[i] = array[j]
                array[j] = temp
            }
            j += 1
        }
    }
}

var a = [11, 11, 8, 23, 9]
sort_selection(&a)
print(a)
```

8.1.6 Insertion Sort
```swift
func insertion_sort(_ array: inout [Int]) {
    var temp: Int
    var j: Int
    
    for i in (1 ..< array.count) {
        j = i
        while array[j - 1] > array[j] {
            temp = array[j]
            array[j] = array[j - 1]
            array[j - 1] = temp
            j -= 1
        }
    }
}

var a = [ 9, 36, 21, 22, 16, 10]
insertion_sort(&a)
print(a)
```

8.1.7 Insertion Sort - Generic
```swift
func insertion_sort<T: Comparable>(_ array: inout [T]) {
    var temp: T
    var j: Int
    
    for i in (1 ..< array.count) {
        j = i
        while array[j - 1] > array[j] {
            temp = array[j]
            array[j] = array[j - 1]
            array[j - 1] = temp
            j -= 1
        }
    }
}

var a = [ 9, 36, 21, 22, 16, 10]
insertion_sort(&a)
print(a)
```



9. Design Patterns

9.1 Singleton
```swift
import Foundation

enum LoginState: String {
    case loggedIn = "LoggedIn"
    case loggeout = "LoggedOut"
}

class LoginSingleton {
    
    static let shared = LoginSingleton()
    private init() {}
    
    var loginState: LoginState = .loggeout
    
    func login(_ loginState: LoginState) {
        self.loginState = loginState
    }
}

let appLogin = LoginSingleton.shared
appLogin.login(.loggedIn)

let networkLogin = LoginSingleton.shared
print("Login status: \(networkLogin.loginState.rawValue)")

networkLogin.login(.loggeout)

print("Login status: \(appLogin.loginState.rawValue)")
```

9.2 Thread-safe Singleton
