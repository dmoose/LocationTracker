#!/bin/bash

# Simple script to run the LocationTracker console demo

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== LocationTracker Simple Console Demo Runner ===${NC}"

# Navigate to the demo directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEMO_DIR="$SCRIPT_DIR/ConsoleDemo"

# Check if demo directory exists
if [ ! -d "$DEMO_DIR" ]; then
    echo -e "${RED}Error: Could not find the ConsoleDemo directory.${NC}"
    echo -e "${YELLOW}Make sure you're running this script from the Examples directory.${NC}"
    exit 1
fi

# Go to the demo directory
cd "$DEMO_DIR" || {
    echo -e "${RED}Error: Could not access the ConsoleDemo directory.${NC}"
    exit 1
}

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo -e "${RED}Error: Swift is not installed or not in your PATH.${NC}"
    echo -e "${YELLOW}Please install Swift or add it to your PATH and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Building and running the LocationTracker console demo...${NC}"

# Build and run
# Clean the build directory first to avoid cache issues
echo -e "${YELLOW}Cleaning build artifacts...${NC}"
swift package clean

# Build and run
if swift build; then
    echo -e "${GREEN}Build successful! Running the demo...${NC}"
    echo -e "${YELLOW}---------------------------------------------${NC}"

    # Find and run the executable
    EXECUTABLE=".build/debug/LocationTrackerConsoleDemo"
    if [ -f "$EXECUTABLE" ]; then
        "$EXECUTABLE"
    else
        echo -e "${YELLOW}Running with 'swift run'...${NC}"
        swift run
    fi

    echo -e "${YELLOW}---------------------------------------------${NC}"
else
    echo -e "${RED}Build failed. See errors above.${NC}"
    exit 1
fi

echo -e "\n${GREEN}Demo execution complete.${NC}"
echo -e "${YELLOW}This simple console demo shows the basics of LocationTracker functionality.${NC}"
echo -e "${YELLOW}View the source code to understand how the package is used.${NC}"
