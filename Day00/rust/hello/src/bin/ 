use std::io::{self, Write}; 
/*
    double inclusion of std::io unit and std::io::Write interface 
    This line can also be the followings : use std::io;
                                            use std::io::Write;
*/


//Hello world in idiomatic rust 
fn other(){
   let msg = "\nI'm a Rustacean!";
   writeln!(io::stdout(), "Hello World! {}", msg).unwrap(); 
   
   /* 
        writeln! macro that uses format string like a printf function
        that takes a file descriptor as first parameter.
   */
}

fn main() {
    let msg = b"Hello, Epitech!\n";
    io::stdout().write_all(msg).unwrap(); 
    
    //.write_all method of the io::stdout::Write interface
    
    other();
}