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