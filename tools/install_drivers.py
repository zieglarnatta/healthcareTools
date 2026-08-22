#!/usr/bin/env python3
"""
Download browser drivers (Chrome, Firefox, Edge) into ./drivers using webdriver-manager.
Run: python tools/install_drivers.py
"""
import os
import shutil
from pathlib import Path

from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from webdriver_manager.microsoft import EdgeChromiumDriverManager


def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)


def make_executable(p: Path):
    mode = p.stat().st_mode
    p.chmod(mode | 0o111)


def install_driver(manager_install_func, dest: Path, name: str):
    print(f"Installing {name}...")
    path = manager_install_func()
    src = Path(path)
    if not src.exists():
        raise RuntimeError(f"Downloaded driver not found: {src}")
    dst = dest / name
    shutil.copy2(src, dst)
    make_executable(dst)
    print(f"{name} installed to: {dst}")
    return dst


def main():
    root = Path(__file__).resolve().parents[1]
    drivers_dir = root / 'drivers'
    ensure_dir(drivers_dir)

    # Chrome
    try:
        chrome = install_driver(ChromeDriverManager().install, drivers_dir, 'chromedriver')
    except Exception as e:
        print(f"Chrome driver install failed: {e}")

    # Gecko (Firefox)
    try:
        gecko = install_driver(GeckoDriverManager().install, drivers_dir, 'geckodriver')
    except Exception as e:
        print(f"Gecko driver install failed: {e}")

    # Edge
    try:
        edge = install_driver(EdgeChromiumDriverManager().install, drivers_dir, 'msedgedriver')
    except Exception as e:
        print(f"Edge driver install failed: {e}")

    print('\nDone. To use these drivers temporarily for the test run:')
    print(f"  export PATH={drivers_dir}:$PATH")
    print('Then run the Robot tests:')
    print('  robot tests/mDS.robot')


if __name__ == '__main__':
    main()
