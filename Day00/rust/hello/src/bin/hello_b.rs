
extern "C" {
    fn write(fd: i32, buff: *const u8, count: usize) -> isize;
}
/*
extern "C": indicate to Rust to use standard ABI (Application Binary Interface)
    of C for linkage

*const u8 : Rust syntax for constant raw 
        pointer (strict equivalent of const char * or const void * in C)
*/

fn main() {
    let msg = b"Hello, Epitech!\n";

    unsafe {
        write(1, msg.as_ptr(), msg.len());
    }
}

/*
    msg.as_ptr() : this method convert the reference of the rust byte string
    (&[u8]) into raw pointer (*const u8) understandable by C.

    unsafe { ... } : It's the necessary key word. Through it you say to the compiler "I know
    what i'm doing and i take the responsibility if the pointer is invalid or if the program freeze"
 */

 /*
    Number of syscalls: 66

    Number of sys_write call: 1
 */