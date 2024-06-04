![# Passwerdle](https://i.imgur.com/eLRg3v1.png)

A game based on guessing one of the top 500 most used passwords.

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Additional Information](#additional-information)

## Installation

### Pre-built Binaries

Pre-built binaries are available for Windows, macOS (Intel chips, **NOT** Apple Silicon; please build from source if you have an Apple CPU) and Linux in the [releases](https://github.com/uptudev/passwerdle/releases) section. Download the appropriate binary for your system and run it in a terminal.

### Building from Source

Passwerdle is written in V, a simple, fast, safe, compiled language. To build from source, install V by following the instructions on the [official website](https://vlang.io).

Once you have V installed, you can clone the repository and build the game:

```sh
# Clone the repository and navigate into it
git clone https://github.com/uptudev/passwerdle.git
cd ./passwerdle

# Build the game
v .
```

## Usage

To start the game, run the compiled binary in a terminal (see [Installation](#installation) for instructions on building the game):

#### Linux/macOS/UNIX

```sh
./passwerdle
```

#### Windows

```cmd
passwerdle.exe
```

## Contributing

This is a personal project and I'm not looking for regular contributions at the moment. However, feel free to fork the repository and modify the game for your own use. I do review pull requests and issues, so feel free to open them if you have any suggestions or feedback.

## License

This project is licensed under the GNU GPL v3 License - see the [LICENSE](LICENSE) file for details. In a nutshell, this means that you are free to use, modify, and distribute the code as long as you include the same license in your distribution and state any changes.

## Additional Information

`rockyou.txt` in this project is a list of the top 5000 most used passwords, which I have reduced to the top 500 for this game via the `max_index` constant found at the top of `main.v`. The full list is available on the internet and is often used for password cracking and security research. The full list is not included in this repository, but you can easily find it by searching for "rockyou.txt" on the internet. Note that this will not work inserted into this program as is, as game assumes a maximum word length of 16 characters, and the full list contains much longer words and may cause issues due to the size of the full list.

### Tips

* Numbers are allowed and may sometimes be the entire password.
* The game is case-insensitive for simplicity.
* Yellow blocks indicate that the password contains the letter you guessed, but does not specify how many times it appears.
