# judge.sh

A modern bash testing framework with rich assertions and beautiful output.

## Features

- 🎯 Simple and intuitive API
- ✅ Rich assertion library
- 🎨 Colorful output
- 📊 Test summaries
- 🔍 Verbose mode for debugging
- 🛑 Stop on first failure option
- 📁 Test file discovery
- 🔗 Integrates with arty.sh for dependency management

## Installation

### Using arty.sh

```bash
arty install https://github.com/YOUR_USERNAME/judge.sh.git
```

### Manual Installation

```bash
git clone https://github.com/YOUR_USERNAME/judge.sh.git
cd judge.sh
chmod +x judge.sh
sudo ln -s "$(pwd)/judge.sh" /usr/local/bin/judge
```

## Quick Start

Create a test file `my_test.sh`:

```bash
#!/usr/bin/env bash

# Source judge.sh
source judge.sh

describe "Basic Math Tests"

it "should add two numbers" "
    result=\$((2 + 2))
    assert_equals '4' \"\$result\"
"

it "should multiply numbers" "
    result=\$((3 * 4))
    assert_equals '12' \"\$result\"
"

describe "String Tests"

it "should compare strings" "
    assert_equals 'hello' 'hello'
"

it "should check if string contains substring" "
    assert_contains 'hello world' 'world'
"

# Run the tests (if file is executed directly)
if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
    print_summary
fi
```

Run your tests:

```bash
judge test my_test.sh
```

## Usage

### Running Tests

```bash
# Run a single test file
judge test my_test.sh

# Run all tests in a directory
judge test ./tests

# Run with verbose output
judge test --verbose my_test.sh

# Stop on first failure
judge test --stop my_test.sh

# Custom file pattern
judge test ./tests --pattern "*spec.sh"
```

### Writing Tests

#### Test Structure

```bash
#!/usr/bin/env bash
source judge.sh

# Describe a test suite
describe "My Feature"

# Define a test
it "should do something" "
    # Your test code here
    assert_equals 'expected' 'actual'
"

# Skip a test
xit "should be implemented later" "
    # This test will be skipped
"
```

### Available Assertions

#### Equality

```bash
assert_equals <expected> <actual> [message]
```

Example:
```bash
it "should compare values" "
    assert_equals '42' '42'
    assert_equals 'hello' 'hello'
"
```

#### Boolean

```bash
assert_true <value> [message]
assert_false <value> [message]
```

Example:
```bash
it "should check boolean values" "
    assert_true '1'
    assert_true 'true'
    assert_false '0'
    assert_false ''
"
```

#### Empty/Not Empty

```bash
assert_empty <value> [message]
assert_not_empty <value> [message]
```

Example:
```bash
it "should check emptiness" "
    assert_empty ''
    assert_not_empty 'hello'
"
```

#### String Contains

```bash
assert_contains <haystack> <needle> [message]
```

Example:
```bash
it "should find substring" "
    assert_contains 'hello world' 'world'
"
```

#### File System

```bash
assert_file_exists <file> [message]
assert_dir_exists <dir> [message]
```

Example:
```bash
it "should check file existence" "
    assert_file_exists '/etc/hosts'
    assert_dir_exists '/tmp'
"
```

#### Command Success/Failure

```bash
assert_success <command> [message]
assert_failure <command> [message]
```

Example:
```bash
it "should run commands" "
    assert_success 'echo hello'
    assert_failure 'false'
"
```

## Advanced Usage

### Setup and Teardown

```bash
#!/usr/bin/env bash
source judge.sh

setup() {
    # Run before tests
    export TEST_VAR="setup"
    mkdir -p /tmp/test_dir
}

teardown() {
    # Run after tests
    rm -rf /tmp/test_dir
}

describe "Tests with setup/teardown"

it "should have setup variables" "
    setup
    assert_equals 'setup' \"\$TEST_VAR\"
    teardown
"
```

### Testing Functions

```bash
#!/usr/bin/env bash
source judge.sh

# Function to test
my_function() {
    local name="$1"
    echo "Hello, $name!"
}

describe "Function Tests"

it "should call function correctly" "
    result=\$(my_function 'World')
    assert_equals 'Hello, World!' \"\$result\"
"
```

### Complex Assertions

```bash
it "should handle complex scenarios" "
    # Multiple assertions
    assert_true '1'
    assert_equals 'a' 'a'
    
    # Command output
    output=\$(echo 'test')
    assert_equals 'test' \"\$output\"
    
    # File operations
    echo 'content' > /tmp/test.txt
    assert_file_exists '/tmp/test.txt'
    content=\$(cat /tmp/test.txt)
    assert_equals 'content' \"\$content\"
    rm /tmp/test.txt
"
```

## Environment Variables

- `JUDGE_VERBOSE`: Enable verbose output (default: false)
- `JUDGE_STOP_ON_FAIL`: Stop on first failure (default: false)

```bash
# Enable verbose mode
export JUDGE_VERBOSE=true
judge test my_test.sh

# Or inline
JUDGE_VERBOSE=true judge test my_test.sh
```

## Integration with CI/CD

judge.sh returns proper exit codes:
- `0`: All tests passed
- `1`: Some tests failed

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          chmod +x judge.sh
          ./judge.sh test ./tests
```

### GitLab CI

```yaml
test:
  script:
    - chmod +x judge.sh
    - ./judge.sh test ./tests
```

## Examples

See the `examples/` directory for more test examples:

- `basic_test.sh` - Basic assertions
- `advanced_test.sh` - Complex test scenarios
- `file_test.sh` - File system testing

## Tips and Best Practices

1. **Keep tests focused**: Each test should verify one specific behavior
2. **Use descriptive names**: Test names should clearly state what they verify
3. **Avoid side effects**: Tests should be independent and not rely on each other
4. **Clean up resources**: Always clean up temporary files and directories
5. **Use setup/teardown**: For common initialization and cleanup code

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Credits

Created as part of the hammer.sh project ecosystem.
