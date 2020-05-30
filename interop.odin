package internal;

import "core:mem";
import "core:os";
import "core:sys/win32";
import "core:fmt";

foreign import "system:kernel32.lib";
foreign import "system:user32.lib"

String :: struct {
	sso: struct #raw_union {
		data: [16]u8,
		ptr: rawptr,		
	},
	len: u64,
	maxlen: u64,
}
#assert(size_of(String) == 32);

to_odin :: proc(using data: ^String) -> string {
	if len < 16 {
		return string(sso.data[:len]);
	}
	str := cast(cstring) sso.ptr;
	return string(str);
}

from_odin :: proc(data: string) -> ^String {
	str := new(String);
	str.len = cast(u64) len(data);
	str.maxlen = str.len + 1;

	if str.len < 16 {
		str.sso.data = transmute([16]u8) data[:];
		return str;
	}

	raw := transmute(mem.Raw_String) data;
	str.sso.ptr = raw.data;

	return str;
}

string_free :: proc(data: ^String) {
	if data.len > 16 {
		free(data.sso.ptr);
	}
	data.len = 0;
	data.maxlen = 0;
	data.sso.ptr = nil;
} 

@(default_calling_convention = "std")
foreign kernel32 {
	AllocConsole :: proc() -> i32 ---;
	AttachConsole :: proc(pid: u32) -> i32 ---;
	GetCurrentProcessId :: proc() -> u32 ---;
	GetStdHandle :: proc(handle: i32) -> rawptr ---;
	SetConsoleMode :: proc(handle: rawptr, mode: u32) -> i32 ---; 
}

foreign user32 {
	FindWindowA :: proc "std" (class: cstring, title: cstring) -> rawptr ---;
}

// missing CreateFile("CONOUT$") ... not really needed as of now
open_console :: proc() {
	AllocConsole();
	AttachConsole(GetCurrentProcessId());

	_in := GetStdHandle(-10);
	out := GetStdHandle(-11);
	err := GetStdHandle(-12);

	SetConsoleMode(_in, 225);
	SetConsoleMode(out, 3);

	os.stdin  = auto_cast _in;
	os.stdout = auto_cast out;
	os.stderr = auto_cast err;
}