# Core Functionality
- Cross-platform image viewing app (Windows, macOS, Linux)
- Open single images or entire folders
- Support common image formats (JPEG, PNG, GIF, BMP, WebP, TIFF, etc.)
- File associations on desktop operating systems to open images directly
- "Open with..." context menu integration for all supported platforms
- When opening the app without a specific file, show empty view with an open button in the middle

# Image Viewing
- Large primary view for the current image
- Zoom functionality with Ctrl + mouse wheel
- Toggle full-screen mode with F key
- Rotate images using < and > keys
- Image rotation option in context menu (right-click)
- Copy image to clipboard using platform-native shortcuts (Ctrl+C, Cmd+C)
- Basic metadata display in status bar (resolution, file size, etc.)
- Display clear error message in the image canvas area when an image fails to load

# Gallery View
- Horizontal scrollable gallery at the bottom showing folder contents
- Large, clear thumbnails in the gallery
- Currently selected image highlighted in the gallery
- Gallery view should be collapsible to maximize viewing area
- Thumbnails generated with Flutter's image caching system

# Navigation
- Keyboard navigation with left/right arrows to move between images
- Click on thumbnails in gallery to select an image
- Gallery scrolls automatically when navigating through images

# Core Framework
- Flutter: Cross-platform UI framework for building natively compiled applications
- flutter_riverpod or Provider: For state management
- go_router: For navigation and deep linking

# UI Framework
- Material Design: Primary design system 
- flutter_adaptive_scaffold: For responsive layouts across different screen sizes

# Image Processing
- flutter_cache_manager: For caching and managing loaded images
- photo_view: Advanced image viewing with pan/zoom capabilities
- exif: For extracting EXIF metadata from images

# File System & Utilities
- path_provider: For accessing platform-specific file locations
- file_picker: For selecting files and directories
- shared_preferences: For storing app settings and recent files

# Build Tools
- Flutter SDK: All-in-one build system for all target platforms
- dart_code_metrics: For code quality analysis

# Packaging
- flutter build: Native packaging for all supported platforms
- flutter_distributor: For managing release workflows
