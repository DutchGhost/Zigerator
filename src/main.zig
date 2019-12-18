usingnamespace @import("iterator.zig");

const testing = @import("std").testing;

test "range iterate + enumerate" {
    var range = Range(usize).init(0, 4).enumerate();

    var next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 0, .b = 0});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 1, .b = 1});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 2, .b = 2});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 3, .b = 3});

    next = range.next();
    testing.expectEqual(next, null);
}

test "range iterate + enumerate" {
    var range = Range(usize).init(0, 4).enumerate().rev();

    var next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 3, .b = 3});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 2, .b = 2});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 1, .b = 1});

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize) {.a = 0, .b = 0});

    next = range.next();
    testing.expectEqual(next, null);

    testing.expectEqual(range.is_empty(), true);
}

test "range nth" {
    var range = Range(usize).init(0, 10);

    var nth = range.nth(3);
    testing.expectEqual(nth, 3);

    var next = range.next();
    testing.expectEqual(next, 4);
}

test "take" {
    var range = Range(usize).init(0, 100).rev().take(2);

    var next = range.next();
    testing.expectEqual(next, 99);

    next = range.next();
    testing.expectEqual(next, 98);
    
    testing.expectEqual(range.next(), null);
}