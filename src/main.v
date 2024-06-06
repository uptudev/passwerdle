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
import flag

const grey_top := term.bright_black('┎─┒')
const yellow_top := term.yellow('┎─┒')
const green_top := term.green('┎─┒')
const grey_bot := term.bright_black('┖─┚')
const yellow_bot := term.yellow('┖─┚')
const green_bot := term.green('┖─┚')

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('passwerdle')
	fp.description('A puzzle game based off of guessing common passwords.')
	fp.version('0.2.0')
	fp.limit_free_args(0, 0)!
	fp.skip_executable()
	path := fp.string('load', `l`, '', 'Loads a plaintext newline-delmited wordbank from a given path.')
	max_index := u32(fp.int('index', `i`, 500, 'Sets the maximum index for the wordbank (the last line it can read).'))
	fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		exit(1)
	}
	term.hide_cursor()
	width, height := term.get_terminal_size()
	term.set_terminal_title('passwerdle')
	term.clear()

	mut state := GameState{
		round: 0,
		word: 'P@RSELRLDE',
		word_len: 10,
		guess: 'P@SSWERDLE',
		guesses_left: 1,
		guess_state: 0,
		prior_guesses: [16]u32{init: 0},
		prior_guess_literals: [16]string{init: ''}
	}
	state.word_len = u8(state.word.len)

	state.update_guess_state()
	state.print_board()

	term.set_cursor_position(x: 0, y: height - 1)
	term.show_cursor()
	os.input_opt('Press <Enter> to begin:\n')

	state.init(path, max_index)!
	term.clear()
	state.print_empty_board()
	for state.round < state.guesses_left {
		term.set_cursor_position(x: 0, y: height - 1)
		str := os.input_opt('Please enter your guess:\n') or {
			continue
		}
		if str.len != state.word_len {
			term.set_cursor_position(x: 0, y: height - 2)
			println('Invalid guess length. Please try again.')
			continue
		}
		state.guess = str.to_upper()
		state.update_guess_state()
		state.print_board()
		mut correct_guess := true
		for i in 0..state.word_len {
			if (state.guess_state >> i) & 1 == 0 {
				correct_guess = false
				break
			}
		}
		if correct_guess {
			congrats_str := "Congratulations! You've guessed the word!"
			term.set_cursor_position(x: width / 2 - congrats_str.len / 2, y: height - 1)
			println(congrats_str)
			time.sleep(3 * time.second)
			exit(0)
		}
		state.round += 1
	}
	term.set_cursor_position(x: 0, y: height - 1)
	println("You've run out of guesses! The word was: ${state.word}")
	time.sleep(3 * time.second)
	exit(0)
}

struct GameState {
mut:
	round u8
	word string
	word_len u8
	guess string
	guesses_left u8
	guess_state u32	// right half is for full matches, left half is for partial matches
	prior_guesses [16]u32
	prior_guess_literals [16]string
}

fn (mut s GameState) init(path string, max_index u32) ! {
	s.round = 0
	s.word = get_random_word(path, max_index)!.to_upper()
	s.word_len = u8(s.word.len)
	s.guesses_left = (s.word_len - 5) / 2 + 6
	s.guess_state = 0x0000
	s.prior_guesses = [16]u32{init: 0}
	s.prior_guess_literals = [16]string{init: ''}
}

fn (mut s GameState) update_guess_state() {
	for i, c in s.guess {
		if c == s.word[i] {
			s.guess_state |= 1 << i
		} else if s.word.contains(c.ascii_str()) {
			s.guess_state &= ~(1 << i)
			s.guess_state |= 1 << (i + 16)
		} else {
			s.guess_state &= ~(1 << i)
			s.guess_state &= ~(1 << (i + 16))
		}
	}
	s.prior_guesses[s.round] = s.guess_state
	s.prior_guess_literals[s.round] = s.guess
}

fn (s GameState) debug_print() {
	println("WORD: ${s.word}")
	println("WORD LEN: ${s.word_len}")
	println("GUESSES LEFT: ${s.guesses_left}")
	println("GUESS STATE: ${s.guess_state}")
	println("PRIOR GUESSES: ${s.prior_guesses}")
	println("PRIOR GUESS LITERALS: ${s.prior_guess_literals}")
}

fn (s GameState) calc_x_coord(i int) int {
	width, _ := term.get_terminal_size()
	return width / 2 - s.word_len * 3 / 2 + i * 3 - 1
}

fn (s GameState) calc_y_coord(j int) int {
	_, height := term.get_terminal_size()
	return height / 2 - (s.round + 1) * 3 / 2 + j * 3 - 1
}

