# SwedeCommTool

SwedeCommTool is a versatile command-line script designed for Android devices. It enables users to make calls, send SMS, and perform random communication actions using ADB (Android Debug Bridge). The script focuses on Swedish phone numbers and offers features like parallel messaging.

## Features

- Make calls to specified phone numbers.
- Send SMS with custom messages to specific numbers.
- Generate and make random calls to Swedish numbers.
- Send random SMS messages.
- Parallel SMS sending capability.

## Usage

```bash
Usage: SwedeCommTool [OPTIONS]

Options:

--prefix PREFIX            | Specify a prefix for phone numbers (range: 70-79)
--call NUMBER              | Make a call to the specified phone NUMBER
--send-sms NUMBER MESSAGE  | Send an SMS to the specified phone NUMBER with the given MESSAGE
--random-call              | Make a random call to a Swedish number
--random-sms TEXT          | Send a random SMS with the given TEXT
-p, --parallel N           | Send random SMS messages in parallel (N is the number of parallel messages)
-h, --help                 | Display this help message
```

### Examples

```bash
SwedeCommTool --prefix 73 --call 123456789
SwedeCommTool --send-sms 987654321 "Hello, how are you?"
SwedeCommTool --random-call
SwedeCommTool --random-sms "I'm feeling lucky"
SwedeCommTool -p 5 --random-sms "Have a great day!"
```

## Installation

1. Clone the repository or download the script.
2. Ensure you have ADB installed and configured on your system.
3. Give the script execution permissions: `chmod +x SwedeCommTool`.

## Requirements

- ADB (Android Debug Bridge)
- Android device connected and configured for ADB commands.

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](#).

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

wuseman - wuseman@nr1.nu

Project Link: [https://git.nr1.nu/wuseman/SwedeCommTool](https://git.nr1.nu/wuseman/SwedeCommTool)
