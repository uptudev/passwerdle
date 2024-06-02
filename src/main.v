module main

import os
import rand
import rand.seed

fn main() {
	// seeds rng with current time and gets line number of word
	rand.seed(seed.time_seed_array(2))
	mut index := (rand.u32() % 5000) + 1

	// opens file and reads line at index
	file := os.open("rockyou.txt")!
	mut buf := []u8{len: 24}

	for file.read_bytes_with_newline(mut buf)! > 0 && index > 0 {
		unsafe{buf.reset()}
		index -= 1
	}
	print("${buf.bytestr()}")
}
