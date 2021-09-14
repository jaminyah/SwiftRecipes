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