fn (s GameState) print_empty_board() {
	term.clear()
	left := s.calc_x_coord(0)
	top := s.calc_y_coord(0) - 1
	term.set_cursor_position(x: left, y: top)
	print(term.bright_black("╭"))
	term.set_cursor_position(x: left, y: top + 1)
	print(term.bright_black("│"))
	term.set_cursor_position(x: left, y: top + 2)
	print(term.bright_black("├"))
	term.set_cursor_position(x: left, y: top + 3)
	print(term.bright_black("│"))
	term.set_cursor_position(x: left, y: top + 4)
	print(term.bright_black("╰"))
	for i in 0..s.word_len {
		x_coord := s.calc_x_coord(i) + 1
		term.set_cursor_position(x: x_coord, y: top)
		print(term.bright_black('───'))
		term.set_cursor_position(x: x_coord, y: top + 1)
		print(grey_top)
		term.set_cursor_position(x: x_coord, y: top + 2)
		print(term.bright_black('┨ ┠'))
		term.set_cursor_position(x: x_coord, y: top + 3)
		print(grey_bot)
		term.set_cursor_position(x: x_coord, y: top + 4)
		print(term.bright_black('───'))
	}
	term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: top)
	println(term.bright_black("╮"))
	term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: top + 1)
	println(term.bright_black("│"))
	term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: top + 2)
	println(term.bright_black("┤"))
	term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: top + 3)
	println(term.bright_black("│"))
	term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: top + 4)
	println(term.bright_black("╯"))
}

fn (s GameState) print_board() {
	term.clear()
	left := s.calc_x_coord(0)
	top := s.calc_y_coord(0) - 1
	term.set_cursor_position(x: left, y: top)
	print(term.bright_black("╭"))
	for _ in 0..s.word_len {
		print(term.bright_black('───'))
	}
	println(term.bright_black("╮"))
	for j := 0; j <= s.round; j++ {
		y_coord := s.calc_y_coord(j)
		term.set_cursor_position(x: left, y: y_coord)
		print(term.bright_black("│"))
		term.set_cursor_position(x: left, y: y_coord + 1)
		print(term.bright_black("├"))
		term.set_cursor_position(x: left, y: y_coord + 2)
		print(term.bright_black("│"))
		for i in 0..s.word_len {
			x_coord := s.calc_x_coord(i) + 1
			if s.prior_guesses[j] & (1 << i) != 0 {
				term.set_cursor_position(x: x_coord, y: y_coord)
				print(green_top)
				term.set_cursor_position(x: x_coord, y: y_coord + 1)
				print(
					term.green('┨')
					+ s.prior_guess_literals[j][i].ascii_str()
					+ term.green('┠'))
				term.set_cursor_position(x: x_coord, y: y_coord + 2)
				print(green_bot)
			} else if s.prior_guesses[j] & (1 << (i + 16)) != 0 {
				term.set_cursor_position(x: x_coord, y: y_coord)
				print(yellow_top)
				term.set_cursor_position(x: x_coord, y: y_coord + 1)
				print(
					term.yellow('┨')
					+ s.prior_guess_literals[j][i].ascii_str()
					+ term.yellow('┠'))
				term.set_cursor_position(x: x_coord, y: y_coord + 2)
				print(yellow_bot)
			} else {
				term.set_cursor_position(x: x_coord, y: y_coord)
				print(grey_top)
				term.set_cursor_position(x: x_coord, y: y_coord + 1)
				print(
					term.bright_black('┨')
					+ s.prior_guess_literals[j][i].ascii_str()
					+ term.bright_black('┠'))
				term.set_cursor_position(x: x_coord, y: y_coord + 2)
				print(grey_bot)
			}
		}
		term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: y_coord)
		println(term.bright_black("│"))
		term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: y_coord + 1)
		println(term.bright_black("┤"))
		term.set_cursor_position(x: s.calc_x_coord(s.word_len) + 1, y: y_coord + 2)
		println(term.bright_black("│"))
	}
	term.set_cursor_position(x: left, y: s.calc_y_coord(s.round + 1))
	print(term.bright_black("╰"))
	for _ in 0..s.word_len {
		print(term.bright_black('───'))
	}
	println(term.bright_black("╯"))
}

fn get_random_word(path string, max_index u32) !string {
	// seeds rng with current time and gets line number of word
	rand.seed(seed.time_seed_array(2))
	mut index := (rand.u32() % max_index) + 1

	if path == '' {
		return get_word_from_index(index)
	}

	buf := os.read_lines(path) or {
		println('Error reading file: ${err}.')
		exit(1)
	}

	return buf[index].trim(' \n\r\0')
}

fn get_word_from_index(index u32) !string {
	// opens file and reads line at index
	file := $embed_file('rockyou.txt')
	buf := file.to_string()
	split := buf.split('\n')
	return split[index].trim(' \n\r\0')
}
