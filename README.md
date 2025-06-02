# LocationTracker Package

a Swift package for locationtracker

## Package Structure

This repository contains a complete Swift package with the following structure:

### 📦 [LocationTrackerPackage/](./LocationTrackerPackage/)
The main Swift package containing:
- **[README.md](./LocationTrackerPackage/README.md)** - Package documentation and usage
- **[Sources/](./LocationTrackerPackage/Sources/)** - Swift source code
- **[Tests/](./LocationTrackerPackage/Tests/)** - Unit tests
- **[Examples/](./LocationTrackerPackage/Examples/)** - Example implementations
- **[LLM Documentation](./LocationTrackerPackage/LLM_AGENT_GUIDE.md)** - AI agent integration guide

### 🎯 [LocationTrackerDemo/](./LocationTrackerDemo/)
Demo iOS/macOS application showing package usage:
- **[README.md](./LocationTrackerDemo/README.md)** - Demo app documentation

### 🔧 Build & Development
- **[Makefile](./Makefile)** - Build automation and cleanup tasks
- **[.github/workflows/](./.github/workflows/)** - CI/CD pipeline configuration

## Quick Start

1. Open `LocationTrackerDemo/LocationTrackerDemo.xcodeproj` in Xcode
2. Build and run the demo to see the package in action
3. Refer to the [package documentation](./LocationTrackerPackage/README.md) for integration details

## Development

```bash
# Clean build artifacts
make clean

# Deep clean (removes all generated files)
make distclean

# Run tests
cd LocationTrackerPackage && ./run-tests.sh

# Build documentation
cd LocationTrackerPackage && ./build-docs.sh
```

## LLM Integration

This package includes comprehensive documentation for AI agents:
- **[LLM Agent Guide](./LocationTrackerPackage/LLM_AGENT_GUIDE.md)** - Detailed integration instructions
- **[LLM README](./LocationTrackerPackage/LLM_README.md)** - Concise package overview
- **[LLM Reference Card](./LocationTrackerPackage/LLM_REFERENCE_CARD.md)** - Quick reference guide
- **[LLM Processing Instructions](./LocationTrackerPackage/LLM_PROCESSING_INSTRUCTIONS.md)** - Guide for generating LLM documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by Swift Package Author on 2025-06-23.
