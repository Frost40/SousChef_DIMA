#!/bin/bash

# Unit Test Runner for SousChef
# This script provides convenient commands for running tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   SousChef Unit Test Runner           ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to run command with status
run_with_status() {
    local cmd=$1
    local desc=$2
    
    echo -e "${BLUE}▶ $desc${NC}"
    if eval "$cmd"; then
        echo -e "${GREEN}✓ Success${NC}\n"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}\n"
        return 1
    fi
}

# Parse command line arguments
case "${1:-all}" in
    "all")
        print_header "Running All Tests"
        run_with_status "flutter test" "Running all test files"
        ;;
    
    "providers")
        print_header "Running Provider Tests"
        run_with_status "flutter test test/providers/" "Testing all providers"
        ;;
    
    "services")
        print_header "Running Service Tests"
        run_with_status "flutter test test/services/" "Testing all services"
        ;;
    
    "auth")
        print_header "Running Auth Tests"
        run_with_status "flutter test test/providers/auth_provider_test.dart" "Testing AuthProvider"
        run_with_status "flutter test test/services/authentication_test.dart" "Testing Authentication Service"
        ;;
    
    "dish")
        print_header "Running Dish Tests"
        run_with_status "flutter test test/providers/dish_provider_test.dart" "Testing DishProvider"
        run_with_status "flutter test test/services/dish_firestore_test.dart" "Testing DishFirestore Service"
        ;;
    
    "order")
        print_header "Running Order Tests"
        run_with_status "flutter test test/providers/order_provider_test.dart" "Testing OrderProvider"
        run_with_status "flutter test test/services/order_firestore_test.dart" "Testing OrderFirestore Service"
        ;;
    
    "chat")
        print_header "Running Chat Tests"
        run_with_status "flutter test test/providers/chat_provider_test.dart" "Testing ChatProvider"
        ;;
    
    "stripe")
        print_header "Running Stripe Tests"
        run_with_status "flutter test test/providers/stripe_provider_test.dart" "Testing StripeProvider"
        ;;
    
    "example")
        print_header "Running Example Test"
        run_with_status "flutter test test/examples/auth_provider_complete_example_test.dart" "Running complete example"
        ;;
    
    "coverage")
        print_header "Running Tests with Coverage"
        run_with_status "flutter test --coverage" "Collecting coverage data"
        
        if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
            print_header "Generating Coverage Report"
            run_with_status "genhtml coverage/lcov.info -o coverage/html" "Generating HTML report"
            echo -e "${GREEN}Coverage report generated at: coverage/html/index.html${NC}"
            echo -e "${BLUE}Open with: open coverage/html/index.html${NC}\n"
        else
            echo -e "${YELLOW}⚠ lcov not installed. Install with: brew install lcov${NC}\n"
        fi
        ;;
    
    "watch")
        print_header "Running Tests in Watch Mode"
        echo -e "${YELLOW}Note: Flutter doesn't have built-in watch mode${NC}"
        echo -e "${YELLOW}Tip: Use VS Code's 'Run and Debug' for continuous testing${NC}\n"
        ;;
    
    "clean")
        print_header "Cleaning Test Artifacts"
        run_with_status "flutter clean" "Cleaning Flutter build"
        run_with_status "flutter pub get" "Reinstalling dependencies"
        ;;
    
    "help"|"-h"|"--help")
        echo -e "${GREEN}Usage: ./run_tests.sh [command]${NC}\n"
        echo "Available commands:"
        echo "  all        - Run all tests (default)"
        echo "  providers  - Run all provider tests"
        echo "  services   - Run all service tests"
        echo "  auth       - Run auth-related tests"
        echo "  dish       - Run dish-related tests"
        echo "  order      - Run order-related tests"
        echo "  chat       - Run chat-related tests"
        echo "  stripe     - Run stripe-related tests"
        echo "  example    - Run the complete example test"
        echo "  coverage   - Run tests with coverage report"
        echo "  clean      - Clean and reinstall dependencies"
        echo "  help       - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./run_tests.sh              # Run all tests"
        echo "  ./run_tests.sh providers    # Run provider tests only"
        echo "  ./run_tests.sh coverage     # Generate coverage report"
        ;;
    
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo -e "Run './run_tests.sh help' for usage information\n"
        exit 1
        ;;
esac

# Footer
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Testing complete!${NC}\n"
