package main

import "fmt"

func main() {
    a := [3]string{"a", "b", "c"}
    var b [3]int
    b[0] = 1
    b[1] = 2
    b[2] = 3
    c := []string{"d", "e", "f"}
    for i := 0; i < len(a); i++ {
        fmt.Print(a[i])
    }
    for j := 0; j < len(b); j++ {
        fmt.Print(b[j]);
    }
    for k := 0; k < len(c); k++ {
        fmt.Print(c[k]);
    }
    fmt.Println()
}
