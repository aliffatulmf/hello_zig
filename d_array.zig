const std = @import("std");

const StructType = struct {
    value: u8,
};

test "array list with Arena" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var array = std.ArrayList(StructType).init(allocator);
    defer array.deinit();

    try array.append(StructType{ .value = 1 });
    try array.append(StructType{ .value = 2 });
    try array.append(StructType{ .value = 3 });

    try std.testing.expect(array.items.len == 3);
}

test "array hash map with GPA" {
    // force safety check
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer {
        const ok = gpa.deinit();
        if (ok == .leak) {
            @panic("TEST FAILED DUE TO LEAK");
        }
    }
    const allocator = gpa.allocator();

    var aahm = std.AutoArrayHashMap(u8, u8).init(allocator);
    defer aahm.deinit();

    try aahm.put('a', 'z');
    try aahm.put('b', 'y');
    try aahm.put('c', 'x');

    try std.testing.expect(aahm.values().len == 3);
    try std.testing.expect(!aahm.contains('k'));
    try std.testing.expect(aahm.contains('c'));
}
