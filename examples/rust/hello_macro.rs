macro_rules! say_hello {
    // '()' indicates that the macro takes no args
    () => (
        // the macro will expand into the contents of this block
        println!("hello macro");
    )
}

fn main() {
    say_hello!();
}
