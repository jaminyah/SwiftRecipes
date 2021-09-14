
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