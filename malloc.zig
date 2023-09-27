const std = @import("std");

test "stack" {
    var name: [4]u8 = .{ 'a', 'l', 'i', 'p' };
    name[3] = 'f';

    try std.testing.expectEqual([4]u8{ 'a', 'l', 'i', 'f' }, name);
    try std.testing.expectEqualStrings("alif", &name);
}

test "page allocator" {
    const allocator = std.heap.page_allocator;
    var array = try std.ArrayList(u8).initCapacity(allocator, 4);
    defer array.deinit();

    try array.appendSlice("alif");

    try std.testing.expectEqual(@as(usize, 4), array.capacity);
    try std.testing.expectEqualStrings("alif", array.items);
}

// example of memory allocation without using defer.
test "area allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var map = std.StringArrayHashMap([]const u8).init(allocator);

    try map.put("foo", "bar");
    try map.put("bar", "foo");

    try std.testing.expectEqualStrings("bar", map.get("foo").?);
    try std.testing.expectEqualStrings("foo", map.get("bar").?);

    map.deinit();
    arena.deinit();
}

test "general purpose allocator" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("TEST FAIL");
        }
    }

    const allocator = gpa.allocator();

    var map = std.StringArrayHashMap([]const u8).init(allocator);
    defer map.deinit();

    try map.put("foo", "bar");
    try map.put("bar", "foo");

    try std.testing.expectEqualStrings("bar", map.get("foo").?);
    try std.testing.expectEqualStrings("foo", map.get("bar").?);

    var array = std.ArrayList(f16).init(allocator);
    defer array.deinit();

    const slice = [_]f16{ 1.20, 3.14, 4.29, 6.12 };
    try array.appendSlice(&slice);

    array.clearAndFree();

    try std.testing.expect(array.getLastOrNull() == null);
}

test "fixed buffer allocator" {
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const allocator = fba.allocator();

    var array = try std.ArrayList(f16).initCapacity(allocator, 3);
    defer array.deinit();

    try array.append(1.20);
    try array.append(3.14);

    try std.testing.expect(array.items.len == 2);
    try std.testing.expect(array.capacity == 3);

    try array.append(4.29);
    try array.append(6.28);

    try std.testing.expect(array.items.len == 4);

    const new_item = try array.addOne();
    new_item.* = 8.12;

    try std.testing.expectEqual(f16, @TypeOf(new_item.*));
    try std.testing.expect(array.getLast() == 8.12);

    array.clearAndFree();
    try std.testing.expect(array.getLastOrNull() == null);
}
