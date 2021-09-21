#Swift Recipes

References:
```bash
1. Swift Functional Programming
2. Programming in Smalltalk, TR87-023, April 15, 1987
3. https://theswiftdev.com/lazy-initialization-in-swift/
4. https://www.uraimo.com/2017/05/07/all-about-concurrency-in-swift-1-the-present/
5. http://www.thinkingparallel.com/2006/09/09/mutual-exclusion-with-locks-an-introduction/
```

```bash
1. Threading
2. NSOperationQueue
3. Functional Programming
4. Comparison
5. Data Types
6. Protocols
7.1 Protocol Declaration
7.2 Protocol Extension
7.2.1 Protocol Extension - Computed Properties
8. Network
8.1 URLSession
8.2 URLRequest
8.3 URLSessionDataTask
9.2 Network Layer Design
10. Lazy Evaluation
11. Algorithms
11.1 Sorts
11.2 Search
12. Design Patterns
13.1 Singleton
14.2 Thread-safe Singleton
15. Properties
15.1 Stored Properties
15.2 Computed Properties
16 Strings
17 Arrays
18 Closures
19 UIKit
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

1.2 Basic Threading

1.2.1 Extending the Thread base class

Thread Properties
```swift
// Obtaining thread properties

import Foundation

class BasicThread: Thread {
    
    // Starting the thread executes the main function
    override func main() {
        print("Starting thread execution ...")
        Thread.sleep(forTimeInterval: 10)
        print("Thread slept for  10 seconds, and exited.")
    }
}

// Instantiating the thread
var basicThread = BasicThread()
print("Is main thread: \(basicThread.isMainThread)")

basicThread.name = "t1"
if let tid = basicThread.name {
    print("Thread id: \(tid)")
}

//basicThread.start()
```
Output:
```bash
Is main thread: false
Thread id: t1
```

Starting the Thread
```swift
// Executing the thread main function

import Foundation

class BasicThread: Thread {
    
    // Starting the thread executes the main function
    override func main() {
        print("Starting thread execution ...")
        Thread.sleep(forTimeInterval: 10)
        print("Thread slept for 10 seconds, and exited.")
    }
}

// Instantiating the thread
var basicThread = BasicThread()
print("Is main thread: \(basicThread.isMainThread)")

basicThread.name = "t1"
if let tid = basicThread.name {
    print("Thread id: \(tid)")
}

// Start thread execution
basicThread.start()
```
Output:
```bash
Is main thread: false
Thread id: t1
Starting thread execution ...
Thread slept for 10 seconds, and exited.
```

Main Thread Properties
```swift
import Foundation

class BasicThread: Thread {
    
    // Starting the thread executes the main function
    override func main() {
        print("Starting thread execution ...")
        Thread.sleep(forTimeInterval: 10)
        print("Thread slept for 10 seconds, and exited.")
    }
}

// Instantiating the thread
var basicThread = BasicThread()
print("Is main thread: \(basicThread.isMainThread)")

// Obtain main thread property
print("Main thread: \(Thread.isMainThread)")

basicThread.name = "t1"
if let tid = basicThread.name {
    print("Thread id: \(tid)")
}

// Start thread execution
basicThread.start()
```

Output:
```bash
Is main thread: false
Main thread: true
Thread id: t1
Starting thread execution ...
Thread slept for 10 seconds, and exited.
```

1.3 Thread Synchronization

Thread synchronization prevent corruption of data when that data is acted upon by multiple threads. The following software constructs facilitate thread synchronization: 
* Mutex / Locks - lock(), unlock()
* Semaphores - binary, counting
* Condition Variables
* Monitors - mutex + condition variable

1.3.1 Mutual Exclusion - mutex

At the assembly language level, three steps are needed in order to increment the value of a variable. 
* Step 1 - Load the value from the variable's memory address into a CPU register.
* Step 2 - Increment the register value by 1
* Stpe 3 - Write the updated register value into the variable's memory address.
```bash
// Assembly pseudocode for incrementing i
mov i, R1
add 1, R1
mov R1, i
```
Increment variable on two threads without mutual exclusion.
```swift
// Increment variable on two threads

import Foundation

var sum = 0

