# LLM Documentation Generation Instructions

This file provides instructions for AI agents to generate comprehensive package documentation by analyzing the source code in this Swift package.

## Overview
This LocationTracker package contains placeholder LLM documentation files that need to be populated based on the actual source code implementation:

- `LLM_AGENT_GUIDE.md` - Comprehensive integration guide for LLMs
- `LLM_README.md` - Concise package overview for LLMs  
- `LLM_REFERENCE_CARD.md` - Quick reference for LLMs

## Source Code Analysis Instructions

### 1. Analyze Package Structure
- Examine `Package.swift` for dependencies, platforms, and targets
- Review `Sources/location-tracker/` for main implementation files
- Check `Tests/` for test patterns and usage examples
- Look at `Examples/` for practical usage demonstrations

### 2. Extract Core Functionality
From the source code, identify:
- **Primary Classes/Structs**: Main types users will interact with
- **Key Methods/Properties**: Essential APIs and their signatures
- **Error Types**: Custom errors and error handling patterns
- **Platform Requirements**: iOS/macOS/watchOS/tvOS versions
- **Swift Version**: Minimum Swift version required
- **Dependencies**: External packages used

### 3. Generate LLM_AGENT_GUIDE.md
Create comprehensive documentation including:
- Package overview with platform requirements
- Core components with code examples
- Integration patterns for different use cases
- Error handling examples
- Common usage scenarios
- Best practices for implementation

**Template Structure:**
```markdown
# LocationTracker Package: LLM Integration Guide

## Package Overview
[One paragraph describing the package's purpose and functionality]

- **Platform Requirements**: [Extract from Package.swift]
- **Swift Version**: [Extract from swift-tools-version]
- **Package Name**: `location-tracker`

## Core Components
[Document each main class/struct with usage examples]

### `MainClassName`
[Description and code examples]

## Usage Examples
[Show common integration patterns]

## Error Handling
[Document error types and handling patterns]

## Best Practices
[Integration recommendations]
```

### 4. Generate LLM_README.md  
Create concise overview including:
- One-sentence package description
- Key features list (3-5 bullet points)
- Basic usage example
- Installation instructions
- Link to full documentation

**Template Structure:**
```markdown
# LocationTracker Package

[One sentence description]

## Key Features
- [Feature 1]
- [Feature 2]
- [Feature 3]

## Quick Example
```swift
import location-tracker
// Basic usage example
```

## Installation
Add to your Package.swift dependencies:
```swift
.package(url: "your-repo-url", from: "1.0.0")
```

## Documentation
See [LLM Agent Guide](LLM_AGENT_GUIDE.md) for complete integration details.
```

### 5. Generate LLM_REFERENCE_CARD.md
Create quick reference including:
- Import statement
- Key type signatures
- Essential method calls
- Common patterns
- Error types

**Template Structure:**
```markdown
# LocationTracker Quick Reference

## Import
```swift
import location-tracker
```

## Key Types
[List main classes/structs with brief descriptions]

## Essential Methods
[List key methods with signatures]

## Common Patterns
[Show typical usage patterns]

## Error Types
[List custom error types]
```

## Code Analysis Guidelines

### Identifying Main Components
1. Look for `public` classes, structs, and enums in Sources/
2. Check for `@Observable`, `@ObservableObject`, or other property wrappers
3. Identify async/await patterns and Task usage
4. Look for protocol definitions and implementations

### Extracting Usage Patterns
1. Examine test files for usage examples
2. Check Examples/ directory for practical implementations
3. Look for common initialization patterns
4. Identify typical method call sequences

### Platform Requirements Analysis
1. Check Package.swift platforms array
2. Look for availability annotations in source code
3. Identify iOS/macOS specific APIs used
4. Note any Xcode version requirements

### Error Handling Patterns
1. Find custom Error enums
2. Look for throwing functions
3. Check for Result types usage
4. Identify async error handling patterns

## Quality Guidelines
- All code examples must be compilable
- Include error handling where appropriate
- Show both basic and advanced usage patterns
- Reference actual types and methods from the source
- Maintain consistency with Swift naming conventions
- Follow Apple's documentation style guidelines
- Use realistic variable names and scenarios

## Processing Steps
1. **Read and understand** all source files in `Sources/location-tracker/`
2. **Identify patterns** from test files in `Tests/`
3. **Extract examples** from `Examples/` directory
4. **Generate documentation** following the AsyncTask package style
5. **Replace placeholder content** in the three LLM markdown files
6. **Validate examples** ensure all code compiles and follows best practices
7. **Delete this instruction file** after completion

## Example Analysis Workflow

### Step 1: Package.swift Analysis
```swift
// Extract platform requirements
platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10), .tvOS(.v17)]
// Extract dependencies
dependencies: [...]
```

### Step 2: Main Source File Analysis
```swift
// Look for main public types
public class MainClass {
    // Document public methods and properties
}
```

### Step 3: Test Analysis
```swift
// Extract usage patterns from tests
func testBasicUsage() {
    let instance = MainClass()
    // Document this pattern
}
```

### Step 4: Documentation Generation
Replace placeholder content in LLM files with analyzed information.

## Note for Future LLMs
This file should be **deleted** after the LLM documentation files have been properly generated and populated with package-specific content. The goal is to create documentation as comprehensive and useful as the AsyncTask package example.
