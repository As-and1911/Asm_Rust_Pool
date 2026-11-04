extern "C" {
    fn write(fd: i32, buff: *const u8, count: usize) -> isize;
}

fn main() {
    let msg = b"Hello, Epitech!\n";

    unsafe {
        write(1, msg.as_ptr(), msg.len());
    }
}