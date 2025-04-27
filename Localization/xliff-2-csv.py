import xml.etree.ElementTree as ET
import csv

xliff_file = 'Airwallex Localizations/en.xcloc/Localized Contents/en.xliff'
csv_file = 'output.csv'

tree = ET.parse(xliff_file)
root = tree.getroot()

namespace = ''
if '}' in root.tag:
    namespace = root.tag.split('}')[0] + '}'

# We'll only use the language codes from the *first* file element for the column headers
file_elem = root.find('.//{}file'.format(namespace))
src_lang = file_elem.attrib.get('source-language', '') if file_elem is not None else ''
tgt_lang = file_elem.attrib.get('target-language', '') if file_elem is not None else ''

header = [
    'file',
    'id',
    f'source({src_lang})',
    f'target({tgt_lang})',
    'note'
]

with open(csv_file, mode='w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)

    # For each file block
    for file_elem in root.iterfind('.//{}file'.format(namespace)):
        file_name = file_elem.attrib.get('original', '')
        if file_name.endswith('InfoPlist.strings') or file_name.endswith('InfoPlist.xcstrings'):
            continue
        for tu in file_elem.iterfind('.//{}trans-unit'.format(namespace)):
            tu_id = tu.attrib.get('id', '')
            source = tu.find('{}source'.format(namespace))
            target = tu.find('{}target'.format(namespace))
            note = tu.find('{}note'.format(namespace))
            src_text = source.text if source is not None else ''
            tgt_text = target.text if target is not None else ''
            note_text = note.text if note is not None else ''
            writer.writerow([
                file_name,
                tu_id,
                src_text,
                tgt_text,
                note_text
            ])

print(f"Done! CSV saved as {csv_file}")