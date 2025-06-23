#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== LocationTracker Documentation Generator ===${NC}"

# Ensure we have the DocC plugin
if ! grep -q "swift-docc-plugin" Package.swift; then
  echo -e "${YELLOW}Adding DocC plugin to Package.swift${NC}"
  swift package add-dependency 'https://github.com/apple/swift-docc-plugin' --exact 1.3.0
fi

# Create docs directory if it doesn't exist
mkdir -p docs

# Clean previous build artifacts
echo -e "${GREEN}Cleaning previous build artifacts...${NC}"
rm -rf .build/plugins/Swift-DocC
rm -rf docs/*

# Build the documentation archive
echo -e "${GREEN}Building documentation for hosting...${NC}"
swift package \
  --allow-writing-to-directory ./docs \
  generate-documentation \
  --target location-tracker \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path "/" \
  --output-path ./docs

# Create a simple redirect index.html that works locally and on GitHub Pages
echo -e "${GREEN}Creating redirect index.html...${NC}"
cat > docs/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=./documentation/location-tracker/">
    <title>LocationTracker Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
        }
        h1 { color: #0070c9; }
        a { color: #0070c9; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>LocationTracker Documentation</h1>
    <p>If you are not redirected automatically, follow this <a href="./documentation/location-tracker/">link to the documentation</a>.</p>
</body>
</html>
EOL

# Fix JavaScript base URL for local preview
echo -e "${GREEN}Fixing JavaScript base URL for local preview...${NC}"
find docs -name "*.html" -exec sed -i '' "s|var baseUrl = \"/location-tracker/\"|var baseUrl = \"/\"|g" {} \;

# Parse command line arguments
case "$1" in
  --preview|-p)
    # First, kill any existing servers
    echo -e "${GREEN}Stopping any existing servers...${NC}"
    pkill -f "docc preview" || true
    pkill -f "python.*http.server" || true

    # Try official DocC preview first
    echo -e "${GREEN}Attempting to use DocC preview...${NC}"
    if swift package --disable-sandbox preview-documentation --target location-tracker; then
      echo -e "${GREEN}DocC preview launched successfully${NC}"
    else
      echo -e "${YELLOW}DocC preview failed, falling back to Python HTTP server...${NC}"

      # Get available port (trying 8080, 8000, 3000)
      PORT=8080
      if ! nc -z localhost $PORT 2>/dev/null; then
        echo -e "${GREEN}Using port $PORT${NC}"
      elif ! nc -z localhost 8000 2>/dev/null; then
        PORT=8000
        echo -e "${GREEN}Using port $PORT${NC}"
      elif ! nc -z localhost 3000 2>/dev/null; then
        PORT=3000
        echo -e "${GREEN}Using port $PORT${NC}"
      else
        echo -e "${RED}No available ports found among standard options.${NC}"
        exit 1
      fi

      # Get system information for proper browser opening command
      if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}Opening browser on macOS...${NC}"
        open "http://localhost:$PORT/documentation/location-tracker/"
      elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${GREEN}Opening browser on Linux...${NC}"
        xdg-open "http://localhost:$PORT/documentation/location-tracker/" &>/dev/null || true
      fi

      echo -e "${GREEN}Starting HTTP server on port $PORT...${NC}"
      echo -e "${YELLOW}View documentation at: http://localhost:$PORT/documentation/location-tracker/${NC}"
      echo -e "${YELLOW}Press Ctrl+C to stop the server when finished.${NC}"
      (cd docs && python3 -m http.server $PORT)
    fi
    ;;

  --help|-h)
    echo -e "Usage: $0 [OPTION]"
    echo -e "  --generate, -g   Generate documentation for GitHub Pages (default)"
    echo -e "  --preview, -p    Preview documentation locally"
    echo -e "  --serve, -s      Serve documentation using Python HTTP server"
    echo -e "  --help, -h       Display this help message"
    ;;

  --serve|-s)
    # Kill any existing Python HTTP servers
    echo -e "${GREEN}Stopping any existing HTTP servers...${NC}"
    pkill -f "python.*http.server" || true

    # Find an available port
    PORT=8080
    if ! nc -z localhost $PORT 2>/dev/null; then
      echo -e "${GREEN}Using port $PORT${NC}"
    elif ! nc -z localhost 8000 2>/dev/null; then
      PORT=8000
      echo -e "${GREEN}Using port $PORT${NC}"
    elif ! nc -z localhost 3000 2>/dev/null; then
      PORT=3000
      echo -e "${GREEN}Using port $PORT${NC}"
    else
      echo -e "${RED}No available ports found among standard options.${NC}"
      exit 1
    fi

    echo -e "${GREEN}Starting HTTP server on port $PORT...${NC}"
    echo -e "${YELLOW}View documentation at: http://localhost:$PORT/documentation/location-tracker/${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the server when finished.${NC}"
    (cd docs && python3 -m http.server $PORT)
    ;;

  --generate|-g|*)
    # This section is already executed at the beginning of the script

    echo -e "${GREEN}Documentation built successfully in the ./docs directory${NC}"
    echo -e "${YELLOW}To view the documentation locally:${NC}"
    echo -e "  1. ${GREEN}$0 --preview${NC} (Use DocC preview if available)"
    echo -e "  2. ${GREEN}$0 --serve${NC}   (Use Python HTTP server)"
    echo -e "  3. Open ${GREEN}docs/documentation/location-tracker/index.html${NC} directly in your browser"
    echo -e ""
    echo -e "${YELLOW}To publish on GitHub Pages:${NC}"
    echo -e "1. Commit the docs directory to your repository"
    echo -e "2. Enable GitHub Pages in your repository settings"
    echo -e "3. Set the source to the docs folder in the main branch"
    echo -e "4. The documentation will be available at: https://yourusername.github.io/repository-name/documentation/location-tracker/"
    echo -e ""
    echo -e "${YELLOW}Note:${NC} If you want to deploy to GitHub Pages with a non-root URL, you'll need to regenerate"
    echo -e "the documentation with the appropriate --hosting-base-path option."
    ;;
esac
