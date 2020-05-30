package internal;

foreign import minhook "lib/libminhook.x64.lib";

@(default_calling_convention = "std")
foreign minhook { // minhook interop
	MH_Initialize :: proc() -> MH_STATUS ---;
	MH_Uninitialize :: proc() -> MH_STATUS ---;
	MH_CreateHook :: proc(target, detour: rawptr, original: ^rawptr) -> MH_STATUS ---;
	MH_RemoveHook :: proc(target: rawptr) -> MH_STATUS ---;
	MH_EnableHook :: proc(target: rawptr) -> MH_STATUS ---;
}

MH_STATUS :: enum i32 {
    UNKNOWN = -1,
    OK = 0,
    ALREADY_INITIALIZED,
    NOT_INITIALIZED,
    ALREADY_CREATED,
    NOT_CREATED,
    ALREADY_ENABLED,
    ALREADY_DISABLED,
    NOT_EXECUTABLE,
    UNSUPPORTED_FUNCTION,
    MEMORY_ALLOC,
    MEMORY_PROTECT,
    MODULE_NOT_FOUND,
    FUNCTION_NOT_FOUND,
    MUTEX_FAILURE
}

initialize_mh :: proc() { 
	status := MH_Initialize();
	assert(status == .OK);
}

hook :: proc(ptr: rawptr, func: $T) -> T {
	orig: T;
	MH_CreateHook(ptr, cast(rawptr) func, cast(^rawptr) &orig);
	return orig;
}

enable_hooks :: inline proc() do MH_EnableHook(nil);

unhook :: proc(ptr: rawptr) -> bool {
	status := MH_RemoveHook(ptr);
	return status == .OK;
}