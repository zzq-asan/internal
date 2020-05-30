package internal;

import "core:strings";
import "core:strconv";
import "core:runtime";
import "core:sys/win32";

gt: rawptr;
hwnd: rawptr;

gt_offset :: proc(offs: uintptr) -> rawptr {
	return cast(rawptr) (uintptr(gt) + offs);
}

gt_context :: proc() -> runtime.Context {
	ctx := runtime.default_context();
	ctx.allocator = c_allocator();
	ctx.temp_allocator = ctx.allocator;
	return ctx;
}

patch_hash_check :: proc(offs: uintptr) {
	addr := cast(^u16) gt_offset(offs);
	old: u32;
	win32.virtual_protect(addr, 2, 0x40, &old);

	addr ^= 0x9090;
}