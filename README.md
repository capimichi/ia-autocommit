# IA Auto Commit

This project contains a script for automatic commits in a development environment.

## Usage

```bash
$ iaautocommit
```

## Requirements

Please note that this script requires:

- git
- curl
- jq
- awk
- sed
- tr

### MacOS

```bash
$ brew install git curl jq gawk gnu-sed gnu-getopt
```

### Ubuntu

```bash
$ sudo apt-get install git curl jq gawk gnu-sed gnu-getopt
```

## Installation

```bash
$ curl https://raw.githubusercontent.com/capimichi/ia-autocommit/main/iaautocommit.sh > /usr/local/bin/iaautocommit
$ chmod +x /usr/local/bin/iaautocommit
```

## Files in this project

- `iaautocommit.sh`: This is the main script that handles automatic commits.
- `.gitignore`: This file specifies intentionally untracked files that Git should ignore.
- `LICENSE`: This project is licensed under the MIT License.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome. Please make sure to update tests as appropriate.

## Contact

For any inquiries, you can reach out to the project owner, Michele Capicchioni.

