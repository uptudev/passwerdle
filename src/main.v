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
import term
import time

const max_index := 500	// max possible value: 5000
const splash_screen := '\x1b[0;31;1m|\x1b[0;32;1m[\x1b[0;1mP\x1b[0;32;1m]\x1b[0;32;1m[\x1b[0;1m@\x1b[0;32;1m]\x1b[0;31;1m[\x1b[0mS\x1b[0;31;1m]\x1b[0;32;1m[\x1b[0;1mS\x1b[0;32;1m]\x1b[0;31;1m[\x1b[0mW\x1b[0;31;1m][\x1b[0mE\x1b[0;31;1m]\x1b[0;32;1m[\x1b[0;1mR\x1b[0;32;1m]\x1b[0;32;1m[\x1b[0;1mD\x1b[0;32;1m]\x1b[0;31;1m[\x1b[0mL\x1b[0;31;1m]\x1b[0;32;1m[\x1b[0;1mE\x1b[0;32;1m]\x1b[0;31;1m|\x1b[0m'
const splash_underline := term.red('================================')
const splash_len := term.strip_ansi(splash_screen).len

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
	width, height := term.get_terminal_size()
	term.set_terminal_title('passwerdle')
	term.clear()
	mut x_coord := width / 2 - splash_len / 2
	mut y_coord := height / 2
	term.set_cursor_position(x: x_coord, y: y_coord)
	println(splash_screen)
	term.set_cursor_position(x: x_coord, y: y_coord - 1)
	println(splash_underline)
	term.set_cursor_position(x: x_coord, y: y_coord + 1)
	println(splash_underline)
	term.hide_cursor()
	term.set_cursor_position(x: 0, y: height)
	os.input_opt('Press any key to begin: ')
	term.clear()
	x_coord = width / 2 - str.len / 2
	term.show_cursor()
	term.set_cursor_position(x: x_coord, y: y_coord)
	println(str)
	term.hide_cursor()
	term.set_cursor_position(x: 0, y: height)

	time.sleep(5 * time.second)
	term.clear()
}
