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