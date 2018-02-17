package main

import "fmt"

func main() {
    for i := 0; i < 4; i++ {
        fmt.Print(i)
    }

    var i uint32
    for i = 4; i < 8; i++ {
        fmt.Print(i)
    }

    // while / loop until break
    for {
        break
    }

    var j int = 5
    for j > 0 {
        j -= 1
        continue
        fmt.Println("not reached")
    }

    fmt.Println()
}
