#!/bin/bash

# LocationTracker Package Test Runner
# Runs unit tests with coverage reporting

set -e  # Exit on any error

echo "🧪 Running LocationTracker Package Tests"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    print_error "Package.swift not found. Please run this script from the LocationTrackerPackage directory."
    exit 1
fi

# Clean previous test artifacts
print_status "Cleaning previous test artifacts..."
rm -rf .build/debug/codecov
rm -rf coverage.lcov
rm -rf test-results.xml

# Run tests with coverage
print_status "Running tests with coverage..."
swift test --enable-code-coverage

# Check if tests passed
if [ $? -eq 0 ]; then
    print_success "All tests passed! ✅"
else
    print_error "Some tests failed! ❌"
    exit 1
fi

# Generate coverage report if llvm-cov is available
if command -v llvm-cov >/dev/null 2>&1; then
    print_status "Generating coverage report..."
    
    # Find the test binary
    TEST_BINARY=$(find .build -name "*PackageTests.xctest" -o -name "*Tests" | head -1)
    
    if [ -n "$TEST_BINARY" ]; then
        # Generate LCOV format coverage report
        llvm-cov export -format="lcov" \
            "$TEST_BINARY" \
            -instr-profile=.build/debug/codecov/default.profdata \
            > coverage.lcov
        
        # Generate human-readable coverage report
        llvm-cov report \
            "$TEST_BINARY" \
            -instr-profile=.build/debug/codecov/default.profdata \
            -use-color
        
        print_success "Coverage report generated: coverage.lcov"
    else
        print_warning "Test binary not found, skipping coverage report generation"
    fi
else
    print_warning "llvm-cov not found, skipping coverage report generation"
fi

# Run specific test configurations if needed
print_status "Running tests on all supported platforms..."

# Test on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Testing on macOS..."
    swift test --destination platform=macOS
fi

# Test with different Swift versions if available
if command -v xcrun >/dev/null 2>&1; then
    print_status "Testing with Xcode toolchain..."
    xcrun swift test
fi

print_success "Test run completed successfully! 🎉"
print_status "Summary:"
echo "  - Unit tests: ✅ Passed"
echo "  - Coverage report: $([ -f coverage.lcov ] && echo "✅ Generated" || echo "⚠️  Skipped")"
echo ""
print_status "Next steps:"
echo "  - Review coverage report if generated"
echo "  - Check test output for any warnings"
echo "  - Run 'swift test --help' for additional test options"
