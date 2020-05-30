package internal;

import "core:mem";

foreign import "system:libcmt.lib";
@(default_calling_convention = "c")
foreign libcmt {
	@(link_name = "malloc") crt_malloc :: proc(size: uintptr) -> rawptr ---;
	@(link_name = "free") crt_free :: proc(ptr: rawptr) ---;
	@(link_name = "realloc") crt_realloc :: proc(ptr: rawptr, size: uintptr) -> rawptr ---;
};

c_allocator_proc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, flags: u64, location := #caller_location) -> rawptr {
	switch mode {
	case .Alloc:
		return crt_malloc(cast(uintptr) size);
	case .Free: crt_free(old_memory);
	case .Free_All:
	case .Resize: return crt_realloc(old_memory, cast(uintptr) size);
	}

	return nil;
}

c_allocator :: proc() -> mem.Allocator {
	return mem.Allocator {
		procedure = c_allocator_proc,
		data = nil,
	};
}