var t1 = Thread {
    print("t1 initial sum: \(sum)")
    sum += 1
    print("t1 incremented sum: \(sum)")
}

var t2 = Thread {
    print("t2 initial sum: \(sum)")
    sum += 1
    print("t2 incremented sum: \(sum)")
}

t1.start()
t2.start()

// wait for t1 and t2 to complete
Thread.sleep(forTimeInterval: 4)
print("Final sum: \(sum)")
```
Output: 
```bash
t1 initial sum: 0
t2 initial sum: 0
t1 incremented sum: 2
t2 incremented sum: 2
Final sum: 2
```
Increasing the expected count to 2000.
```swift
// Increment variable on two threads

import Foundation

var sum = 0

var t1 = Thread {
    print("t1 initial sum: \(sum)")
    for _ in (0 ..< 1000) {
        sum += 1
    }
    print("t1 incremented sum: \(sum)")
}

var t2 = Thread {
    print("t2 initial sum: \(sum)")
    for _ in (0 ..< 1000) {
        sum += 1
    }
    print("t2 incremented sum: \(sum)")
}

t1.start()
t2.start()

// main thread sleeps
Thread.sleep(forTimeInterval: 4)
print("Final sum: \(sum)")
```
```bash
t1 initial sum: 0
t2 initial sum: 0
t1 incremented sum: 1895
t2 incremented sum: 1997
Final sum: 1997
```

Implementing Mutual Exclusion with NSLock
* Only one thread at a time can acquire the lock.
* Only the thread acquired the lock can perform unlock.
* Other threads will be blocked until the thread in unlocked.
* Locks are <em>unfair</em>. Acquiring the lock is not based on any order.

```swift
// Increment variable on two threads with mutual exclusion
// to obtain the expected value of sum.

import Foundation

var sum = 0
let nslock = NSLock()

var t1 = Thread {
    print("t1 initial sum: \(sum)")
    nslock.lock()

    // increment sum 1000 times
    for _ in (0 ..< 1000) {
        sum += 1
    }
    nslock.unlock()
    print("t1 incremented sum: \(sum)")
}

var t2 = Thread {
    print("t2 initial sum: \(sum)")
    nslock.lock()

    // increment sum 1000 times
    for _ in (0 ..< 1000) {
        sum += 1
    }
    nslock.unlock()
    print("t2 incremented sum: \(sum)")
}

t1.start()
t2.start()

// main thread sleeps
Thread.sleep(forTimeInterval: 4)
print("Final sum: \(sum)")
```
Output:
```bash
t1 initial sum: 0
t2 initial sum: 0
t1 incremented sum: 1000
t2 incremented sum: 2000
Final sum: 2000
```

Subclassing Thread class
```swift
import Foundation

var sum = 0
let nslock = NSLock()

// subclassing requires overriding main()
class MyThread: Thread {
    var myText: String
    
    init(myText: String) {
        self.myText = myText
    }
    
    override func main() {
        print("\(myText) \(sum)")
        nslock.lock()
        
        // increment sum 1000 times
        for _ in (0 ..< 1000) {
            sum += 1
        }
        nslock.unlock()
        print("t1 incremented sum: \(sum)")
    }
}

var t2 = Thread {
    print("t2 initial sum: \(sum)")
    nslock.lock()
    
    // increment sum 1000 times
    for _ in (0 ..< 1000) {
        sum += 1
    }
    nslock.unlock()
    print("t2 incremented sum: \(sum)")
}

let t1 = MyThread(myText: "t1 initial sum:")
t1.start()
t2.start()

// main thread sleeps
Thread.sleep(forTimeInterval: 4)
print("Final sum: \(sum)")
```
Output:
```bash
t1 initial sum: 0
t2 initial sum: 0
t2 incremented sum: 1000
t1 incremented sum: 2000
Final sum: 2000
```

1.3.2 Recursive Lock - NSRecursive Lock
Unlike NSLock, NSRecursive lock allows the same thread to acquire the lock multiple times without creating a deadlock condition.
```swift
import Foundation

let recursiveLock = NSRecursiveLock()
var a = 2
var b = 4
var sum = 0

func product() {
    recursiveLock.lock()
    print("Acquiring lock again.")
    sum += a * b
    recursiveLock.unlock()
    print("Function releases lock.")
}

