const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const DoubleEndedIterator = iterator.DoubleEndedIterator;
const ExactSizeIterator = iterator.ExactSizeIterator;

const Tuple = iterator.Tuple;

const builtin = @import("builtin");
const TypeId = builtin.TypeId;

pub fn Zip(comptime A: type, comptime B: type) type {
    return struct {
        pub const Item = Tuple(A.Item, B.Item);

        const Self = @This();

        a: A,
        b: B,

        pub fn init(a: A, b: B) Self {
            return Self{
                .a = a,
                .b = b,
            };
        }

        pub fn next(self: *Self) ?Item {
            var a_next = self.a.next() orelse return null;
            var b_next = self.b.next();

            // We have to deinit A.Item if b yielded null.
            if (b_next == null) {
                const A_ITEM = switch (@typeInfo(A.Item)) {
                    TypeId.Struct => A.Item,
                    TypeId.Enum => A.Item,
                    TypeId.Union => A.Item,
                    else => return null,
                };

                if (@hasDecl(A_ITEM, "deinit")) {
                    a_next.deinit();
                    return null;
                }
            }

            // We know that `b_next` can not be null here.
            return Item{ .a = a_next, .b = b_next orelse unreachable };
        }

        pub fn next_back(self: *Self) ?Item {
            var a_next_back = self.a.next_back() orelse return null;
            var b_next_back = self.b.next_back();

            // We have to deinit A.Item if b yielded null.
            if (b_next_back == null) {
                const A_ITEM = switch (@typeInfo(A.Item)) {
                    TypeId.Struct => A.Item,
                    TypeId.Enum => A.Item,
                    TypeId.Union => A.Item,
                    else => return null,
                };

                if (@hasDecl(A_ITEM, "deinit")) {
                    a_next.deinit();
                    return null;
                }
            }

            // We know that `b_next_back` can not be null here.
            return Item{ .a = a_next_back, .b = b_next_back orelse unreachable };
        }

        pub usingnamespace Iterator(Self);
        pub usingnamespace DoubleEndedIterator(Self);
    };
}

const testing = @import("std").testing;

test "zip" {
    const Range = iterator.Range;

    var range = Range(usize).init(0, 100).zip(Range(usize).init(0, 3));

    var next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 0, .b = 0 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 1, .b = 1 });

    next = range.next();
    testing.expectEqual(next, Tuple(usize, usize){ .a = 2, .b = 2 });

    next = range.next();
    testing.expectEqual(next, null);
}

test "exhausted zip" {
    const Range = iterator.Range;

    const Resource = struct {
        flag: *bool,

        const Self = @This();

        fn init(flag: *bool) Self {
            return Self{ .flag = flag };
        }

        fn deinit(self: *Self) void {
            self.flag.* = true;
        }
    };

    const ResourceIterator = struct {
        pub const Item = Resource;
        const Self = @This();

        flag: *bool,

        fn init(flag: *bool) Self {
            return Self{ .flag = flag };
        }

        fn next(self: *Self) ?Item {
            return Resource.init(self.flag);
        }

        usingnamespace Iterator(Self);
    };

    var flag = false;
    var zipped = ResourceIterator.init(&flag).zip(Range(usize).init(0, 1));

    var next = zipped.next() orelse @panic("Iterator returned null");
    testing.expectEqual(next.b, 0);

    testing.expectEqual(zipped.next(), null);

    testing.expectEqual(flag, true);
}
