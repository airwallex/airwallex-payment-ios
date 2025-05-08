import xml.etree.ElementTree as ET
import csv
import os

export_dir = 'exported'
csv_file = 'translations.csv'
updated_dir = 'updated'

# Gather all xliff file info from .xcloc dirs
xliff_files = []
for file in os.listdir(export_dir):
    if file.endswith('.xcloc'):
        code = file.rsplit('.', 1)[0]
        xliff_path = os.path.join(export_dir, file, 'Localized Contents', f'{code}.xliff')
        xliff_files.append((code, xliff_path))

def extract_default_namespace(element):
    if element.tag[0] == '{':
        return element.tag[1:].split('}')[0]
    return ''

# Read localization data from CSV into a dict
with open(csv_file, mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f)
    rows = list(reader)
    header_row = rows[0]  # The CSV header

    # Build lookup: key=file_name-tu_id, value=row
    rows_dict = {}
    for row in rows[1:]:
        file_name, tu_id = row[0], row[1]
        key = f"{file_name}-{tu_id}"
        rows_dict[key] = row

    print("CSV header:", header_row)

    for code, xliff_path in xliff_files:
        if not os.path.exists(xliff_path):
            print(f"Warning: {xliff_path} not found.")
            continue

        col_name = f'target({code})'
        try:
            column_idx = header_row.index(col_name)
        except ValueError:
            print(f"Warning: No column '{col_name}' in CSV for {xliff_path}. Skipping.")
            continue

        tree = ET.parse(xliff_path)
        root = tree.getroot()
        namespace = extract_default_namespace(root)
        namespaces = {'ns': namespace}
        updated_count = 0

        # For each file in xliff (just in case)
        for file_elem in root.iterfind('.//ns:file', namespaces):
            file_name = file_elem.attrib.get('original', '')
            if file_name.endswith('InfoPlist.strings') or file_name.endswith('InfoPlist.xcstrings'):
                continue

            for tu in file_elem.iterfind('.//ns:trans-unit', namespaces):
                tu_id = tu.attrib.get('id', '')
                target = tu.find('ns:target', namespaces)
                updated_row = rows_dict.get(f"{file_name}-{tu_id}")
                if updated_row:
                    new_text = updated_row[column_idx].strip()
                    if not new_text:
                        continue
                    if target is None:
                        target = ET.SubElement(tu, 'target')
                    if target.text != new_text:  # Only update if different
                        target.text = new_text
                        updated_count += 1

        # Write updated XLIFF back out
        updated_xliff_path = os.path.join(updated_dir, f'{code}.xliff')
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(updated_xliff_path), exist_ok=True)
        ET.register_namespace('', namespace)
        tree.write(updated_xliff_path, encoding='utf-8', xml_declaration=True)
        if updated_count > 0:
            print(f"{updated_count} translations updated in: {updated_xliff_path}")
        else:
            print(f"No updates for {xliff_path}")

print(f"\nDone! XLIFF files updated using {csv_file}")