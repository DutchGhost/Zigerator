/// Returns `T` if the flag was true, and empty struct otherwise.
pub fn mixin_if(comptime flag: bool, comptime T: type) type {
    if(flag) {
        return T;
    } else {
        return struct {};
    }
}