import os
import re
import sys
import urllib.request

DEFAULT_KEY_FILE   = './.openai.api_key'
DEFAULT_NUMBER     = 1
DEFAULT_IMAGE_SIZE = "1024x1024"
DEFAULT_DOWNLOAD_DIR = './downloads'

def die(msg):
    print(f'{msg}; exiting')
    sys.exit(1)

def prompt_number(default=DEFAULT_NUMBER):
    n = input(f'Number (default={default}): ')
    return int(n) if n else default

def prompt_prompt():
    prompt = input('Prompt: ')
    if not prompt:
        die('No prompt')
    return prompt

def prompt_api_key(default_key_file=DEFAULT_KEY_FILE, persist=True):
    default_key = None
    if default_key_file and os.path.exists(default_key_file):
        with open(default_key_file) as f:
            default_key = f.read().strip()
    key = input(f'API Key (default={default_key_file}): ')
    if not key:
        key = default_key
    if not key:
        die('No API key')
    if persist:
        with open(default_key_file, 'w') as f:
            f.write(key)
    return key

def prompt_image_size(default=DEFAULT_IMAGE_SIZE):
    size = input(f'Image size (default={default}): ')
    if not size:
        size = default
    if not re.match('([0-9]+)x([0-9]+)', size):
        die('Input image size format {height}x{width}')
    return size

def confirm(text):
    print('''\nFor review:''')
    print()
    print('\t'.join(('\n'+text).splitlines()))
    print()
    while True:
        resp = input('Confirm? (y/n) ')
        if re.match('^[Yy]$', resp):
            return True
        elif re.match('^[Nn]$', resp):
            return False

def download_to_directory(urls, directory, basedir=DEFAULT_DOWNLOAD_DIR, suffix='.png'):
    dirpath = os.path.join(basedir, str(directory))
    os.makedirs(dirpath, exist_ok=True)
    i = 0
    for url in urls:
        i += 1
        filepath = os.path.join(dirpath, f'{i}{suffix}')
        urllib.request.urlretrieve(url, filepath)
        print(f'Downloaded {filepath}')

