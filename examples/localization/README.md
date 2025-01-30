# Localization Example

This example demonstrates the usage of the UI Framework's localization module. It showcases various features including:

- Text translation with parameters
- Language switching
- Date/time formatting
- Number formatting
- Currency formatting

## Features Demonstrated

1. **Language Switching**
   - Switch between English, Simplified Chinese, and Japanese
   - UI updates automatically when language changes

2. **Text Translation**
   - Basic text translation
   - Parameter substitution in translations

3. **Date/Time Formatting**
   - Short date format
   - Medium date format
   - Long date format

4. **Number Formatting**
   - Basic number formatting
   - Currency formatting with appropriate symbols

## How to Use

1. Open the `localization_example.tscn` scene
2. Run the scene
3. Use the language selector dropdown to switch between different languages
4. Observe how different elements update according to the selected language

## Translation Files

Translation files are stored in the `translations` directory:
- `en.json`: English translations
- `zh_CN.json`: Simplified Chinese translations
- `ja.json`: Japanese translations

## Code Structure

- `localization_example.tscn`: Main scene file
- `localization_example.gd`: Main script handling the localization logic
- `translations/*.json`: Translation files for different languages
