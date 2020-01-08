const builtin = @import("builtin");
const utils = @import("utils.zig");
const has_fn = utils.has_fn;
const has_item = utils.has_item;

pub fn is_iterator(comptime I: type) bool {
    return has_item(I, "Item") and
        has_fn(I, "next", fn (*I) ?I.Item);
}

pub fn is_double_ended_iterator(comptime I: type) bool {
    return is_iterator(I) and
        has_fn(I, "next_back", fn (*I) ?I.Item);
}

pub fn is_exact_size_iterator(comptime I: type) bool {
    return is_iterator(I) and
        has_fn(I, "len", fn (*const I) usize);
}

pub fn is_integral(comptime N: type) bool {
    return @typeInfo(N) == builtin.TypeId.Int;
}

pub fn requires(comptime B: bool) void {
    if (!B) {
        @compileError("Failed to meet requirements");
    }
}
