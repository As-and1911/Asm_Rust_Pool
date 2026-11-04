use std::io::{self, Write};

fn other(){
   let msg = "\nI'm a Rustacean!";
   writeln!(io::stdout(), "Hello World! {}", msg).unwrap();
}

fn main() {
    let msg = b"Hello, Epitech!\n";
    io::stdout().write_all(msg).unwrap();
    other();
}