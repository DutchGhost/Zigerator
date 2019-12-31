const itermodule = @import("iterator.zig");
const Iterator = itermodule.Iterator;
const DoubleEndedIterator = itermodule.DoubleEndedIterator;
const utils = @import("utils.zig");

pub fn Filter(comptime Iter: type, comptime F: type) type {
    return struct {
        iter: Iter,
        predicate: F,

        const Self = @This();

        pub fn init(iter: Iter, predicate: F) Self {
            return Self {
                .iter = iter,
                .predicate = predicate
            };
        }

        pub fn next(self: *Self) ?Iter.Item {
            while(true) {
                var elem = self.iter.next() orelse return null;

                if (self.predicate[0].call(self.predicate, &elem)) {
                    return elem;
                }
            }
        }

        pub usingnamespace utils.mixin_if(
            @hasDecl(Iter, "next_back"),
            struct {
                pub fn next_back(self: *Self) ?Iter.Item {
                    while(true) {
                        var elem = self.iter.next_back() orelse return null;

                        if(self.predicate[0].call(self.predicate, &elem)) {
                            return elem;
                        }
                    }
                }

                pub usingnamespace DoubleEndedIterator(Self);
            }
        );

        usingnamespace Iterator(Self, Iter.Item);
    };
}