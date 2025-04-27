import xml.etree.ElementTree as ET
import csv
import os


csv_file = 'output.csv'

xliff_files = []

# find xliff file in current directory
for file in os.listdir('.'):
    if file.endswith('.xcloc'):
        code = file.split('.')[0]
        xliff_files.append((code, file + f'/Localized Contents/{code}.xliff'))

# print(xliff_files)

header = [
    'file',
    'id'
]

# insert target language codes as column in header in the formate of target(LANG) after 'id'
sorted_target_languages = sorted([x[0] for x in xliff_files])
# print(sorted_target_languages)

# insert target language codes as column in header in the formate of target(LANG) after 'id'
for lang in sorted_target_languages:
    header.append(f'target({lang})')

header.append('note')

# print(header)
# create csv file
namespaces = {'ns': 'urn:oasis:names:tc:xliff:document:1.2'}
with open(csv_file, mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    code = xliff_files[0][0]
    xliff_file = xliff_files[0][1]
    tree = ET.parse(xliff_file)
    root = tree.getroot()

    # Define namespace map

    # We'll only use the language codes from the *first* file element for the column headers
    file_elem = root.find('.//ns:file', namespaces)
    tgt_lang = file_elem.attrib.get('target-language', '') if file_elem is not None else ''
    print(f"Target language: {tgt_lang}")
    # For each file block
    for file_elem in root.iterfind('.//ns:file', namespaces):
        file_name = file_elem.attrib.get('original', '')
        # print(file_name)
        if file_name.endswith('InfoPlist.strings') or file_name.endswith('InfoPlist.xcstrings'):
            continue
        for tu in file_elem.iterfind('.//ns:trans-unit', namespaces):
            tu_id = tu.attrib.get('id', '')
            target = tu.find('ns:target', namespaces)
            note = tu.find('ns:note', namespaces)
            tgt_text = target.text if target is not None else ''
            note_text = note.text if note is not None else ''
            
            row = [ file_name, tu_id ]
            for lang in sorted_target_languages:
                if lang == code:
                    row.append(tgt_text)
                else:
                    row.append('')
            row.append(note_text)

            writer.writerow(row)

# update other languages
with open(csv_file, mode='r', encoding='utf-8', newline='') as f:
    reader = csv.reader(f)
    rows = list(reader)  # Read all rows into a list
    for xliff_file in xliff_files[1:]:
        code = xliff_file[0]
        xliff_file = xliff_file[1]
        tree = ET.parse(xliff_file)
        root = tree.getroot()

        file_elem = root.find('.//ns:file', namespaces)
        tgt_lang = file_elem.attrib.get('target-language', '') if file_elem is not None else ''
        print(f"Target language: {tgt_lang}")
        # For each file block
        for file_elem in root.iterfind('.//ns:file', namespaces):
            file_name = file_elem.attrib.get('original', '')
            # print(file_name)
            if file_name.endswith('InfoPlist.strings') or file_name.endswith('InfoPlist.xcstrings'):
                continue
            for tu in file_elem.iterfind('.//ns:trans-unit', namespaces):
                tu_id = tu.attrib.get('id', '')
                target = tu.find('ns:target', namespaces)
                tgt_text = target.text if target is not None else ''

                for row in rows:  # Iterate over the list of rows
                    if row[1] == tu_id and row[0] == file_name:
                        row[header.index(f'target({code})')] = tgt_text
                        break
                
    # Write the updated rows back to the CSV file
    with open(csv_file, mode='w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(rows)

print(f"Done! CSV saved as {csv_file}")