var thread = Thread {
 
    print("Thread acquires lock.")
    recursiveLock.lock()
    sum += a + b
    product()
    recursiveLock.unlock()
    print("Thread execution is complete.")
}

thread.start()
Thread.sleep(forTimeInterval: 3)
print("Sum: \(sum)")
```

1.3.3 NSConditionLock

NSConditionLock object can be used to acquire and release a lock when program defined conditions are met. Condition is of type Int.

Declaration
```bash
class NSConditionLock: NSObject
```
```swift
import Foundation

let EMPTY = 0
let FULL = 5

let fuelTank = NSConditionLock(condition: EMPTY)
var fuelQuantity = 0

class FuelThread: Thread {
    
    override func main(){
 
        print("Filling the tank ...")
        fuelTank.lock(whenCondition: EMPTY)         // Acquire the lock when condition is EMPTY
        
        for gallon in 1 ..< 6 {
            print("Fuel quantity: \(gallon)")
            fuelQuantity = gallon
        }
        print()
        fuelTank.unlock(withCondition: FULL)        // Release the lock and set the condition to FULL
 
    }
}

class DriveThread: Thread {
    
    override func main(){
        print("Waiting for fuel ...")
        fuelTank.lock(whenCondition: FULL)          // Acquire the lock when condition is FULL
        
        for miles in 1 ..< 6 {
            fuelQuantity -= 1
            print("Miles driven: \(miles), fuel remaining: \(fuelQuantity)")
 
        }
        print()
        fuelTank.unlock(withCondition: EMPTY)       // Release the lock and set the condition to EMPTY
    }
}

let fueling = FuelThread()
let driving = DriveThread()

fueling.start()
driving.start()
```

1.3.4 NSCondition

> "A condition object acts as both a lock and a checkpoint in a given thread. The lock protects your code while it tests the condition and performs the task triggered by the condition. The checkpoint behavior requires that the condition be true before the thread proceeds with its task. While the condition is not true, the thread blocks. It remains blocked until another thread signals the condition object." 

```swift
import Foundation

let condition = NSCondition()
var readyState = false
var bulletCount = 0

class MazagineLoader: Thread {
 
    override func main() {
        print("Magazine is Loading ...")
        
        condition.lock()
        while readyState == true {
            condition.wait()
        }
        
        for _ in (0 ..< 20) {
            bulletCount += 1
            print("loader - bullet count: \(bulletCount)")
            
            if bulletCount % 10 == 0 {
                readyState = true
                condition.signal()
                condition.unlock()
                break
            }
        }
    }
}

class Cannon: Thread {
    
    override func main() {
        condition.lock()
        while readyState == false {
            print("Cannon is waiting ...")
            condition.wait()
        }
        
        print("Cannon is Firing ...")
        for _ in (0 ..< 5) {
            bulletCount -= 1
            print("cannon - bullet count: \(bulletCount)")
        }
        readyState = false
        condition.unlock()
    }
}

let loader = MazagineLoader()
let cannon = Cannon()
loader.start()
cannon.start()
```
Output:
```bash
Magazine is Loading ...
Cannon is waiting ...
loader - bullet count: 1
loader - bullet count: 2
loader - bullet count: 3
loader - bullet count: 4
loader - bullet count: 5
loader - bullet count: 6
loader - bullet count: 7
loader - bullet count: 8
loader - bullet count: 9
loader - bullet count: 10
Cannon is Firing ...
cannon - bullet count: 9
cannon - bullet count: 8
cannon - bullet count: 7
cannon - bullet count: 6
cannon - bullet count: 5
```



1.3.2 Semaphore

Semaphores, developed by Dijkstra, provides access control to shared data. Semaphores are of two forms, Binary Semaphores and Counting Semaphores.





2. NSOperationQueue
```swift
// Basic OperationQueue

import Foundation

class NetworkTask: Operation {
    override func main() {
        print("Executing a network task.")
    }
}

class ImageFilterTask: Operation {
    override func main() {
        print("Executing an image filter task.")
    }
}

let networkTask = NetworkTask()
let filterImageTask = ImageFilterTask()

networkTask.completionBlock = {
    print("Network task is complete.")
}

filterImageTask.completionBlock = {
    print("Image filter task is complete.")
}

