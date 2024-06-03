# passwerdle

## state
```v
    word: const string,
    word_len: const uint,
    guess: mut string,
    guesses_left: mut u8,
    guess_state: mut u16,
    prior_guesses: mut []u16{len: guesses},
    prior_guess_literals: mut []string{len: guesses},
```
when a game starts, a word is chosen and length is calculated.
state is set to 0x00000000.

## guesses

guesses should be rational to the length of the password to guess.
the smallest are 5 chars long, and should have 6 guesses.
the longest is 16 chars long, and should have 11 guesses.

as such, the number of guesses $g$ is modelled by the following (where $l$ is password length):
$$g=\frac{l-5}{2}+6$$

## proc

```

main {
    state := init_state()
    for state.guesses_left > 0 {
        print_board(state)
        get_input(state)
        check_answer(state)
        state.guesses_left--
    }
    print_lose_screen()
}

print_board(state) {
    // formatting crap i'm not pseudocoding
}

get_input(state) {
    // query stdin and put it in state.guess
}

bool check_answer(state) {
    // compare state.guess vs state.word, setting result bitwise into state.guess_state
    if state.guess_state == 2^(state.word_len) - 1
        print_win_screen()
        exit()
    }
}

```
