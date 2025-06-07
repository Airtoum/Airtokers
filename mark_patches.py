import os
import re
import sys
import datetime

# do not change without removing all the old marks!
# nevermind there is a template file now

mark = '\t\t -- Airtokers! // >⏝o )\\'
mark = '       -- Airtokers! // >\\\\\\\\u23ddo )\\'
mark = '\t\t -- Airtokers! // >⏝o )\\\\ '
mark = '\t\t -- Airtokers! // >⏝o )\\t'
mark = '\t\t -- Airtokers! // >⏝o )\\u005C'   # for " 
mark2 = '\t\t -- Airtokers! // >⏝o )\\'       # for '''

def mark_spaced(line: str, variant):
    if '<NO MARK>' in line:
        return ''
    pad_size = 20
    padding = ' ' * (-len(line) + (-((-len(line)) // pad_size) * pad_size))
    if variant == 'Variant A':
        return padding + mark
    else:
        return padding + mark2

only_remove_marks = False

if len(sys.argv) >= 2:
    os.chdir(sys.argv[1])
print(f"marking in {os.getcwd()}\n")

for dirpath, dirnames, filenames in os.walk('.\\lovely'):
    for filename in filenames:
        if filename.endswith('.toml.um'):
            source_filepath = os.path.join(dirpath, filename)
            print(f'found {source_filepath}')
            with open(source_filepath, 'r', encoding='utf8') as thefile:
                thetoml = thefile.read()
                #with open(source_filepath + '.txt', 'w') as thebackup:
                #    thebackup.write(thetoml)
                
                toml_lines = thetoml.splitlines()
                in_payload = False
                start_of_payload = False
                single_line_payload = False
                end_of_payload = False
                for i, line in enumerate(toml_lines):
                    line = line.replace(mark, '') # remove all marks
                    line = line.replace(mark2, '') # remove all marks
                    if not only_remove_marks:
                        if (m := re.match("^payload =[\\s]*'''(.*)", line)) and not re.match("^payload=[\\s]*'''.+'''[\\s]*$", line):
                            if m[1].strip() != '':
                                in_payload = True
                            else:
                                start_of_payload = True
                        if in_payload:
                            def replacement(m):
                                global end_of_payload
                                end_of_payload = True
                                return f'{m[1]}{mark_spaced(m[1], 'Variant B')}{m[2]}'
                            if re.match(".*'''[\\s]*$", line):
                                line = re.sub("^([\\s]*[\\S].*[\\s]*)('''[\\s]*)$", replacement, line)
                                in_payload = False
                            else:
                                line = line + mark_spaced(line, 'Variant B')
                        else:
                            def replacement(m):
                                global single_line_payload
                                single_line_payload = True
                                return f'{m[1]}{mark_spaced(m[1], 'Variant A')}{m[2]}'
                            line = re.sub("^(payload = \".+)(\"[\\s]*)$", replacement, line)
                    try:
                        print(f'{single_line_payload:<2}{start_of_payload:<2}{in_payload:<2}{end_of_payload:<5}' + line)
                    except UnicodeEncodeError:
                        print((f'{single_line_payload:<2}{start_of_payload:<2}{in_payload:<2}{end_of_payload:<5}' + line).replace('⏝', '_'))
                    toml_lines[i] = line
                    if start_of_payload:
                        in_payload = True
                        start_of_payload = False
                    single_line_payload = False
                    end_of_payload = False
                
                with open(source_filepath.replace('.toml.um', '.toml'), 'w', encoding='utf8') as theoutfile:
                    theoutfile.write("\n".join(toml_lines)+'\n')


if len(sys.argv) >= 3:
    print(f'{datetime.datetime.now()} done \t\t :)')
else:
    input('done')




