# Highlights Screensaver
A KOReader plugin to show a random highlight on your screensaver.

## What does this plugin do?
Highlights Screensaver replaces your sleep screen wallpaper with a randomly selected highlight from one of the books in your library.

### Example images
![Light theme example 1](images/light_01.JPG)
![Light theme example 2](images/light_02.JPG)
![Dark theme example 2](images/dark_01.JPG)

## Features
- Shows you the original quote, source (book & author), and any notes you have attached to a highlight.
- Automatically remains up to date with your latest highlights.
- Automatically resizes to dynamically fit content of varying length on the sleep screen.
- Independent font selection for quote, source, and notes.
- Light and Dark themes.
- Disable any unwanted highlights from appearing on your sleep screen.

## Installation & setup
1. Download the latest `HighlightsScreensaver.zip` from the releases page and unzip the contents.
2. Copy the `highlightsscreensaver.koplugin` directory into `koreader/plugins/` on your device.
3. Restart KOReader and setup the plugin following the instructions below.

### Setup instructions
1. In the settings menu (the cog icon), go to `Screen > Sleep screen > Wallpaper`. Select "Show highlights screensaver".

Next we will set up the directories which Highlights Screensaver will scan for book highlights.

2. Navigate to wherever your books are stored.
3. In the settings menu, go to `Screen > Sleep screen > Highlights screensaver`. Select "Add current directory to scannable directories".

You may add as many directories to Highlights Screensaver's watch list as you want, but most users will likely only need to add the top-level directory which contains their library. This is likely the location you've made your home directory. Note that all subdirectories will also be scanned, so there is no need to add these individually if you've already added your top-level library directory.

4. In the settings menu, go to `Screen > Sleep screen > Highlights screensaver`. Select "Scan book highlights".

This will perform an initial scan of any existing highlights that Highlights Screensaver will use. From this point onwards, highlights will be kept up to date as Highlights Screensaver will perform a background scan the first time the sleep screen is entered each day. You may also manually trigger a scan at any time by going to the "Scan book highlights" option.

5. Configure fonts and theme to your preference, once again under `Screen > Sleep screen > Highlights screensaver`.

## Compatibility
Highlights Screensaver has been tested to work on Kobo Libra Colour running KOReader 2025.10. It may (should?) work on other devices, but I do not have any others to test with.

If you find it works on a different device, please let me know so I can compile a compatibility list. If it doesn't, please open an issue or contribute to the project.

---
⭐ Please leave a star if you enjoy Highlights Screensaver
