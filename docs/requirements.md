# Core Functionality
- Cross-platform image viewing app (Windows, macOS, Linux)
- Open single images or entire folders
- Support common image formats (JPEG, PNG, GIF, BMP, WebP, TIFF, etc.)
- File associations on all operating systems to open images directly
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
- If the folder contains other folders, those are listed at start of the gallery and double-clicking them sets that folder as parent, the first thumbnail is also for navigating to parent folder
- Currently selected image highlighted in the gallery
- Gallery view should be collapsible to maximize viewing area
- Thumbnails generated in real-time (optimization deferred)

# Navigation
- Keyboard navigation with left/right arrows to move between images, however if a folder or parent are selected, that does not automatically open them, instead it changes content view to one with a message to 'press Enter to open xxx' where xxx is the target folder name
- Click on thumbnails in gallery to select an image
- Gallery scrolls automatically when navigating through images