let queue = OperationQueue()
queue.addOperation(networkTask)
queue.addOperation(filterImageTask)
```
Output:
```bash
Executing a network task.
Executing an image filter task.
Image filter task is complete.
Network task is complete.
```

3. Functional Programming
3.1 Higher Order Function

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

7.1 Avoid using implicitly unwrapped optionals in UIKit ViewController
```swift
//  Use lazy var instead of implicity unwrapped optionals

import UIKit

class ViewController: UIViewController {
    
    lazy var label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))

    override func loadView() {
        super.loadView()
        self.view.addSubview(self.label)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.label.text = "Hello, World!"
        self.label.textColor = .black
        self.label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.label.center = CGPoint(x: 160, y: 285)
        self.label.textAlignment = .center
    }
}
```

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

8.1.8 Bubble Sort
```swift
func bubbleSort(_ array: inout [Int]) {
    var temp: Int

    for i in (0 ..< array.count) {
        for j in (0 ..< array.count - 1 - i) {
            if array[j] > array[j + 1] {
                temp = array[j]
                array[j] = array[j + 1]
                array[j + 1] = temp
            }
        }
    }
}

var a = [5, 3, 1, 2, 6,4]
bubbleSort(&a)
print(a)
```
8.1.9 Bubble Sort - Generic
```swift
func bubbleSort<T: Comparable>(_ array: inout [T]) {
    var temp: T

    for i in (0 ..< array.count) {
        for j in (0 ..< array.count - 1 - i) {
            if array[j] > array[j + 1] {
                temp = array[j]
                array[j] = array[j + 1]
                array[j + 1] = temp
            }
        }
    }
}

var a = [25, 33, 11, 29, 17, 24]
bubbleSort(&a)
print(a)
```

8.1.10 Merge Sort
```swift
func mergeSort(_ array: inout [Int]) {
    
    if array.count > 1 {
        let mid = array.count / 2
        
        var leftArr = Array(array[0 ..< mid])
        var rightArr = Array(array[mid ..< array.count])
        
        mergeSort(&leftArr)
        mergeSort(&rightArr)
        
        // merge
        var i = 0
        var j = 0
        var k = 0
        
        while i < leftArr.count && j < rightArr.count {
            if leftArr[i] < rightArr[j] {
                array[k] = leftArr[i]
                i += 1
            } else {
                array[k] = rightArr[j]
                j += 1
            }
            k += 1
        }
        
        // un-merged left array values
        while i < leftArr.count {
            array[k] = leftArr[i]
            i += 1
            k += 1
        }
        
        // un-merged right array values
        while j < rightArr.count {
            array[k] = rightArr[j]
            j += 1
            k += 1
        }
    }
}

var a = [2, 3, 5, 1, 7, 4, 4, 4, 2, 6, 1]
mergeSort(&a)
print(a)
```

8.1.11 Merge Sort - Generic
```swift
func mergeSort<T: Comparable>(_ array: inout [T]) {
    
    if array.count > 1 {
        let mid = array.count / 2
        
        var leftArr = Array(array[0 ..< mid])
        var rightArr = Array(array[mid ..< array.count])
        
        mergeSort(&leftArr)
        mergeSort(&rightArr)
        
        // merge
        var i = 0
        var j = 0
        var k = 0
        
        while i < leftArr.count && j < rightArr.count {
            if leftArr[i] < rightArr[j] {
                array[k] = leftArr[i]
                i += 1
            } else {
                array[k] = rightArr[j]
                j += 1
            }
            k += 1
        }
        
        // un-merged left array values
        while i < leftArr.count {
            array[k] = leftArr[i]
            i += 1
            k += 1
        }
        
        // un-merged right array values
        while j < rightArr.count {
            array[k] = rightArr[j]
            j += 1
            k += 1
        }
    }
}

var a = [2.8, 3.0, 5.1, 1.8, 7.6, 4.9, 4.8, 4.3, 2.0, 6.3, 1.8]
mergeSort(&a)
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


10. Properties

Swift instance properties come in three flavors. Stored, computed and type properties. Stored properties can be read-write variables that are declared with the var keyword. Stored properties can also be <em>constant stored property </em> and is declared with the <em>let</em> keyword. Type properties are associated with the type and not a particular instance of the type.

