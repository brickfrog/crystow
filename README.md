# CryStow

CryStow (Crystal-like stow) is a tool designed to manage your dotfiles easily, inspired by the simplicity of Crystal.

## Installation

Clone the repository and build the project using:

```bash
crystal build src/crystow.cr
```

## Usage

Run `crystow` with the required options:

```bash
crystal run src/crystow.cr -- -a ~/.config/i3 -d ~/dotfiles/i3 --simulate --verbose
```

### Options

- `-v, --version`: Show the version of CryStow.
- `-s, --simulate`: Simulate the operation without making any changes to the files.
- `--verbose`: Enable verbose output to see more detailed logs.
- `-f, --force`: Force overwrite existing files without asking.
- `-a APP, --app=APP`: Specify the application configuration path you want to manage.
- `-d DEST, --dest=DEST`: Specify the destination path where the dotfiles should be stored.
- `-h, --help`: Display help information.

## Example

To simulate the management of i3 config files without actually copying them:

```bash
./crystow -a ~/.config/i3 -d ~/dotfiles/i3 --simulate --verbose
```

This command will show what changes would be made if the command were executed without the `--simulate` flag.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your features or fixes.

## License

Distributed under the MIT License. See `LICENSE` for more information.
