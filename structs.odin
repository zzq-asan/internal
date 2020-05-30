package internal;

ENet_Packet :: struct {
	refcount: uintptr,
	flags: u32,
	data: ^u8,
	length: uintptr,
	free_callback: rawptr,
	user_data: rawptr,
}

Game_Logic_Component :: struct {
	
}