10.1 Stored Property
 A stored property is a variable or constant that is declared in a class, struct or enum. Stored properties are assigned either during the execution of the init method or by assigning a value when the property is declared. "Constant properties must always have a value before initialization is complete." As a result they can be declared with the lazy modifier.

> Stored properties can only be associated with classes and structures.

10.2 Lazy Stored Property
"A lazy stored property is a property whose initial value isn't calculated until the first time it is used." Lazy properties increase performance in cases where the property is rarely read.
> Lazy properties are always declared as a variable, with keyword var. This is because <em>initialization</em> of the object must be complete before the lazy property can be accessed.

10.2.1 Computed properties 
Computed properties can be associated with classes, structures, and enumerations (enums).
> Computed properties cannot be designated as lazy.
```swift
//  Polynomial.swift
//  LazyApp
//  Created on 9/17/21.

import Foundation

class Polynomial {
    
    var x: Int      // stored property, x is assigned a value during init method execution
    var y: Int      // stored property, y is assigned a value during init method execution
    
    // Error: computed property cannot be lazy
    lazy var fx: Int {
        print("fx compute")
        return x * x + y
    }
       
    init(x: Int, y: Int) {
        print("init x, y")
        self.x = x
        self.y = y
    }
}
```
10.2.2 Lazy property with Immediately Invoked Closure
```swift
//  Polynomial.swift
//  LazyApp
//  Created on 9/17/21.

import Foundation

class Polynomial {
    
    var x: Int
    var y: Int
    var z: Double = 3.8         // z is assigned at var declaration
    
    // computed property
    var fx: Int {
        print("fx compute")
        return x * x + y
    }
    
    // lazy applied to immediately invoked closure
    lazy var gx: Int = {
        print("gx compute")
        return 2 * x + y
    }()
    
    init(x: Int, y: Int) {
        print("init x, y")
        self.x = x
        self.y = y
    }
}

//  ViewController.swift
//  LazyApp
//  Created by macbook on 9/16/21.

import UIKit

class ViewController: UIViewController {
    
    let poly = Polynomial(x: 4, y: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fx = poly.fx
        print("view controller fx: \(fx)")
        
       // let gx = poly.gx
       // print("view controller gx: \(gx)")
    }
}
```

Since, gx is not used, it is not computed.
```bash
// Output:
init x, y
fx compute
view controller fx: 19
```

10.2.3 Compute lazy property on first use
```swift
//  Polynomial.swift
//  LazyApp
//
//  Created on 9/17/21.

import Foundation

class Polynomial {
    
    var x: Int
    var y: Int
    
    // computed property
    var fx: Int {
        print("fx compute")
        return x * x + y
    }
    
    // lazy applied to immediately invoked closure
    lazy var gx: Int = {
        print("gx compute")
        return 2 * x + y
    }()
    
    init(x: Int, y: Int) {
        print("init x, y")
        self.x = x
        self.y = y
    }
}

//  ViewController.swift
//  LazyApp
//  Created by macbook on 9/16/21.

import UIKit

class ViewController: UIViewController {
    
    let poly = Polynomial(x: 4, y: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fx = poly.fx
        print("view controller fx: \(fx)")
        
       let gx = poly.gx
       print("view controller gx: \(gx)")
    }
}
```

Since, gx is used, it is computed.
```bash
init x, y
fx compute
view controller fx: 19
gx compute
view controller gx: 11
```
10.2.4 Lazy computed properties are only calcuated once.
```swift
//  Polynomial.swift
//  LazyApp
//  Created on 9/17/21.

import Foundation

class Polynomial {
    
    var x: Int
    var y: Int
    
    // computed property
    var fx: Int {
        print("fx compute")
        return x * x + y
    }
    
    // lazy applied to immediately invoked closure
    lazy var gx: Int = {
        print("gx compute")
        return 2 * x + y
    }()
    
    init(x: Int, y: Int) {
        print("init x, y")
        self.x = x
        self.y = y
    }
}

/  ViewController.swift
//  LazyApp
//  Created on 9/16/21.

import UIKit

class ViewController: UIViewController {
    
    let poly = Polynomial(x: 4, y: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fx = poly.fx
        print("view controller fx: \(fx)")
        
        let gx = poly.gx
        print("view controller gx: \(gx)")
        
        // lazy property is only computed once
        poly.x = 14
        poly.y = 13
        
        let gx2 = poly.gx
        print("view controller gx2: \(gx2)")
    }
}
```

