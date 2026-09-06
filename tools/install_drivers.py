#!/usr/bin/env python3
"""
Download browser drivers (Chrome, Firefox, Edge) into ./drivers using webdriver-manager.
Run: python tools/install_drivers.py
"""
import os
import shutil
from pathlib import Path

import sys
import subprocess
import importlib

# selenium and webdriver-manager are ensured at runtime in main()


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

    # Ensure a virtualenv exists at project root and use its pip/python
    def ensure_venv(root: Path, name: str = '.venv') -> Path:
        venv_dir = root / name
        if not venv_dir.exists():
            print(f"Creating virtual environment at {venv_dir}...")
            subprocess.check_call([sys.executable, '-m', 'venv', str(venv_dir)])
        # Find the venv python executable
        if os.name == 'nt':
            py = venv_dir / 'Scripts' / 'python.exe'
        else:
            py = venv_dir / 'bin' / 'python'
        if not py.exists():
            raise RuntimeError(f"Virtualenv python not found at {py}")
        return py

    venv_python = ensure_venv(root)

    # Ensure required packages are installed into the venv
    for pkg_name, check_module in (('selenium', 'selenium'), ('webdriver-manager', 'webdriver_manager')):
        try:
            # Try importing using the venv python to check
            subprocess.check_call([str(venv_python), '-c', f"import {check_module}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            print(f"Installing '{pkg_name}' into virtualenv...")
            subprocess.check_call([str(venv_python), '-m', 'pip', 'install', pkg_name])

    # If not running under the venv Python, re-exec the script under it so imports come from the venv
    if Path(sys.executable) != venv_python:
        print(f"Re-running under virtualenv python: {venv_python}")
        os.execv(str(venv_python), [str(venv_python), str(Path(__file__).resolve())] + sys.argv[1:])

    # Imports that require the packages above (now running inside venv)
    from selenium import webdriver  # noqa: F401
    from webdriver_manager.chrome import ChromeDriverManager
    from webdriver_manager.firefox import GeckoDriverManager
    from webdriver_manager.microsoft import EdgeChromiumDriverManager

    drivers = [
        ('chromedriver', ChromeDriverManager().install),
        ('geckodriver', GeckoDriverManager().install),
        ('msedgedriver', EdgeChromiumDriverManager().install),
    ]

    for name, manager_install in drivers:
        dst = drivers_dir / name
        # If driver already in drivers_dir, skip
        if dst.exists():
            print(f"{name} already present at {dst}, skipping download.")
            make_executable(dst)
            continue
        # If driver exists on PATH, copy it locally
        which = shutil.which(name)
        if which:
            print(f"{name} found in PATH at {which}, copying to {drivers_dir}.")
            shutil.copy2(which, dst)
            make_executable(dst)
            continue
        # Otherwise download via webdriver-manager
        try:
            install_driver(manager_install, drivers_dir, name)
        except Exception as e:
            print(f"{name} install failed: {e}")

    print('\nDone. To use these drivers temporarily for the test run:')
    print(f"  export PATH={drivers_dir}:$PATH")
    print('Then run the Robot tests:')
    print('  robot tests/mDS.robot')


if __name__ == '__main__':
    main()
