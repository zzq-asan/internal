package internal;

import "core:fmt";
import "core:sys/win32";

log_to_console_safe_t :: proc "c" (str: ^String);
process_tank_packet_t :: proc "c" (self: ^Game_Logic_Component, packet: rawptr);
send_packet_t :: proc "c" (peer: rawptr, cid: u8, packet: ^ENet_Packet) -> i32;

log_to_console_safe_orig: log_to_console_safe_t;
process_tank_packet_orig: process_tank_packet_t;
send_packet_orig: send_packet_t;


log_to_console_safe_hook :: proc "c" (str: ^String) {
	context = gt_context();
	// do the handling here
	msg := to_odin(str); // does not allocate

	log_to_console(msg);
}

// a little helper function
log_to_console :: proc(msg: string) {
	// tprintf also uses the global allocator so don't forget to free it
	str := from_odin(fmt.tprintf("`3[STANKY LEG]``: {}", msg));
	defer free(str);
	
	log_to_console_safe_orig(str);
}

process_tank_packet_hook :: proc "c" (self: ^Game_Logic_Component, packet: rawptr) {
	context = gt_context();
	
	msg := fmt.tprintf("We at {} got packet {}", self, packet);
	defer delete(msg);
	
	log_to_console(msg);

	process_tank_packet_orig(self, packet);
}

send_packet_hook :: proc "c" (peer: rawptr, cid: u8, packet: ^ENet_Packet) -> i32 {
	context = gt_context();
	
	msg := fmt.tprintf("We at {} sending packet {}", peer, packet);
	defer delete(msg);
	
	log_to_console(msg);

	return send_packet_orig(peer, cid, packet);
}

main :: proc() {
	initialize_mh();
	open_console();
	gt = win32.get_module_handle_w(nil);
	hwnd = FindWindowA(nil, "Growtopia");

	patch_hash_check(0x1F4983); // "ban bypass"

	// it would be better to have these sigged but that's an excercise for the reader
	log        := gt_offset(0x277140); // LogToConsoleSafe
	onpacket   := gt_offset(0x1F5840); // GameLogicComponent::ProcessTankUpdatePacket
	sendpacket := gt_offset(0x360240); // enet_peer_send

	log_to_console_safe_orig = hook(log     , log_to_console_safe_hook);
	process_tank_packet_orig = hook(onpacket, process_tank_packet_hook);
	send_packet_orig = hook(sendpacket, send_packet_hook);

	enable_hooks();
}