# LocationTracker Package Makefile
# Build automation and cleanup tasks

.PHONY: clean userclean distclean help

# Default target
help:
	@echo "LocationTracker Package Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  clean      - Remove build artifacts and temporary files"
	@echo "  userclean  - Remove user-specific data and caches"
	@echo "  distclean  - Complete cleanup (clean + userclean + project files)"
	@echo "  help       - Show this help message"

# Remove build artifacts and temporary files
clean:
	@echo "Cleaning build artifacts..."
	# Remove Xcode build products
	-rm -rf LocationTrackerDemo/build
	-rm -rf LocationTrackerPackage/.build
	-rm -rf DerivedData
	
	# Remove documentation build artifacts
	-rm -rf LocationTrackerPackage/.docc-build
	-rm -rf docs
	
	# Remove test artifacts
	-rm -rf LocationTrackerPackage/.coverage
	-rm -rf LocationTrackerPackage/coverage.lcov
	-rm -rf LocationTrackerPackage/test-results.xml
	
	# Remove temporary files
	-find . -name "*.tmp" -delete
	-find . -name ".DS_Store" -delete
	-find . -name "Thumbs.db" -delete
	
	@echo "Build artifacts cleaned."

# Remove user-specific data and caches
userclean:
	@echo "Cleaning user-specific data..."
	# Remove Xcode user data
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcodeproj/xcuserdata
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcodeproj/project.xcworkspace/xcuserdata
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcworkspace/xcuserdata
	
	# Remove user preferences
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
	
	# Remove Swift Package Manager caches
	-rm -rf LocationTrackerPackage/.swiftpm
	-rm -rf ~/.swiftpm/cache
	
	@echo "User-specific data cleaned."

# Complete cleanup - removes everything including project files
distclean: clean userclean
	@echo "Performing deep clean..."
	# Remove package resolution files
	-rm -rf LocationTrackerPackage/Package.resolved
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
	
	# Remove Xcode project files (forces regeneration)
	-rm -rf LocationTrackerDemo/LocationTrackerDemo.xcodeproj/project.xcworkspace
	
	# Remove any generated source files (if applicable)
	-find . -name "*.generated.swift" -delete
	
	@echo "Deep clean completed. Project reset to initial state."
