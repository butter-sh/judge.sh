# Snapshot Testing - Quick Start

## 🚀 Get Started in 3 Steps

### Step 1: Make Scripts Executable
```bash
cd __tests
bash make-executable.sh
```

### Step 2: Create Initial Snapshots
```bash
./setup-snapshots.sh
```

### Step 3: Commit to Git
```bash
git add snapshots/*_master.log
git add snapshots/.gitignore
git add snapshots/README.md
git commit -m "Add initial test snapshots"
```

## 📋 Daily Usage

### Run Tests
```bash
./run-all-tests.sh
```

### Update Snapshots (after intentional changes)
```bash
./run-all-tests.sh -u
git add snapshots/*_master.log
git commit -m "Update snapshots for feature X"
```

## 🛠️ Common Commands

```bash
# Run tests
./run-all-tests.sh

# Run with verbose output
./run-all-tests.sh -v

# Run specific test
./run-all-tests.sh -t stack-list

# Update snapshots
./run-all-tests.sh -u

# View latest snapshot
./snapshot-tool.sh show stack-list

# Compare with master
./snapshot-tool.sh diff stack-list

# Clean old snapshots
./snapshot-tool.sh clean

# Show statistics
./snapshot-tool.sh stats
```

## 📖 Full Documentation

See [`TESTING.md`](TESTING.md) for complete documentation.

## ✅ What's Included

- ✅ Full snapshot capture for all test runs
- ✅ Command-line options: `-u`, `-i`, `-v`, `-t`
- ✅ Master snapshots committed to git
- ✅ Timestamped snapshots (not committed)
- ✅ Snapshot management tools
- ✅ Comprehensive documentation

## 🎯 Benefits

- **Catch Regressions**: Automatically detect unintended output changes
- **Easy Updates**: Simple workflow for updating expected output
- **Full History**: Complete logs of all test runs
- **CI/CD Ready**: Works seamlessly in automated pipelines
- **Developer Friendly**: Intuitive commands and clear documentation
