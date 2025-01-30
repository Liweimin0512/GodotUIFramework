# UI Framework Localization Module

## Overview
The localization module provides a powerful and flexible way to handle multiple languages and localized resources in your Godot game. It is designed to be component-based, type-safe, and seamlessly integrated with the UI Framework.

## Key Features

### 1. Component-Based Design
The module provides specialized components for different types of localization:
- `UILocalizedTextComponent`: For text localization
- `UILocalizedTextureComponent`: For texture/image localization
- `UILocalizedAudioComponent`: For audio localization
- `UILocalizedStyleComponent`: For theme style localization

### 2. Resource Management
- Support for multiple resource types:
  - Text translations
  - Images/Textures
  - Audio files
  - Theme styles (StyleBox, Font, Color, etc.)
- Dynamic resource loading and unloading
- Automatic resource switching when language changes

### 3. Formatting Features
- Number formatting with locale-specific rules
  - Decimal separators
  - Thousands separators
  - Currency symbols
- Date/Time formatting with multiple styles:
  - Short format (e.g., "MM/DD/YYYY")
  - Medium format (e.g., "MMM DD, YYYY")
  - Long format (e.g., "MMMM DD, YYYY")

### 4. Integration with UI Framework
- Managed through `UIManager.localization_manager`
- Automatic UI updates when language changes
- Seamless integration with other UI Framework modules

## Usage

### Basic Setup
```gdscript
# Get localization manager
var localization_manager = UIManager.localization_manager

# Load translations
localization_manager.load_translations("en", "res://translations/en.json")
localization_manager.load_translations("zh_CN", "res://translations/zh_CN.json")

# Switch language
localization_manager.current_locale = "zh_CN"
```

### Using Components

#### Text Component
```gdscript
# In scene tree
var text_component = UILocalizedTextComponent.new()
text_component.key = "welcome"
text_component.params = {"name": "User"}
label.add_child(text_component)
```

#### Texture Component
```gdscript
var texture_component = UILocalizedTextureComponent.new()
texture_component.key = "background_image"
texture_rect.add_child(texture_component)
```

#### Audio Component
```gdscript
var audio_component = UILocalizedAudioComponent.new()
audio_component.key = "background_music"
audio_player.add_child(audio_component)
```

#### Style Component
```gdscript
var style_component = UILocalizedStyleComponent.new()
style_component.key = "button_style"
style_component.style_type = "StyleBox"
style_component.style_name = "normal"
button.add_child(style_component)
```

### Translation Files
Translation files use JSON format:
```json
{
    "welcome": "Welcome, {name}!",
    "title": "Game Title",
    "menu": {
        "start": "Start Game",
        "options": "Options"
    }
}
```

### Number Formatting
```gdscript
# Format number
var formatted = localization_manager.format_number(1234.56)  # "1,234.56"

# Format currency
var currency = localization_manager.format_number(1234.56, "currency")  # "$1,234.56"
```

## Advantages Over Godot's Native System

1. **Component-Based Architecture**
   - Modular and reusable components
   - Automatic UI updates on language change
   - Better organization and maintenance

2. **Flexible Resource Management**
   - Support for multiple resource types
   - Dynamic resource loading
   - Better memory management

3. **Enhanced Formatting**
   - Rich number formatting options
   - Customizable date/time formatting
   - Currency support

4. **Type Safety**
   - GDScript type system integration
   - Reduced runtime errors
   - Better IDE support

5. **UI Framework Integration**
   - Seamless integration with other modules
   - Centralized management through UIManager
   - Consistent API design

6. **Parameter Support**
   - Dynamic text parameters
   - Real-time parameter updates
   - Complex string formatting

7. **Developer Experience**
   - Editor-friendly components
   - Clear API design
   - Better error handling and debugging

8. **Extensibility**
   - Easy to add new components
   - Customizable formatting rules
   - Support for new resource types

## Best Practices

1. **Organization**
   - Keep translation files organized by language
   - Use consistent key naming conventions
   - Group related translations

2. **Resource Management**
   - Preload commonly used resources
   - Unload unused resources when changing languages
   - Use appropriate resource formats

3. **Error Handling**
   - Always check if translations exist
   - Provide fallback values
   - Log missing translations

4. **Performance**
   - Cache frequently used translations
   - Batch load resources
   - Use appropriate component update strategies

## Example
See the example scene at `addons/GodotUIFramework/examples/localization/localization_example.tscn` for a complete demonstration of the localization module's features.
