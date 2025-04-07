
import PIL
import pathlib
import os

import PIL.PngImagePlugin
import PIL.Image

for dirpath, dirnames, filenames in os.walk('.\\assets\\1x'):
    for filename in filenames:
        if filename.endswith('png'):
            source_filepath = os.path.join(dirpath, filename)
            with PIL.Image.open(source_filepath) as thefile:
                resized = thefile.resize((thefile.size[0] * 2, thefile.size[1] * 2), resample=PIL.Image.Resampling.NEAREST)
                dest_filepath = os.path.join(dirpath, filename).replace('1x', '2x')
                resized.save(dest_filepath)
                print(f'Resized {source_filepath} to {dest_filepath}')

input('Done!')
