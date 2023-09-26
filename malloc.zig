const std = @import("std");

test "stack" {
    var name: [4]u8 = .{ 'a', 'l', 'i', 'p' };
    name[3] = 'f';

    try std.testing.expectEqual([_]u8{ 'a', 'l', 'i', 'f' }, name);
}

test "page_allocator" {
    const allocator = std.heap.page_allocator;
    var array = try std.ArrayList(u8).initCapacity(allocator, 4);
    defer array.deinit();

    try array.appendSlice("alif");

    try std.testing.expectEqual(@as(usize, 4), array.capacity);
    try std.testing.expectEqualStrings("alif", array.items);
}

// example of memory allocation without using defer.
test "area_allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var map = std.StringHashMap([]const u8).init(allocator);

    try map.put("foo", "bar");
    try map.put("bar", "foo");

    try std.testing.expectEqualStrings("bar", map.get("foo").?);
    try std.testing.expectEqualStrings("foo", map.get("bar").?);

    map.deinit();
    arena.deinit();
}
