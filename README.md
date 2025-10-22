# QuickSpec

A World of Warcraft addon for quickly switching between talent specializations.

## Features

- **No Dependencies**: Uses native Blizzard UI frames instead of Ace3 libraries
- **Dynamic UI**: Frame automatically resizes based on the number of available specializations
- **Slash Commands**: Support for `/quickspec` and `/qs` commands
- **Key Binding**: Configurable keybind to open/close the interface
- **Click to Switch**: Simple click interface to change specializations

## Usage

### Interface
- Use `/quickspec` or `/qs` to open the specialization selector
- Click on any specialization icon to switch to that spec
- The frame shows your current spec at the top and available alternatives below
- Frame automatically closes after selecting a specialization

### Slash Commands
- `/quickspec` or `/qs` - Opens the GUI interface
- `/quickspec <specname>` or `/qs <specname>` - Directly switches to the named specialization

### Key Binding
- Set up a key binding in the game's Key Bindings menu under "QuickSpec"

## Changes in Version 901.3

- **Removed Ace3 Dependency**: Completely rewritten to use native Blizzard UI frames
- **Improved Performance**: No external library dependencies means faster loading
- **Better Integration**: Uses standard Blizzard frame templates for consistent look and feel
- **Maintained Functionality**: All original features preserved while removing dependencies

## Installation

1. Extract the QuickSpec folder to your `World of Warcraft\_retail_\Interface\AddOns\` directory
2. Restart World of Warcraft or reload your UI (`/reload`)
3. The addon should appear in your AddOns list

## Technical Notes

The addon now uses:
- `CreateFrame()` with `BasicFrameTemplateWithInset` for the main window
- Native font strings and textures for UI elements  
- Standard Blizzard button templates
- Built-in frame movement and drag functionality

This eliminates the need for any external libraries while maintaining all functionality.