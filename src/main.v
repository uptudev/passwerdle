/*
 *  Passwerdle, a puzzle game based off of guessing common passwords
 *  Copyright (C) 2024	uptu <uptu@uptu.dev>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

module main

import os
import rand
import rand.seed

const max_index := 500	// max possible value: 5000
const splash_screen := 'P@SSWERDLE'

fn main() {
	// seeds rng with current time and gets line number of word
	rand.seed(seed.time_seed_array(2))
	mut index := (rand.u32() % max_index) + 1

	// opens file and reads line at index
	file := os.open("rockyou.txt")!
	mut buf := []u8{len: 24}

	for file.read_bytes_with_newline(mut buf)! > 0 && index > 0 {
		unsafe{buf.reset()}	// idrk why this needs unsafe to reset all bytes to 0...
		index -= 1
	}
	str := buf.bytestr().trim(' \n\r\0')
	println(str)
}
