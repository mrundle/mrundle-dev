package main

import "fmt"
import "log"
import "os"
import "path"

func main() {
    var a = "string"
    // type is inferred
    var b = 1
    // you can declare multiple at once
    var c, d int = 2, 3
    // declare and initialize shorthnad
    e := 4
    // uninitialized variables are zeroed,
    // but must have a type
    var f string
    // "assert" via log.Fatal
    if (f != "") { log.Fatal("fatal") }
    // print the executable name
    fmt.Println(path.Base(os.Args[0]))
    // avoid unused variable errors
    _, _, _, _, _ = a, b, c, d, e
}
