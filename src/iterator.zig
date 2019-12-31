const Enumerate = @import("enumerate.zig").Enumerate;
const Rev = @import("rev.zig").Rev;
const Take = @import("take.zig").Take;
const Filter = @import("filter.zig").Filter;
const utils = @import("utils.zig");

/// Expect a `next` function to be defined:
/// fn next(self: *Self) ?Item
pub fn Iterator(comptime Self: type, comptime _Item: type) type {
    return struct {
        const builtin = @import("builtin");
        
        comptime {
            switch (@typeInfo(@TypeOf(Self.next))) {
                builtin.TypeId.Fn => |f| {
                    if(f.args[0].arg_type.? != *Self) {
                        @compileError("First argument must be `*Self`");
                    }
                },
                else => @compileError("Expected `fn next(*Self) ?Self.Item`"),
            }
        }

        pub const Item = _Item;

        pub fn enumerate(self: Self) Enumerate(Self) {
            return Enumerate(Self).init(self);
        }

        pub fn rev(self: Self) Rev(Self) {
            return Rev(Self).init(self);
        }

        pub fn take(self: Self, n: usize) Take(Self) {
            return Take(Self).init(self, n);
        }
        
        pub fn filter(self: Self, func: var) Filter(Self, @TypeOf(func)) {
            return Filter(Self, @TypeOf(func)).init(self, func);
        }

        pub usingnamespace utils.mixin_if(
            !@hasDecl(Self, "nth"),
            struct {
                pub fn nth(self: *Self, nth_elem: usize) ?Item {
                    var n = nth_elem;
                    while(self.next()) |elem| {
                        if (n == 0) return elem;
                        n -= 1;
                    }

                    return null;
                }
            }
        );

        pub usingnamespace utils.mixin_if(
            !@hasDecl(Self, "count"),
            struct {
                pub fn count(self: Self) usize {
                    var __self = self;
                    var __count: usize = 0;

                    while(__self.next()) |_| {
                        __count += 1;
                    }

                    return __count;
                }
            }
        );

        pub usingnamespace utils.mixin_if(
            @typeInfo(Item) == builtin.TypeId.Int,
            struct {
                pub fn sum(_self: Self) Item {
                    var self = _self;
                    var _sum = @as(Item, 0);

                    while(self.next()) |elem| {
                        _sum += elem;
                    }

                    return _sum;
                }
            }
        );
    };
}

/// Expects a `next_back` function to be defined:
/// fn next_back(self: *Self) ?Item
pub fn DoubleEndedIterator(comptime Self: type) type {
    return struct {
        pub usingnamespace utils.mixin_if(
            !@hasDecl(Self, "nth_back"),
            struct {
                pub fn nth_back(self: *Self, n: usize) ?Self.Item {
                    var _n = n;
                    while(self.next_back()) |elem| {
                        if (_n == 0) { return elem; }
                        _n -= 1; 
                    }

                    return null;
                }
            }
        );

        //@TODO: Fixme
        // pub usingnamespace Iterator(Self, Self.Item);
    };
}

/// Expects a `len` function to be defined:
/// fn len(self: *const Self) usize
pub fn ExactSizeIterator(comptime Self: type) type {
    return struct {
        usingnamespace Iterator(Self, Self.Item);

        pub fn is_empty(self: *const Self) bool {
            return self.len() == 0;
        }
    };
}

pub fn Range(comptime T: type) type {
    return struct {
        begin: T,
        end: T,

        const Self = @This();

        pub fn init(begin: T, end: T) Self {
            return Self { .begin = begin, .end = end};
        }

        pub fn nth(self: *Self, nth_elem: usize) ?T {
            if (self.begin + nth_elem < self.end) {
                self.begin += nth_elem;
                return self.next();
            }
            return null;
        }

        pub fn next(self: *Self) ?T {
            if (self.begin >= self.end) {
                return null;
            }

            var ret = self.begin;
            self.begin += 1;
            return ret;
        }

        pub fn next_back(self: *Self) ?T {
            if (self.begin < self.end) {
                self.end -= 1;
                return self.end;
            }
            return null;
        }

        pub fn len(self: *const Self) usize {
            return self.end - self.begin;
        }

        pub usingnamespace Iterator(Self, T);
        pub usingnamespace DoubleEndedIterator(Self);
        pub usingnamespace ExactSizeIterator(Self);
    };
}

pub fn Tuple(comptime A: type, comptime B: type) type {
    return struct {
        a: A,
        b: B,
    };
}