#!/usr/bin/env python3
"""
Download Firefox ESR 115.9.0 and ensure geckodriver is latest via webdriver-manager.
Extract Firefox to ./drivers/firefox and leave geckodriver in ./drivers as before.
Run: python tools/install_firefox_esr.py
"""
import os
import shutil
import tarfile
import sys
from pathlib import Path
from urllib.request import urlretrieve

DRIVERS = Path(__file__).resolve().parents[1] / 'drivers'
ensure = DRIVERS.mkdir
ensure(parents=True, exist_ok=True)

# Firefox ESR 115.9.0 (example) - adjust locale if necessary
ESR_VERSION = '115.9.0esr'
FIREFOX_NAME = f'firefox-{ESR_VERSION}.tar.bz2'
FIREFOX_URL = f'https://archive.mozilla.org/pub/firefox/releases/{ESR_VERSION}/linux-x86_64/en-US/{FIREFOX_NAME}'
FIREFOX_DEST = DRIVERS / 'firefox'


def download_firefox():
    print('Downloading Firefox ESR 115...')
    dest = DRIVERS / FIREFOX_NAME
    if dest.exists():
        print('Archive already exists:', dest)
    else:
        urlretrieve(FIREFOX_URL, dest)
        print('Downloaded to', dest)
    # Extract
    if FIREFOX_DEST.exists():
        print('Existing firefox folder found, removing...')
        shutil.rmtree(FIREFOX_DEST)
    with tarfile.open(dest, 'r:bz2') as tf:
        tf.extractall(DRIVERS)
    # Extraction produces a 'firefox' folder
    extracted = DRIVERS / 'firefox'
    if not extracted.exists():
        print('Unexpected extraction layout, aborting')
        sys.exit(2)
    print('Firefox extracted to', extracted)
    print('Firefox binary at', extracted / 'firefox')


def ensure_geckodriver():
    try:
        from webdriver_manager.firefox import GeckoDriverManager
    except Exception as e:
        print('webdriver-manager not available, install requirements first')
        raise
    path = GeckoDriverManager().install()
    dst = DRIVERS / 'geckodriver'
    shutil.copy2(path, dst)
    dst.chmod(0o755)
    print('Geckodriver installed to', dst)


if __name__ == '__main__':
    download_firefox()
    ensure_geckodriver()
    print('\nDone. To use locally, export PATH or pass binary path to tests:')
    print(f'  export PATH={DRIVERS}:$PATH')
    print(f'Firefox binary: {FIREFOX_DEST / "firefox"}')
