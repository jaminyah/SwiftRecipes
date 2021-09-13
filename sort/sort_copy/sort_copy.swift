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
    var copyCount = copy.count
    
    while copyCount > 0 {
        minIndex = 0
        for i in (0 ..< copyCount) {
            if copy[i] < copy[minIndex] {
                minIndex = i
            }
        }
        sorted.append(copy[minIndex])
        copy.remove(at: minIndex)
        copyCount = copy.count                  // Avoid multiple computation of count
    }
    return sorted
}

let a = [7, 4, 9, 2]
let result = sort_copy(array: a)
print(result)