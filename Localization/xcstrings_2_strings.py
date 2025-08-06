#!/usr/bin/env python3
"""
Convert .xcstrings file to traditional .strings files for each language.
This script parses a .xcstrings file and generates .strings files for each language
in the appropriate .lproj directories.
"""

import json
import os
import argparse
import re

def escape_string(s):
    """Escape a string for use in a .strings file."""
    # Replace backslashes first to avoid double escaping
    s = s.replace('\\', '\\\\')
    s = s.replace('"', '\\"')
    s = s.replace('\n', '\\n')
    s = s.replace('\r', '\\r')
    s = s.replace('\t', '\\t')
    return s

def convert_xcstrings_to_strings(xcstrings_path, output_dir):
    """Convert a .xcstrings file to .strings files for each language."""
    # Read the .xcstrings file
    with open(xcstrings_path, 'r', encoding='utf-8') as f:
        xcstrings_data = json.load(f)
    
    # Get the source language
    source_language = xcstrings_data.get('sourceLanguage', 'en')
    print(f"Source language: {source_language}")
    
    # Create a dictionary to store translations for each language
    languages = {}
    
    # Process each string
    for key, string_data in xcstrings_data.get('strings', {}).items():
        comment = string_data.get('comment', '')
        
        # Process localizations
        for lang, localization in string_data.get('localizations', {}).items():
            if lang not in languages:
                languages[lang] = []
            
            # Get the translated value
            value = localization.get('stringUnit', {}).get('value', key)
            
            # Add the translation to the language dictionary
            languages[lang].append({
                'key': key,
                'value': value,
                'comment': comment
            })
    
    # Also create a .strings file for the source language (English)
    # Since English might not have explicit translations in the .xcstrings file
    if source_language not in languages:
        languages[source_language] = []
        for key, string_data in xcstrings_data.get('strings', {}).items():
            languages[source_language].append({
                'key': key,
                'value': key,  # Use the key as the value for the source language
                'comment': string_data.get('comment', '')
            })
    
    # Create .strings files for each language
    for lang, translations in languages.items():
        # Create the .lproj directory if it doesn't exist
        lproj_dir = os.path.join(output_dir, f"{lang}.lproj")
        os.makedirs(lproj_dir, exist_ok=True)
        
        # Create the .strings file
        strings_path = os.path.join(lproj_dir, "Localizable.strings")
        with open(strings_path, 'w', encoding='utf-16') as f:
            for translation in translations:
                key = escape_string(translation['key'])
                value = escape_string(translation['value'])
                comment = translation['comment']
                
                # Write the comment if it exists
                if comment:
                    f.write(f"/* {comment} */\n")
                
                # Write the key-value pair
                f.write(f"\"{key}\" = \"{value}\";\n\n")
        
        print(f"Created {strings_path} with {len(translations)} translations")

def main():
    parser = argparse.ArgumentParser(description='Convert .xcstrings to .strings files')
    parser.add_argument('xcstrings_path', help='Path to the .xcstrings file')
    parser.add_argument('--output-dir', '-o', default=None, 
                        help='Output directory (defaults to the directory containing the .xcstrings file)')
    
    args = parser.parse_args()
    
    # If output_dir is not specified, use the directory containing the .xcstrings file
    output_dir = args.output_dir
    if output_dir is None:
        output_dir = os.path.dirname(args.xcstrings_path)
    
    convert_xcstrings_to_strings(args.xcstrings_path, output_dir)

if __name__ == '__main__':
    main()