Output:
```bash
init x, y
fx compute
view controller fx: 19
gx compute
view controller gx: 11
view controller gx2: 11
```

10.2.5 Computed properties are computed on each call
```swift
//  Polynomial.swift
//  LazyApp
//  Created on 9/17/21.

import Foundation

class Polynomial {
    
    var x: Int
    var y: Int
    
    // computed property
    var fx: Int {
        print("fx compute")
        return x * x + y
    }
    
    // lazy applied to immediately invoked closure
    lazy var gx: Int = {
        print("gx compute")
        return 2 * x + y
    }()
    
    var hx: Int {
        return 2 * x + y + 7
    }
    
    init(x: Int, y: Int) {
        print("init x, y")
        self.x = x
        self.y = y
    }
}
```
Output:
```bash
init x, y
fx compute
view controller fx: 19
gx compute
view controller gx: 11
view controller hx: 18

Change x, y
fx compute
view controller fx: 209
view controller gx: 11
view controller hx: 48
```


10.2.6 Type Property

* Stored type properties must always have a default value
* Stored type properties are lazily initialized on their first access and so do not require the lazy keyword
* Stored type properties are thread-safe and so can be accessed by multiple threads at the same time.
* Stored type properties are declared as part to the type's definition.
* Stored type properties are declared with the static keyword.
* Computed type property can be declared with the class keyword to allow subclasses to override the implementation.

10.2.7 Getters and Setters

10.2.7.1 Computed Property with Custom Getter and Setter
Standard Syntax
```swift
var <property-name>: <data-type> {
    get {

    }
    set (<newValue-implicit> or <customName>) {

    }
}
```

```swift
struct Position {
    x: Double = 0.0
    y: Double = 0.0
    var coordinate: String {
        get {

        }
        set (newValue) {

        }
    }
}
```



11. UIKit

11.1 Add UILabel - Programmatic
```swift
//  Reference:
//  https://stackoverflow.com/questions/24081731/how-to-create-uilabel-programmatically-using-swift
//  ViewLabel.swift

import UIKit

class ViewLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }
    
    func initLabel() {
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.textAlignment = .center
    }
}

// ViewController.swift
// Reference:
// https://theswiftdev.com/lazy-initialization-in-swift/

import UIKit

class ViewController: UIViewController {
    
    var viewLabel: UILabel = ViewLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    var viewLabel2: UILabel = ViewLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
 
    override func loadView() {
        super.loadView()
        self.view.addSubview(viewLabel)
        self.view.addSubview(viewLabel2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewLabel.text = "Hello, World!"
        viewLabel.center = CGPoint(x: 160, y: 285)
        
        viewLabel2.text = "Hello, Label!"
        viewLabel2.center = CGPoint(x: 160, y: 385)
    }
}
```

11.2 Add UILabel with Closure

```swift
//  Reference:
//  https://theswiftdev.com/lazy-initialization-in-swift/

import UIKit

class ViewController: UIViewController {
    
    // self-executing closure
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Hello, World!"
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        return label
    }()
    
    override func loadView() {
        super.loadView()
        
        // [self label] executes closure
        self.view.addSubview(self.label)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```

10.3 Factory method of Initialization
```swift
// Reference: https://theswiftdev.com/lazy-initialization-in-swift/

import UIKit

class ViewController: UIViewController {
    
    lazy var label: UILabel = self.createUILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.label)
    }
    
    private func createUILabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Hello, World!"
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        return label
    }
}
```


11.4 Static Factory Initializer
```swift
// Reference: https://theswiftdev.com/lazy-initialization-in-swift/
//
import UIKit

class ViewController: UIViewController {
    
    lazy var label = UILabel.createUILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.label)
    }
}

extension UILabel {
    static func createUILabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))

        // programmatically instantiating UILabel set to false
        // default is true.
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Hello, World!"
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        return label
    }
}
```

18. Closures
* Self is not needed when referencing instance properties.
