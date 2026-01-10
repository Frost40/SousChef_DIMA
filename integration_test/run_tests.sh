#!/bin/bash

# Integration Test Runner Script
# This script helps run integration tests on different devices

set -e  # Exit on error

echo "🧪 SousChef Integration Test Runner"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_success "Flutter found: $(flutter --version | head -n 1)"
echo ""

# Get available devices
echo "📱 Available devices:"
flutter devices
echo ""

# Ask user to select device
echo "Enter device ID (or press Enter to use first available device):"
read -r DEVICE_ID

if [ -z "$DEVICE_ID" ]; then
    # Get first available device
    DEVICE_ID=$(flutter devices | grep -v "No devices" | grep "•" | head -n 1 | awk -F'•' '{print $2}' | xargs)
    print_warning "Using first available device: $DEVICE_ID"
fi

echo ""
print_success "Selected device: $DEVICE_ID"
echo ""

# Check if integration test file exists
TEST_FILE="integration_test/login_to_home_flow_test.dart"
if [ ! -f "$TEST_FILE" ]; then
    print_error "Test file not found: $TEST_FILE"
    exit 1
fi

# Ask if user wants to run all tests or specific ones
echo "What do you want to run?"
echo "1) All integration tests"
echo "2) Only login_to_home_flow_test.dart"
echo "3) Custom test file"
read -r CHOICE

case $CHOICE in
    1)
        TEST_PATH="integration_test/"
        print_success "Running all integration tests"
        ;;
    2)
        TEST_PATH="integration_test/login_to_home_flow_test.dart"
        print_success "Running login_to_home_flow_test.dart"
        ;;
    3)
        echo "Enter test file path:"
        read -r TEST_PATH
        ;;
    *)
        TEST_PATH="integration_test/login_to_home_flow_test.dart"
        print_warning "Invalid choice, defaulting to login_to_home_flow_test.dart"
        ;;
esac

echo ""
echo "================================"
echo "🚀 Starting integration tests..."
echo "================================"
echo ""

# Run the tests
if [ -z "$DEVICE_ID" ]; then
    flutter test "$TEST_PATH"
else
    flutter test "$TEST_PATH" -d "$DEVICE_ID"
fi

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    print_success "All tests passed! 🎉"
    echo "================================"
else
    echo ""
    echo "================================"
    print_error "Some tests failed! 😞"
    echo "================================"
    exit 1
fi
